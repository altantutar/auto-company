// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {YieldRouterVault} from "../src/core/YieldRouterVault.sol";
import {IYieldRouterAdapter} from "../src/interfaces/IYieldRouterAdapter.sol";
import {MockAdapter} from "./MockAdapter.sol";

/// @title Keeper
/// @notice Foundry scripts for keeper operations on the Yield Router vault.
///
/// @dev This file contains three independent scripts:
///      - KeeperHarvest:    Calls harvest() on the vault.
///      - KeeperUpdateAPYs: Calls updateAdapterAPYs() with provided APY values.
///      - KeeperRebalance:  Calls rebalance() on the vault.
///
///   All scripts read the following environment variables:
///     KEEPER_PRIVATE_KEY  - keeper EOA private key
///     VAULT_PROXY         - vault proxy address
///
///   KeeperUpdateAPYs additionally reads:
///     ADAPTER_APYS        - comma-separated APY values in bps (e.g., "450,620,850")

// ──────────────────────────────────────────────────────────────────────────────
// Harvest
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Calls harvest() to accrue performance fees on any profit above the
///         high-water mark.
///
/// @dev Usage:
///   forge script script/Keeper.s.sol:KeeperHarvest \
///     --rpc-url $BASE_SEPOLIA_RPC \
///     --broadcast \
///     -vvvv
contract KeeperHarvest is Script {
    function run() external {
        uint256 keeperKey = vm.envUint("KEEPER_PRIVATE_KEY");
        address vaultProxy = vm.envAddress("VAULT_PROXY");

        YieldRouterVault vault = YieldRouterVault(vaultProxy);

        // Pre-flight: log current state
        uint256 totalAssets = vault.totalAssets();
        uint256 hwm = vault.highWaterMark();
        console2.log("=== Keeper: Harvest ===");
        console2.log("Vault:", vaultProxy);
        console2.log("Total Assets:", totalAssets);
        console2.log("High Water Mark:", hwm);

        if (hwm > 0 && totalAssets <= hwm) {
            console2.log("SKIP: No profit above HWM. Nothing to harvest.");
            return;
        }

        if (hwm > 0) {
            uint256 profit = totalAssets - hwm;
            console2.log("Profit:", profit);

            // MIN_HARVEST_PROFIT is 1e6 (1 USDC)
            if (profit < 1e6) {
                console2.log("SKIP: Profit below minimum threshold (1 USDC).");
                return;
            }
        } else {
            console2.log("First harvest: will set initial HWM.");
        }

        vm.startBroadcast(keeperKey);
        vault.harvest();
        vm.stopBroadcast();

        console2.log("Harvest executed successfully.");
        console2.log("New HWM:", vault.highWaterMark());
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// Update APYs
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Updates the cached APY values on all adapters via the vault's
///         updateAdapterAPYs() function.
///
/// @dev Usage:
///   ADAPTER_APYS="450,620,850" forge script script/Keeper.s.sol:KeeperUpdateAPYs \
///     --rpc-url $BASE_SEPOLIA_RPC \
///     --broadcast \
///     -vvvv
///
///   The ADAPTER_APYS string must have exactly N values (one per adapter),
///   in the same order as vault.getAdapters().
contract KeeperUpdateAPYs is Script {
    function run() external {
        uint256 keeperKey = vm.envUint("KEEPER_PRIVATE_KEY");
        address vaultProxy = vm.envAddress("VAULT_PROXY");
        string memory apyString = vm.envString("ADAPTER_APYS");

        YieldRouterVault vault = YieldRouterVault(vaultProxy);
        address[] memory adapters = vault.getAdapters();
        uint256 n = adapters.length;

        console2.log("=== Keeper: Update APYs ===");
        console2.log("Vault:", vaultProxy);
        console2.log("Adapter count:", n);
        console2.log("APY string:", apyString);

        // Parse comma-separated APY values
        uint256[] memory apys = _parseApys(apyString, n);

        // Log current vs new APYs
        for (uint256 i; i < n; ++i) {
            uint256 currentApy = IYieldRouterAdapter(adapters[i]).currentAPY();
            string memory adapterName = IYieldRouterAdapter(adapters[i]).protocolName();
            console2.log("  Adapter", adapterName);
            console2.log("    current APY (bps):", currentApy);
            console2.log("    new APY (bps):", apys[i]);
        }

        vm.startBroadcast(keeperKey);
        vault.updateAdapterAPYs(apys);
        vm.stopBroadcast();

        console2.log("APYs updated successfully.");
    }

    /// @dev Parse a comma-separated string of numbers into a uint256 array.
    ///      Example: "450,620,850" -> [450, 620, 850]
    function _parseApys(string memory s, uint256 expectedCount) internal pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](expectedCount);
        bytes memory b = bytes(s);
        uint256 idx;
        uint256 current;
        bool hasDigit;

        for (uint256 i; i < b.length; ++i) {
            if (b[i] == ",") {
                require(hasDigit, "Empty value in ADAPTER_APYS");
                require(idx < expectedCount, "Too many values in ADAPTER_APYS");
                result[idx] = current;
                ++idx;
                current = 0;
                hasDigit = false;
            } else {
                require(uint8(b[i]) >= 0x30 && uint8(b[i]) <= 0x39, "Non-numeric character in ADAPTER_APYS");
                current = current * 10 + (uint8(b[i]) - 0x30);
                hasDigit = true;
            }
        }

        // Last value (no trailing comma)
        if (hasDigit) {
            require(idx < expectedCount, "Too many values in ADAPTER_APYS");
            result[idx] = current;
            ++idx;
        }

        require(idx == expectedCount, "ADAPTER_APYS count does not match adapter count");
        return result;
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// Rebalance
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Calls rebalance() to redistribute capital across adapters based on
///         current risk-adjusted APYs.
///
/// @dev Usage:
///   forge script script/Keeper.s.sol:KeeperRebalance \
///     --rpc-url $BASE_SEPOLIA_RPC \
///     --broadcast \
///     -vvvv
contract KeeperRebalance is Script {
    function run() external {
        uint256 keeperKey = vm.envUint("KEEPER_PRIVATE_KEY");
        address vaultProxy = vm.envAddress("VAULT_PROXY");

        YieldRouterVault vault = YieldRouterVault(vaultProxy);
        address[] memory adapters = vault.getAdapters();
        uint256 n = adapters.length;

        console2.log("=== Keeper: Rebalance ===");
        console2.log("Vault:", vaultProxy);
        console2.log("Total Assets:", vault.totalAssets());

        if (n == 0) {
            console2.log("SKIP: No adapters registered.");
            return;
        }

        // Log pre-rebalance state
        console2.log("Pre-rebalance allocation:");
        for (uint256 i; i < n; ++i) {
            IYieldRouterAdapter adapter = IYieldRouterAdapter(adapters[i]);
            console2.log("  Adapter", adapter.protocolName());
            console2.log("    balance:", adapter.totalAssets());
            console2.log("    APY (bps):", adapter.currentAPY());
            console2.log("    riskWeight:", adapter.riskWeight());
        }

        vm.startBroadcast(keeperKey);
        vault.rebalance();
        vm.stopBroadcast();

        // Log post-rebalance state
        console2.log("Post-rebalance allocation:");
        for (uint256 i; i < n; ++i) {
            IYieldRouterAdapter adapter = IYieldRouterAdapter(adapters[i]);
            console2.log("  Adapter", adapter.protocolName());
            console2.log("    balance:", adapter.totalAssets());
        }

        console2.log("Rebalance executed successfully.");
        console2.log("New total assets:", vault.totalAssets());
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// SimulateYield (testnet only)
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Injects simulated yield into a mock adapter. Testnet only.
///
/// @dev Usage:
///   ADAPTER_INDEX=0 YIELD_AMOUNT=5000000 \
///   forge script script/Keeper.s.sol:KeeperSimulateYield \
///     --rpc-url $BASE_SEPOLIA_RPC \
///     --broadcast \
///     -vvvv
///
///   YIELD_AMOUNT is in raw USDC units (6 decimals). 5000000 = 5 USDC.
contract KeeperSimulateYield is Script {
    function run() external {
        uint256 keeperKey = vm.envUint("KEEPER_PRIVATE_KEY");
        address vaultProxy = vm.envAddress("VAULT_PROXY");
        uint256 adapterIndex = vm.envUint("ADAPTER_INDEX");
        uint256 yieldAmount = vm.envUint("YIELD_AMOUNT");

        YieldRouterVault vault = YieldRouterVault(vaultProxy);
        address[] memory adapters = vault.getAdapters();

        require(adapterIndex < adapters.length, "ADAPTER_INDEX out of bounds");

        MockAdapter adapter = MockAdapter(adapters[adapterIndex]);

        console2.log("=== Keeper: Simulate Yield ===");
        console2.log("Adapter:", adapters[adapterIndex]);
        console2.log("Protocol:", adapter.protocolName());
        console2.log("Balance before:", adapter.totalAssets());
        console2.log("Yield to inject:", yieldAmount);

        vm.startBroadcast(keeperKey);
        adapter.simulateYield(yieldAmount);
        vm.stopBroadcast();

        console2.log("Balance after:", adapter.totalAssets());
        console2.log("Yield injected successfully.");
    }
}
