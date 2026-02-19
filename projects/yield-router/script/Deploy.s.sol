// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {TransparentUpgradeableProxy} from
    "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {YieldRouterVault} from "../src/core/YieldRouterVault.sol";
import {MockUSDC, MockAdapter} from "./MockAdapter.sol";

/// @title Deploy
/// @notice Full deployment script for the Yield Router on Base Sepolia testnet.
///
/// @dev Deploys in this order:
///      1. MockUSDC (mintable test token)
///      2. YieldRouterVault implementation
///      3. TransparentUpgradeableProxy -> vault impl + initialize()
///      4. Three MockAdapters (simulating Aave, Morpho, Aerodrome)
///      5. Registers all adapters in the vault
///      6. Sets initial APYs on adapters via updateAdapterAPYs()
///      7. Mints test USDC to the deployer for smoke testing
///
///   Usage:
///     forge script script/Deploy.s.sol:Deploy \
///       --rpc-url $BASE_SEPOLIA_RPC \
///       --broadcast \
///       --verify \
///       --verifier-url https://api-sepolia.basescan.org/api \
///       --etherscan-api-key $BASESCAN_API_KEY \
///       -vvvv
///
///   Required environment variables:
///     DEPLOYER_PRIVATE_KEY  - deployer EOA private key
///     GOVERNANCE_ADDRESS    - governance address (EOA for testnet)
///     GUARDIAN_ADDRESS      - guardian address (EOA for testnet)
///     KEEPER_ADDRESS        - keeper bot address
///     FEE_RECIPIENT         - address receiving fee shares
///
///   Optional environment variables:
///     DEPOSIT_CAP           - deposit cap in full USDC units (default: 1000000)
///     INITIAL_MINT          - USDC to mint to deployer (default: 10000000 = 10M)
contract Deploy is Script {
    // ── Testnet parameters ────────────────────────────────────────────────────
    uint256 constant DEFAULT_DEPOSIT_CAP = 1_000_000e6; // $1M in USDC (6 decimals)
    uint256 constant DEFAULT_INITIAL_MINT = 10_000_000e6; // 10M USDC for testing

    // ── Mock adapter risk weights (matching production adapters) ──────────────
    uint256 constant AAVE_RISK_WEIGHT = 9500; // 0.95
    uint256 constant MORPHO_RISK_WEIGHT = 9000; // 0.90
    uint256 constant AERODROME_RISK_WEIGHT = 8000; // 0.80

    // ── Initial APYs (in bps) for testnet ─────────────────────────────────────
    uint256 constant AAVE_INITIAL_APY = 450; // 4.5%
    uint256 constant MORPHO_INITIAL_APY = 620; // 6.2%
    uint256 constant AERODROME_INITIAL_APY = 850; // 8.5%

    function run() external {
        // ── Read environment ──────────────────────────────────────────────────
        uint256 deployerKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        address governance = vm.envAddress("GOVERNANCE_ADDRESS");
        address guardian = vm.envAddress("GUARDIAN_ADDRESS");
        address keeper = vm.envAddress("KEEPER_ADDRESS");
        address feeRecipient = vm.envAddress("FEE_RECIPIENT");

        uint256 depositCap = vm.envOr("DEPOSIT_CAP", DEFAULT_DEPOSIT_CAP);
        uint256 initialMint = vm.envOr("INITIAL_MINT", DEFAULT_INITIAL_MINT);

        console2.log("=== Yield Router Testnet Deployment ===");
        console2.log("Chain ID:", block.chainid);
        console2.log("Deployer:", deployer);
        console2.log("Governance:", governance);
        console2.log("Guardian:", guardian);
        console2.log("Keeper:", keeper);
        console2.log("Fee Recipient:", feeRecipient);
        console2.log("Deposit Cap:", depositCap);
        console2.log("");

        vm.startBroadcast(deployerKey);

        // ── Step 1: Deploy MockUSDC ───────────────────────────────────────────
        MockUSDC usdc = new MockUSDC();
        console2.log("[1/7] MockUSDC deployed:", address(usdc));

        // ── Step 2: Deploy vault implementation ───────────────────────────────
        YieldRouterVault vaultImpl = new YieldRouterVault();
        console2.log("[2/7] Vault implementation:", address(vaultImpl));

        // ── Step 3: Deploy proxy with initialize() ────────────────────────────
        bytes memory initData = abi.encodeCall(
            YieldRouterVault.initialize,
            (address(usdc), governance, guardian, keeper, feeRecipient, depositCap)
        );

        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(address(vaultImpl), governance, initData);

        address vaultProxy = address(proxy);
        console2.log("[3/7] Vault proxy (yrUSDC):", vaultProxy);

        // ── Step 4: Deploy mock adapters ──────────────────────────────────────
        // All adapters point to the vault proxy address and use the keeper as
        // the owner for testnet convenience (keeper can call simulateYield).
        MockAdapter aaveAdapter =
            new MockAdapter(vaultProxy, address(usdc), AAVE_RISK_WEIGHT, "MockAaveV3", keeper);
        console2.log("[4/7] Mock Aave adapter:", address(aaveAdapter));

        MockAdapter morphoAdapter =
            new MockAdapter(vaultProxy, address(usdc), MORPHO_RISK_WEIGHT, "MockMorphoBlue", keeper);
        console2.log("[5/7] Mock Morpho adapter:", address(morphoAdapter));

        MockAdapter aerodromeAdapter =
            new MockAdapter(vaultProxy, address(usdc), AERODROME_RISK_WEIGHT, "MockAerodrome", keeper);
        console2.log("[6/7] Mock Aerodrome adapter:", address(aerodromeAdapter));

        // ── Step 5: Register adapters in vault ────────────────────────────────
        // The deployer is NOT governance, so we need to prank governance.
        // In the deploy script with broadcast, the deployer signs all txs.
        // Since initialize() grants GOVERNANCE_ROLE to the governance address,
        // these calls must come from governance.
        //
        // For testnet: if deployer == governance, this works directly.
        // If deployer != governance, governance must call addAdapter separately.
        //
        // To handle both cases, we check if the deployer has the governance role.
        YieldRouterVault vault = YieldRouterVault(vaultProxy);

        // If deployer is governance, register directly. Otherwise, log instructions.
        if (deployer == governance) {
            vault.addAdapter(address(aaveAdapter));
            vault.addAdapter(address(morphoAdapter));
            vault.addAdapter(address(aerodromeAdapter));
            console2.log("[7/7] All 3 adapters registered in vault");

            // ── Step 6: Set initial APYs ──────────────────────────────────────
            // updateAdapterAPYs requires KEEPER_ROLE. If deployer == keeper, call directly.
            // Otherwise, the keeper must call this post-deployment.
            if (deployer == keeper) {
                uint256[] memory apys = new uint256[](3);
                apys[0] = AAVE_INITIAL_APY;
                apys[1] = MORPHO_INITIAL_APY;
                apys[2] = AERODROME_INITIAL_APY;
                vault.updateAdapterAPYs(apys);
                console2.log("      Initial APYs set: Aave=%d, Morpho=%d, Aero=%d", AAVE_INITIAL_APY, MORPHO_INITIAL_APY, AERODROME_INITIAL_APY);
            } else {
                console2.log("      NOTE: Keeper must call updateAdapterAPYs() post-deployment");
                console2.log("      Keeper address:", keeper);
            }
        } else {
            console2.log("[7/7] MANUAL STEP REQUIRED: Governance must register adapters");
            console2.log("      Run the following from the governance address:");
            console2.log("      vault.addAdapter(%s)", address(aaveAdapter));
            console2.log("      vault.addAdapter(%s)", address(morphoAdapter));
            console2.log("      vault.addAdapter(%s)", address(aerodromeAdapter));
        }

        // ── Step 7: Mint test USDC ────────────────────────────────────────────
        usdc.mint(deployer, initialMint);
        console2.log("      Minted %d USDC to deployer", initialMint);

        // Also mint to governance, guardian, and keeper for testing
        usdc.mint(governance, 1_000_000e6);
        usdc.mint(guardian, 1_000_000e6);
        usdc.mint(keeper, 1_000_000e6);
        console2.log("      Minted 1M USDC each to governance, guardian, keeper");

        vm.stopBroadcast();

        // ── Summary ───────────────────────────────────────────────────────────
        console2.log("");
        console2.log("=== DEPLOYMENT COMPLETE ===");
        console2.log("Chain ID:            ", block.chainid);
        console2.log("MockUSDC:            ", address(usdc));
        console2.log("Vault Implementation:", address(vaultImpl));
        console2.log("Vault Proxy (yrUSDC):", vaultProxy);
        console2.log("Mock Aave Adapter:   ", address(aaveAdapter));
        console2.log("Mock Morpho Adapter: ", address(morphoAdapter));
        console2.log("Mock Aero Adapter:   ", address(aerodromeAdapter));
        console2.log("");
        console2.log("Save these addresses to deployments/base-sepolia.json");
    }
}
