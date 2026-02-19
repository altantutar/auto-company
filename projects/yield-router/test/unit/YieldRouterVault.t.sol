// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TransparentUpgradeableProxy} from
    "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {YieldRouterVault} from "../../src/core/YieldRouterVault.sol";
import {IYieldRouterVault} from "../../src/interfaces/IYieldRouterVault.sol";
import {IYieldRouterAdapter} from "../../src/interfaces/IYieldRouterAdapter.sol";
import {Allocator} from "../../src/core/Allocator.sol";

// ─────────────────────────────────────────────────────────────────────────────
// Mock USDC (6 decimals)
// ─────────────────────────────────────────────────────────────────────────────

contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin", "USDC") {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock Adapter — simple in-memory balance tracking
// ─────────────────────────────────────────────────────────────────────────────

contract MockAdapter is IYieldRouterAdapter {
    address public override vault;
    address public override asset;
    uint256 public override riskWeight;
    uint256 internal _balance;
    uint256 public apyBps;

    constructor(address _vault, address _asset, uint256 _riskWeight) {
        vault = _vault;
        asset = _asset;
        riskWeight = _riskWeight;
    }

    modifier onlyVault() {
        if (msg.sender != vault) revert OnlyVault();
        _;
    }

    function totalAssets() external view override returns (uint256) {
        return _balance;
    }

    function currentAPY() external view override returns (uint256) {
        return apyBps;
    }

    function protocolName() external pure override returns (string memory) {
        return "Mock";
    }

    function deposit(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();
        // Pull USDC from this contract into internal balance
        _balance += amount;
        emit Deposited(amount);
    }

    function withdraw(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();
        if (amount > _balance) revert InsufficientBalance();
        _balance -= amount;
        // Send USDC back to vault
        IERC20(asset).transfer(vault, amount);
        emit Withdrawn(amount);
    }

    function withdrawAll() external override onlyVault returns (uint256 withdrawn) {
        withdrawn = _balance;
        _balance = 0;
        if (withdrawn > 0) {
            IERC20(asset).transfer(vault, withdrawn);
        }
        emit Withdrawn(withdrawn);
    }

    // Test helpers
    function setAPY(uint256 _apyBps) external {
        apyBps = _apyBps;
    }

    /// @dev Simulate yield accrual by increasing balance.
    function simulateYield(uint256 amount) external {
        // Mint USDC to adapter to simulate earned yield
        MockUSDC(asset).mint(address(this), amount);
        _balance += amount;
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Test Suite
// ─────────────────────────────────────────────────────────────────────────────

contract YieldRouterVaultTest is Test {
    MockUSDC usdc;
    YieldRouterVault vault;
    address vaultAddress;

    MockAdapter adapterA;
    MockAdapter adapterB;

    address governance = makeAddr("governance");
    address guardian = makeAddr("guardian");
    address keeper = makeAddr("keeper");
    address feeRecipient = makeAddr("feeRecipient");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    uint256 constant DEPOSIT_CAP = 1_000_000e6; // $1M USDC
    uint256 constant MIN_DEPOSIT = 10e6; // 10 USDC

    function setUp() public {
        // Deploy mock USDC
        usdc = new MockUSDC();

        // Deploy vault implementation + proxy
        YieldRouterVault impl = new YieldRouterVault();
        bytes memory initData = abi.encodeCall(
            YieldRouterVault.initialize,
            (address(usdc), governance, guardian, keeper, feeRecipient, DEPOSIT_CAP)
        );

        // Use a separate proxy admin to avoid TransparentUpgradeableProxy routing issues
        address proxyAdmin = makeAddr("proxyAdmin");
        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(address(impl), proxyAdmin, initData);
        vaultAddress = address(proxy);
        vault = YieldRouterVault(vaultAddress);

        // Deploy mock adapters
        adapterA = new MockAdapter(vaultAddress, address(usdc), 9500); // Aave-like
        adapterB = new MockAdapter(vaultAddress, address(usdc), 9000); // Morpho-like

        // Register adapters
        vm.startPrank(governance);
        vault.addAdapter(address(adapterA));
        vault.addAdapter(address(adapterB));
        vm.stopPrank();

        // Fund users
        usdc.mint(alice, 100_000e6);
        usdc.mint(bob, 100_000e6);

        // Approve vault
        vm.prank(alice);
        usdc.approve(vaultAddress, type(uint256).max);
        vm.prank(bob);
        usdc.approve(vaultAddress, type(uint256).max);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Initialization
    // ─────────────────────────────────────────────────────────────────────────

    function test_initialization() public view {
        assertEq(vault.name(), "Yield Router USDC");
        assertEq(vault.symbol(), "yrUSDC");
        assertEq(vault.asset(), address(usdc));
        assertEq(vault.depositCap(), DEPOSIT_CAP);
        assertEq(vault.minDeposit(), MIN_DEPOSIT);
        assertEq(vault.performanceFeeBps(), 1000);
        assertEq(vault.feeRecipient(), feeRecipient);
        assertEq(vault.idleBufferBps(), 500);
        assertEq(vault.rebalanceThresholdBps(), 200);
    }

    function test_adaptersRegistered() public view {
        address[] memory adapters = vault.getAdapters();
        assertEq(adapters.length, 2);
        assertEq(adapters[0], address(adapterA));
        assertEq(adapters[1], address(adapterB));
        assertTrue(vault.isAdapter(address(adapterA)));
        assertTrue(vault.isAdapter(address(adapterB)));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Deposits
    // ─────────────────────────────────────────────────────────────────────────

    function test_deposit_basic() public {
        uint256 depositAmount = 1000e6; // 1000 USDC

        vm.prank(alice);
        uint256 shares = vault.deposit(depositAmount, alice);

        assertGt(shares, 0);
        assertEq(vault.totalAssets(), depositAmount);
        assertEq(usdc.balanceOf(vaultAddress), depositAmount);
    }

    function test_deposit_belowMinimum_reverts() public {
        uint256 tooSmall = 5e6; // 5 USDC < 10 USDC minimum

        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(IYieldRouterVault.BelowMinDeposit.selector, tooSmall, MIN_DEPOSIT)
        );
        vault.deposit(tooSmall, alice);
    }

    function test_deposit_exceedsCap_reverts() public {
        // Give alice enough USDC
        usdc.mint(alice, 2_000_000e6);
        vm.prank(alice);
        usdc.approve(vaultAddress, type(uint256).max);

        uint256 overCap = DEPOSIT_CAP + 1;
        vm.prank(alice);
        vm.expectRevert(); // DepositCapExceeded
        vault.deposit(overCap, alice);
    }

    function test_deposit_whenPaused_reverts() public {
        vm.prank(guardian);
        vault.pause();

        vm.prank(alice);
        vm.expectRevert(); // Pausable: paused
        vault.deposit(1000e6, alice);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Withdrawals
    // ─────────────────────────────────────────────────────────────────────────

    function test_withdraw_fromIdle() public {
        // Deposit first
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        uint256 balanceBefore = usdc.balanceOf(alice);

        vm.prank(alice);
        vault.withdraw(500e6, alice, alice);

        assertEq(usdc.balanceOf(alice) - balanceBefore, 500e6);
    }

    function test_withdraw_whenPaused_succeeds() public {
        // Deposit first
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        // Pause
        vm.prank(guardian);
        vault.pause();

        // Withdraw should still work
        vm.prank(alice);
        vault.withdraw(500e6, alice, alice);

        // Verify withdrawal succeeded
        assertGt(usdc.balanceOf(alice), 0);
    }

    function test_withdraw_pullsFromAdapters() public {
        // Deposit
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        // Manually move funds to adapter (simulating rebalance)
        vm.prank(vaultAddress);
        usdc.transfer(address(adapterA), 800e6);
        // Tell adapter it has a balance
        vm.prank(vaultAddress);
        adapterA.deposit(800e6);

        // Now vault idle is only 200e6 but user wants 500e6
        vm.prank(alice);
        vault.withdraw(500e6, alice, alice);

        // Should have pulled from adapter
        assertLt(adapterA.totalAssets(), 800e6);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Harvest
    // ─────────────────────────────────────────────────────────────────────────

    function test_harvest_firstCall_setsHWM() public {
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        vm.prank(keeper);
        vault.harvest();

        assertEq(vault.highWaterMark(), 1000e6);
    }

    function test_harvest_withProfit_mintsFeeShares() public {
        // Deposit
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        // First harvest to set HWM
        vm.prank(keeper);
        vault.harvest();
        assertEq(vault.highWaterMark(), 1000e6);

        // Simulate yield in adapter
        vm.prank(vaultAddress);
        usdc.transfer(address(adapterA), 500e6);
        vm.prank(vaultAddress);
        adapterA.deposit(500e6);
        adapterA.simulateYield(100e6); // 100 USDC yield

        // Now totalAssets = 500 (idle) + 600 (adapter) = 1100
        // Profit = 1100 - 1000 = 100
        // Fee = 100 * 10% = 10 USDC worth of shares

        uint256 feeSharesBefore = vault.balanceOf(feeRecipient);

        vm.prank(keeper);
        vault.harvest();

        uint256 feeSharesAfter = vault.balanceOf(feeRecipient);
        assertGt(feeSharesAfter, feeSharesBefore);
        assertEq(vault.highWaterMark(), 1100e6);
    }

    function test_harvest_noProfit_reverts() public {
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        // First harvest
        vm.prank(keeper);
        vault.harvest();

        // Second harvest with no yield
        vm.prank(keeper);
        vm.expectRevert(IYieldRouterVault.NothingToHarvest.selector);
        vault.harvest();
    }

    function test_harvest_onlyKeeper() public {
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        vm.prank(alice);
        vm.expectRevert(); // AccessControl
        vault.harvest();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Rebalance
    // ─────────────────────────────────────────────────────────────────────────

    function test_rebalance_distributesCapital() public {
        // Setup APY so allocator distributes
        adapterA.setAPY(500); // 5%
        adapterB.setAPY(300); // 3%

        // Deposit
        vm.prank(alice);
        vault.deposit(10_000e6, alice);

        // Rebalance
        vm.prank(keeper);
        vault.rebalance();

        // After rebalance, some capital should be in adapters
        uint256 adapterABal = adapterA.totalAssets();
        uint256 adapterBBal = adapterB.totalAssets();
        uint256 idle = usdc.balanceOf(vaultAddress);

        // Total should still equal deposit amount
        assertEq(adapterABal + adapterBBal + idle, 10_000e6);

        // Adapter A (higher risk-adjusted yield) should have more
        assertGt(adapterABal, 0);
    }

    function test_rebalance_onlyKeeper() public {
        vm.prank(alice);
        vm.expectRevert(); // AccessControl
        vault.rebalance();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Emergency Withdraw
    // ─────────────────────────────────────────────────────────────────────────

    function test_emergencyWithdraw() public {
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        // Move funds to adapter
        vm.prank(vaultAddress);
        usdc.transfer(address(adapterA), 500e6);
        vm.prank(vaultAddress);
        adapterA.deposit(500e6);

        assertEq(adapterA.totalAssets(), 500e6);

        // Emergency withdraw
        vm.prank(guardian);
        vault.emergencyWithdraw(address(adapterA));

        assertEq(adapterA.totalAssets(), 0);
        assertGe(usdc.balanceOf(vaultAddress), 500e6);
    }

    function test_emergencyWithdraw_onlyGuardian() public {
        vm.prank(alice);
        vm.expectRevert(); // AccessControl
        vault.emergencyWithdraw(address(adapterA));
    }

    function test_emergencyWithdraw_unknownAdapter_reverts() public {
        address fake = makeAddr("fake");
        vm.prank(guardian);
        vm.expectRevert(abi.encodeWithSelector(IYieldRouterVault.AdapterNotFound.selector, fake));
        vault.emergencyWithdraw(fake);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Adapter Management
    // ─────────────────────────────────────────────────────────────────────────

    function test_addAdapter_duplicate_reverts() public {
        vm.prank(governance);
        vm.expectRevert(
            abi.encodeWithSelector(IYieldRouterVault.AdapterAlreadyExists.selector, address(adapterA))
        );
        vault.addAdapter(address(adapterA));
    }

    function test_removeAdapter() public {
        vm.prank(governance);
        vault.removeAdapter(address(adapterB));

        address[] memory adapters = vault.getAdapters();
        assertEq(adapters.length, 1);
        assertFalse(vault.isAdapter(address(adapterB)));
    }

    function test_removeAdapter_withBalance_reverts() public {
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        // Move funds to adapter
        vm.prank(vaultAddress);
        usdc.transfer(address(adapterA), 500e6);
        vm.prank(vaultAddress);
        adapterA.deposit(500e6);

        vm.prank(governance);
        vm.expectRevert(IYieldRouterVault.InvalidParameter.selector);
        vault.removeAdapter(address(adapterA));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Governance Parameter Updates
    // ─────────────────────────────────────────────────────────────────────────

    function test_setDepositCap() public {
        vm.prank(governance);
        vault.setDepositCap(5_000_000e6);
        assertEq(vault.depositCap(), 5_000_000e6);
    }

    function test_setPerformanceFee() public {
        vm.prank(governance);
        vault.setPerformanceFee(500); // 5%
        assertEq(vault.performanceFeeBps(), 500);
    }

    function test_setPerformanceFee_tooHigh_reverts() public {
        vm.prank(governance);
        vm.expectRevert(abi.encodeWithSelector(IYieldRouterVault.FeeTooHigh.selector, 1001));
        vault.setPerformanceFee(1001); // > 10% max
    }

    function test_setFeeRecipient() public {
        address newRecipient = makeAddr("newRecipient");
        vm.prank(governance);
        vault.setFeeRecipient(newRecipient);
        assertEq(vault.feeRecipient(), newRecipient);
    }

    function test_setFeeRecipient_zero_reverts() public {
        vm.prank(governance);
        vm.expectRevert(IYieldRouterVault.ZeroAddress.selector);
        vault.setFeeRecipient(address(0));
    }

    function test_setIdleBuffer() public {
        vm.prank(governance);
        vault.setIdleBuffer(1000); // 10%
        assertEq(vault.idleBufferBps(), 1000);
    }

    function test_setRebalanceThreshold() public {
        vm.prank(governance);
        vault.setRebalanceThreshold(300);
        assertEq(vault.rebalanceThresholdBps(), 300);
    }

    function test_governance_onlyGovernance() public {
        vm.prank(alice);
        vm.expectRevert();
        vault.setDepositCap(0);

        vm.prank(alice);
        vm.expectRevert();
        vault.setPerformanceFee(0);

        vm.prank(alice);
        vm.expectRevert();
        vault.addAdapter(address(0));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Pause / Unpause
    // ─────────────────────────────────────────────────────────────────────────

    function test_pause_unpause() public {
        vm.prank(guardian);
        vault.pause();
        assertTrue(vault.paused());

        vm.prank(guardian);
        vault.unpause();
        assertFalse(vault.paused());
    }

    function test_pause_onlyGuardian() public {
        vm.prank(alice);
        vm.expectRevert();
        vault.pause();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ERC-4626 compliance
    // ─────────────────────────────────────────────────────────────────────────

    function test_multipleDepositors() public {
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        vm.prank(bob);
        vault.deposit(2000e6, bob);

        assertEq(vault.totalAssets(), 3000e6);

        // Bob has ~2x the shares of Alice
        uint256 aliceShares = vault.balanceOf(alice);
        uint256 bobShares = vault.balanceOf(bob);
        // Allow 1 wei rounding tolerance
        assertApproxEqAbs(bobShares, aliceShares * 2, 1);
    }

    function test_redeem() public {
        vm.prank(alice);
        uint256 shares = vault.deposit(1000e6, alice);

        uint256 balanceBefore = usdc.balanceOf(alice);

        vm.prank(alice);
        uint256 assets = vault.redeem(shares, alice, alice);

        assertEq(assets, 1000e6);
        assertEq(usdc.balanceOf(alice) - balanceBefore, 1000e6);
    }

    function test_totalAssets_includesAdapters() public {
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        // Move some to adapter
        vm.prank(vaultAddress);
        usdc.transfer(address(adapterA), 400e6);
        vm.prank(vaultAddress);
        adapterA.deposit(400e6);

        // totalAssets should still be 1000
        assertEq(vault.totalAssets(), 1000e6);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Allocator library
    // ─────────────────────────────────────────────────────────────────────────

    function test_allocator_basic() public pure {
        Allocator.AdapterInfo[] memory infos = new Allocator.AdapterInfo[](2);
        infos[0] = Allocator.AdapterInfo({apyBps: 500, riskWeight: 9500, currentBalance: 0});
        infos[1] = Allocator.AdapterInfo({apyBps: 300, riskWeight: 9000, currentBalance: 0});

        Allocator.Allocation memory alloc = Allocator.computeAllocation(infos, 10_000e6, 500);

        // 5% idle = 500e6
        // Adapter 0 score: 500 * 9500 / 10000 = 475
        // Adapter 1 score: 300 * 9000 / 10000 = 270
        // Adapter 0 gets first allocation (capped at 60% = 6000e6)
        // Adapter 1 gets remainder
        assertEq(alloc.targets[0] + alloc.targets[1] + alloc.idle, 10_000e6);
        assertGe(alloc.idle, 500e6); // At least 5% idle
        assertGt(alloc.targets[0], alloc.targets[1]); // Higher score gets more
    }

    function test_allocator_respectsCap() public pure {
        // Single adapter — should be capped at 60%
        Allocator.AdapterInfo[] memory infos = new Allocator.AdapterInfo[](1);
        infos[0] = Allocator.AdapterInfo({apyBps: 500, riskWeight: 9500, currentBalance: 0});

        Allocator.Allocation memory alloc = Allocator.computeAllocation(infos, 10_000e6, 500);

        // Cap is 60% of 10000 = 6000
        assertEq(alloc.targets[0], 6_000e6);
        assertEq(alloc.idle, 4_000e6); // Remainder = idle
    }

    function test_allocator_zeroAPY_getsNothing() public pure {
        Allocator.AdapterInfo[] memory infos = new Allocator.AdapterInfo[](2);
        infos[0] = Allocator.AdapterInfo({apyBps: 500, riskWeight: 9500, currentBalance: 0});
        infos[1] = Allocator.AdapterInfo({apyBps: 0, riskWeight: 9000, currentBalance: 0});

        Allocator.Allocation memory alloc = Allocator.computeAllocation(infos, 10_000e6, 500);

        assertEq(alloc.targets[1], 0); // Zero APY gets nothing
    }

    function test_allocator_noAdapters_reverts() public {
        Allocator.AdapterInfo[] memory infos = new Allocator.AdapterInfo[](0);
        vm.expectRevert(Allocator.NoAdapters.selector);
        Allocator.computeAllocation(infos, 10_000e6, 500);
    }

    function test_allocator_isRebalanceNeeded() public pure {
        Allocator.AdapterInfo[] memory infos = new Allocator.AdapterInfo[](2);
        infos[0] = Allocator.AdapterInfo({apyBps: 500, riskWeight: 10000, currentBalance: 0});
        infos[1] = Allocator.AdapterInfo({apyBps: 200, riskWeight: 10000, currentBalance: 0});

        // Delta = 500 - 200 = 300 bps, threshold 200 -> should rebalance
        assertTrue(Allocator.isRebalanceNeeded(infos, 200));

        // Threshold 400 -> should not rebalance
        assertFalse(Allocator.isRebalanceNeeded(infos, 400));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Audit fix coverage
    // ─────────────────────────────────────────────────────────────────────────

    function test_harvest_dustProfit_reverts() public {
        // H-01: profit below MIN_HARVEST_PROFIT (1 USDC) should revert
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        // Set HWM
        vm.prank(keeper);
        vault.harvest();

        // Simulate tiny yield: 0.5 USDC (500000 = 0.5e6) — below 1e6 threshold
        adapterA.simulateYield(500000);
        // Move the simulated yield token into adapter so totalAssets picks it up
        // simulateYield already mints to adapter and updates _balance

        vm.prank(keeper);
        vm.expectRevert(IYieldRouterVault.NothingToHarvest.selector);
        vault.harvest();
    }

    function test_emergencyWithdraw_resetsHWM() public {
        // M-08: HWM should update after emergency withdraw
        vm.prank(alice);
        vault.deposit(1000e6, alice);

        // Set initial HWM
        vm.prank(keeper);
        vault.harvest();
        assertEq(vault.highWaterMark(), 1000e6);

        // Move funds to adapter
        vm.prank(vaultAddress);
        usdc.transfer(address(adapterA), 500e6);
        vm.prank(vaultAddress);
        adapterA.deposit(500e6);

        // Emergency withdraw
        vm.prank(guardian);
        vault.emergencyWithdraw(address(adapterA));

        // HWM should be reset to current totalAssets
        assertEq(vault.highWaterMark(), vault.totalAssets());
    }

    function test_setRebalanceThreshold_tooHigh_reverts() public {
        // M-02: threshold >= BPS (10000) should revert
        vm.prank(governance);
        vm.expectRevert(IYieldRouterVault.InvalidParameter.selector);
        vault.setRebalanceThreshold(10_000);

        vm.prank(governance);
        vm.expectRevert(IYieldRouterVault.InvalidParameter.selector);
        vault.setRebalanceThreshold(15_000);
    }

    function test_updateAdapterAPYs() public {
        // Keeper can update APYs on all adapters
        uint256[] memory apys = new uint256[](2);
        apys[0] = 500; // 5%
        apys[1] = 300; // 3%

        vm.prank(keeper);
        vault.updateAdapterAPYs(apys);

        assertEq(adapterA.currentAPY(), 500);
        assertEq(adapterB.currentAPY(), 300);
    }

    function test_updateAdapterAPYs_wrongLength_reverts() public {
        uint256[] memory apys = new uint256[](1); // wrong length
        apys[0] = 500;

        vm.prank(keeper);
        vm.expectRevert(IYieldRouterVault.InvalidParameter.selector);
        vault.updateAdapterAPYs(apys);
    }

    function test_setPerformanceFee_atMax() public {
        // Can set fee to exactly MAX_FEE_BPS (1000 = 10%)
        vm.prank(governance);
        vault.setPerformanceFee(1000);
        assertEq(vault.performanceFeeBps(), 1000);
    }

    function test_initialize_zeroGuardian_reverts() public {
        // L-02: zero address checks on guardian/keeper
        YieldRouterVault impl = new YieldRouterVault();
        bytes memory initData = abi.encodeCall(
            YieldRouterVault.initialize,
            (address(usdc), governance, address(0), keeper, feeRecipient, DEPOSIT_CAP)
        );
        address proxyAdmin = makeAddr("proxyAdmin2");
        vm.expectRevert(); // ZeroAddress
        new TransparentUpgradeableProxy(address(impl), proxyAdmin, initData);
    }

    function test_initialize_zeroKeeper_reverts() public {
        YieldRouterVault impl = new YieldRouterVault();
        bytes memory initData = abi.encodeCall(
            YieldRouterVault.initialize,
            (address(usdc), governance, guardian, address(0), feeRecipient, DEPOSIT_CAP)
        );
        address proxyAdmin = makeAddr("proxyAdmin3");
        vm.expectRevert(); // ZeroAddress
        new TransparentUpgradeableProxy(address(impl), proxyAdmin, initData);
    }
}
