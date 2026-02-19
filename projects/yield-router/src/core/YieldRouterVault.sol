// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC4626Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IYieldRouterVault} from "../interfaces/IYieldRouterVault.sol";
import {IYieldRouterAdapter} from "../interfaces/IYieldRouterAdapter.sol";
import {Allocator} from "./Allocator.sol";

/// @title YieldRouterVault
/// @notice Base-native ERC-4626 vault that auto-optimises USDC yield across Morpho Blue,
///         Aave V3, and Aerodrome stable LPs. Shares are denominated as yrUSDC.
///
/// @dev Architecture notes:
///      - Upgradeable via TransparentUpgradeableProxy (OZ pattern).
///      - Role-based access: GOVERNANCE_ROLE, GUARDIAN_ROLE, KEEPER_ROLE.
///      - Deposits can be paused; withdrawals NEVER pause.
///      - Virtual shares pattern (1e6 offset) to prevent inflation attacks.
///      - High-water mark performance fee accrual on harvest().
///      - 10% performance fee (configurable, max 10%).
///      - Allocation via pure Allocator library.
///      - Minimum deposit: 10 USDC.  Deposit cap: configurable (Phase 1: $1M).
contract YieldRouterVault is
    Initializable,
    ERC4626Upgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    IYieldRouterVault
{
    using SafeERC20 for IERC20;
    using Math for uint256;

    // ──────────────────────────────────────────────────────────────────────────
    // Constants
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Role for governance actions (add/remove adapters, set params).
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    /// @notice Role for guardian actions (pause, emergency withdraw).
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    /// @notice Role for keeper actions (harvest, rebalance).
    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");

    /// @notice Maximum performance fee: 10% (1000 bps).
    uint256 public constant MAX_FEE_BPS = 1000;

    /// @notice Maximum number of adapters.
    uint256 public constant MAX_ADAPTERS = 10;

    /// @notice Basis points denominator.
    uint256 internal constant BPS = 10_000;

    /// @notice Virtual share offset for inflation attack protection (1e6 for USDC 6 decimals).
    uint256 internal constant VIRTUAL_OFFSET = 1e6;

    /// @notice Minimum profit (in asset units) required for harvest to execute.
    /// @dev Prevents dust/donation griefing attacks. 1 USDC minimum.
    uint256 internal constant MIN_HARVEST_PROFIT = 1e6;

    // ──────────────────────────────────────────────────────────────────────────
    // Storage (upgradeable — careful with slot ordering)
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Active adapters list.
    address[] internal _adapters;

    /// @notice Quick lookup: adapter address -> is active.
    mapping(address => bool) public isAdapter;

    /// @inheritdoc IYieldRouterVault
    uint256 public depositCap;

    /// @inheritdoc IYieldRouterVault
    uint256 public minDeposit;

    /// @inheritdoc IYieldRouterVault
    uint256 public performanceFeeBps;

    /// @inheritdoc IYieldRouterVault
    address public feeRecipient;

    /// @inheritdoc IYieldRouterVault
    uint256 public highWaterMark;

    /// @inheritdoc IYieldRouterVault
    uint256 public idleBufferBps;

    /// @inheritdoc IYieldRouterVault
    uint256 public rebalanceThresholdBps;

    /// @dev Gap for future storage slots.
    uint256[40] private __gap;

    // ──────────────────────────────────────────────────────────────────────────
    // Initializer
    // ──────────────────────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialise the vault (called once via proxy).
    /// @param _asset         USDC address.
    /// @param _governance    Address receiving GOVERNANCE_ROLE (timelock).
    /// @param _guardian      Address receiving GUARDIAN_ROLE (multisig).
    /// @param _keeper        Address receiving KEEPER_ROLE.
    /// @param _feeRecipient  Address receiving minted fee shares.
    /// @param _depositCap    Initial deposit cap in USDC (6 decimals).
    function initialize(
        address _asset,
        address _governance,
        address _guardian,
        address _keeper,
        address _feeRecipient,
        uint256 _depositCap
    ) external initializer {
        if (_asset == address(0)) revert ZeroAddress();
        if (_governance == address(0)) revert ZeroAddress();
        if (_guardian == address(0)) revert ZeroAddress();
        if (_keeper == address(0)) revert ZeroAddress();
        if (_feeRecipient == address(0)) revert ZeroAddress();

        __ERC4626_init(IERC20(_asset));
        __ERC20_init("Yield Router USDC", "yrUSDC");
        __Pausable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _governance);
        _grantRole(GOVERNANCE_ROLE, _governance);
        _grantRole(GUARDIAN_ROLE, _guardian);
        _grantRole(KEEPER_ROLE, _keeper);

        feeRecipient = _feeRecipient;
        depositCap = _depositCap;
        minDeposit = 10e6; // 10 USDC
        performanceFeeBps = 1000; // 10%
        idleBufferBps = 500; // 5%
        rebalanceThresholdBps = 200; // 2%

        // Initialise HWM to 0; first harvest sets it.
        highWaterMark = 0;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // ERC-4626 overrides
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Total assets = idle USDC in vault + sum of all adapter balances.
    function totalAssets() public view override returns (uint256 total) {
        total = IERC20(asset()).balanceOf(address(this));
        uint256 len = _adapters.length;
        for (uint256 i; i < len; ++i) {
            total += IYieldRouterAdapter(_adapters[i]).totalAssets();
        }
    }

    /// @dev Virtual shares offset to prevent inflation attacks on USDC (6 decimals).
    function _decimalsOffset() internal pure override returns (uint8) {
        return 6;
    }

    /// @dev Enforce min deposit and deposit cap. Deposits are pausable.
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares)
        internal
        override
        whenNotPaused
        nonReentrant
    {
        if (assets < minDeposit) revert BelowMinDeposit(assets, minDeposit);

        uint256 totalAfter = totalAssets() + assets;
        if (totalAfter > depositCap) revert DepositCapExceeded(totalAfter, depositCap);

        super._deposit(caller, receiver, assets, shares);
    }

    /// @dev Withdrawals are NEVER paused — no whenNotPaused modifier.
    function _withdraw(address caller, address owner, address receiver, uint256 assets, uint256 shares)
        internal
        override
        nonReentrant
    {
        // If idle balance is insufficient, pull from adapters
        uint256 idle = IERC20(asset()).balanceOf(address(this));
        if (idle < assets) {
            _pullFromAdapters(assets - idle);
        }

        // H-02: verify we actually received enough liquidity
        uint256 available = IERC20(asset()).balanceOf(address(this));
        if (available < assets) revert InsufficientLiquidity(assets, available);

        super._withdraw(caller, owner, receiver, assets, shares);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Keeper functions
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterVault
    function harvest() external onlyRole(KEEPER_ROLE) nonReentrant {
        uint256 total = totalAssets();
        uint256 hwm = highWaterMark;

        // On first harvest, just set HWM
        if (hwm == 0) {
            highWaterMark = total;
            emit Harvested(total, 0, 0);
            return;
        }

        if (total <= hwm) revert NothingToHarvest();

        uint256 profit = total - hwm;
        if (profit < MIN_HARVEST_PROFIT) revert NothingToHarvest();
        uint256 feeAssets = (profit * performanceFeeBps) / BPS;

        // Mint fee shares to feeRecipient
        // feeShares = feeAssets * totalSupply / (totalAssets - feeAssets)
        // This dilutes existing holders proportionally to the fee.
        uint256 supply = totalSupply();
        uint256 feeShares;
        if (supply == 0 || total == feeAssets) {
            feeShares = feeAssets; // Edge case: should not happen in practice
        } else {
            feeShares = feeAssets.mulDiv(supply, total - feeAssets, Math.Rounding.Floor);
        }

        if (feeShares > 0) {
            _mint(feeRecipient, feeShares);
        }

        highWaterMark = total;

        emit Harvested(total, profit, feeShares);
    }

    /// @inheritdoc IYieldRouterVault
    function updateAdapterAPYs(uint256[] calldata apyBps) external onlyRole(KEEPER_ROLE) {
        uint256 n = _adapters.length;
        if (apyBps.length != n) revert InvalidParameter();
        for (uint256 i; i < n; ++i) {
            IYieldRouterAdapter(_adapters[i]).setAPY(apyBps[i]);
        }
    }

    /// @inheritdoc IYieldRouterVault
    function rebalance() external onlyRole(KEEPER_ROLE) nonReentrant {
        uint256 n = _adapters.length;
        if (n == 0) return;

        uint256 total = totalAssets();

        // Build adapter info array
        Allocator.AdapterInfo[] memory infos = new Allocator.AdapterInfo[](n);
        for (uint256 i; i < n; ++i) {
            IYieldRouterAdapter adapter = IYieldRouterAdapter(_adapters[i]);
            infos[i] = Allocator.AdapterInfo({
                apyBps: adapter.currentAPY(),
                riskWeight: adapter.riskWeight(),
                currentBalance: adapter.totalAssets()
            });
        }

        // Compute target allocation
        Allocator.Allocation memory alloc = Allocator.computeAllocation(infos, total, idleBufferBps);

        // Execute rebalance: withdraw from over-allocated, deposit to under-allocated
        // Phase 1: withdraw all excess first, then deposit
        for (uint256 i; i < n; ++i) {
            uint256 current = infos[i].currentBalance;
            uint256 target = alloc.targets[i];
            if (current > target) {
                uint256 excess = current - target;
                IYieldRouterAdapter(_adapters[i]).withdraw(excess);
            }
        }

        for (uint256 i; i < n; ++i) {
            uint256 current = infos[i].currentBalance;
            uint256 target = alloc.targets[i];
            if (target > current) {
                uint256 deficit = target - current;
                uint256 idle = IERC20(asset()).balanceOf(address(this));
                uint256 toDeposit = deficit < idle ? deficit : idle;
                if (toDeposit > 0) {
                    IERC20(asset()).safeTransfer(_adapters[i], toDeposit);
                    IYieldRouterAdapter(_adapters[i]).deposit(toDeposit);
                }
            }
        }

        emit Rebalanced(totalAssets());
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Governance functions
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterVault
    function addAdapter(address adapter) external onlyRole(GOVERNANCE_ROLE) nonReentrant {
        if (adapter == address(0)) revert ZeroAddress();
        if (isAdapter[adapter]) revert AdapterAlreadyExists(adapter);
        if (_adapters.length >= MAX_ADAPTERS) revert TooManyAdapters();

        // Verify the adapter points to this vault
        if (IYieldRouterAdapter(adapter).vault() != address(this)) revert InvalidParameter();
        if (IYieldRouterAdapter(adapter).asset() != asset()) revert InvalidParameter();

        _adapters.push(adapter);
        isAdapter[adapter] = true;

        emit AdapterAdded(adapter);
    }

    /// @inheritdoc IYieldRouterVault
    function removeAdapter(address adapter) external onlyRole(GOVERNANCE_ROLE) nonReentrant {
        if (!isAdapter[adapter]) revert AdapterNotFound(adapter);
        if (IYieldRouterAdapter(adapter).totalAssets() > 0) revert InvalidParameter();

        // Remove from array (swap-and-pop)
        uint256 len = _adapters.length;
        for (uint256 i; i < len; ++i) {
            if (_adapters[i] == adapter) {
                _adapters[i] = _adapters[len - 1];
                _adapters.pop();
                break;
            }
        }
        isAdapter[adapter] = false;

        emit AdapterRemoved(adapter);
    }

    /// @inheritdoc IYieldRouterVault
    function setDepositCap(uint256 newCap) external onlyRole(GOVERNANCE_ROLE) {
        uint256 oldCap = depositCap;
        depositCap = newCap;
        emit DepositCapUpdated(oldCap, newCap);
    }

    /// @inheritdoc IYieldRouterVault
    function setPerformanceFee(uint256 newFeeBps) external onlyRole(GOVERNANCE_ROLE) {
        if (newFeeBps > MAX_FEE_BPS) revert FeeTooHigh(newFeeBps);
        uint256 oldFee = performanceFeeBps;
        performanceFeeBps = newFeeBps;
        emit PerformanceFeeUpdated(oldFee, newFeeBps);
    }

    /// @inheritdoc IYieldRouterVault
    function setFeeRecipient(address newRecipient) external onlyRole(GOVERNANCE_ROLE) {
        if (newRecipient == address(0)) revert ZeroAddress();
        address oldRecipient = feeRecipient;
        feeRecipient = newRecipient;
        emit FeeRecipientUpdated(oldRecipient, newRecipient);
    }

    /// @inheritdoc IYieldRouterVault
    function setIdleBuffer(uint256 newBufferBps) external onlyRole(GOVERNANCE_ROLE) {
        if (newBufferBps >= BPS) revert InvalidParameter();
        uint256 oldBuffer = idleBufferBps;
        idleBufferBps = newBufferBps;
        emit IdleBufferUpdated(oldBuffer, newBufferBps);
    }

    /// @inheritdoc IYieldRouterVault
    function setRebalanceThreshold(uint256 newThresholdBps) external onlyRole(GOVERNANCE_ROLE) {
        if (newThresholdBps >= BPS) revert InvalidParameter();
        uint256 oldThreshold = rebalanceThresholdBps;
        rebalanceThresholdBps = newThresholdBps;
        emit RebalanceThresholdUpdated(oldThreshold, newThresholdBps);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Guardian functions
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterVault
    function pause() external onlyRole(GUARDIAN_ROLE) {
        _pause();
    }

    /// @inheritdoc IYieldRouterVault
    function unpause() external onlyRole(GUARDIAN_ROLE) {
        _unpause();
    }

    /// @inheritdoc IYieldRouterVault
    function emergencyWithdraw(address adapter) external onlyRole(GUARDIAN_ROLE) nonReentrant {
        if (!isAdapter[adapter]) revert AdapterNotFound(adapter);
        uint256 withdrawn = IYieldRouterAdapter(adapter).withdrawAll();
        // M-08: reset HWM to prevent phantom profit fee on recovered assets
        highWaterMark = totalAssets();
        emit EmergencyWithdrawal(adapter, withdrawn);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // View helpers
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterVault
    function getAdapters() external view returns (address[] memory) {
        return _adapters;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Internal helpers
    // ──────────────────────────────────────────────────────────────────────────

    /// @dev Pull assets from adapters to cover a withdrawal deficit.
    ///      Pulls proportionally from each adapter.
    function _pullFromAdapters(uint256 deficit) internal {
        uint256 n = _adapters.length;
        if (n == 0) return;

        // Calculate total deployed across all adapters
        uint256 totalDeployed;
        uint256[] memory balances = new uint256[](n);
        for (uint256 i; i < n; ++i) {
            balances[i] = IYieldRouterAdapter(_adapters[i]).totalAssets();
            totalDeployed += balances[i];
        }

        if (totalDeployed == 0) return;

        uint256 remaining = deficit;
        for (uint256 i; i < n; ++i) {
            if (remaining == 0) break;
            if (balances[i] == 0) continue;

            // Pull proportionally, but cap at adapter balance
            uint256 pull = (deficit * balances[i]) / totalDeployed;
            if (pull > balances[i]) pull = balances[i];
            if (pull > remaining) pull = remaining;
            if (pull == 0) continue;

            IYieldRouterAdapter(_adapters[i]).withdraw(pull);
            remaining -= pull;
        }

        // If still short (due to rounding), pull from first adapter with balance
        if (remaining > 0) {
            for (uint256 i; i < n; ++i) {
                uint256 avail = IYieldRouterAdapter(_adapters[i]).totalAssets();
                if (avail == 0) continue;
                uint256 pull = remaining < avail ? remaining : avail;
                IYieldRouterAdapter(_adapters[i]).withdraw(pull);
                remaining -= pull;
                if (remaining == 0) break;
            }
        }
    }
}
