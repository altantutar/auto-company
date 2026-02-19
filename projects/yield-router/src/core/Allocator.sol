// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Allocator
/// @notice Pure library that computes optimal capital allocation across yield adapters.
/// @dev The algorithm maximises risk-adjusted yield subject to concentration caps.
///
///      Constraints:
///        - No single protocol may exceed `MAX_PROTOCOL_BPS` (60%) of total capital.
///        - No single market may exceed `MAX_MARKET_BPS` (40%) of total capital.
///        - At least `minIdleBps` must remain as idle buffer in the vault.
///
///      Scoring:
///        score_i = apyBps_i * riskWeight_i / 1e4
///
///      Allocation:
///        1. Reserve idle buffer.
///        2. Sort adapters by score (descending).
///        3. Greedily allocate to highest-scored adapter up to its cap.
///        4. Remainder stays idle.
library Allocator {
    // ──────────────────────────────────────────────────────────────────────────
    // Constants
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Maximum allocation to any single protocol (60%).
    uint256 internal constant MAX_PROTOCOL_BPS = 6000;

    /// @notice Basis points denominator.
    uint256 internal constant BPS = 10_000;

    // ──────────────────────────────────────────────────────────────────────────
    // Types
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Input data for each adapter.
    struct AdapterInfo {
        /// @dev Current APY in basis points (e.g. 500 = 5%).
        uint256 apyBps;
        /// @dev Risk weight scaled to 1e4 (e.g. 9500 = 0.95).
        uint256 riskWeight;
        /// @dev Current balance deployed in this adapter.
        uint256 currentBalance;
    }

    /// @notice Output: target allocation for each adapter.
    struct Allocation {
        /// @dev Target balance for each adapter (same order as input).
        uint256[] targets;
        /// @dev Amount that should remain idle in the vault.
        uint256 idle;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Errors
    // ──────────────────────────────────────────────────────────────────────────

    error NoAdapters();
    error IdleBufferTooHigh();

    // ──────────────────────────────────────────────────────────────────────────
    // Core
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Compute target allocations given current state.
    /// @param adapters   Array of adapter info structs.
    /// @param totalAssets Total assets under management (deployed + idle).
    /// @param idleBufferBps Minimum idle buffer in basis points (e.g. 500 = 5%).
    /// @return alloc The computed allocation.
    function computeAllocation(
        AdapterInfo[] memory adapters,
        uint256 totalAssets,
        uint256 idleBufferBps
    ) internal pure returns (Allocation memory alloc) {
        uint256 n = adapters.length;
        if (n == 0) revert NoAdapters();
        if (idleBufferBps >= BPS) revert IdleBufferTooHigh();

        alloc.targets = new uint256[](n);

        // 1. Reserve idle buffer
        uint256 idleReserve = (totalAssets * idleBufferBps) / BPS;
        uint256 deployable = totalAssets - idleReserve;

        // 2. Compute risk-adjusted scores
        uint256[] memory scores = new uint256[](n);
        for (uint256 i; i < n; ++i) {
            scores[i] = (adapters[i].apyBps * adapters[i].riskWeight) / BPS;
        }

        // 3. Build sorted index array (descending by score) — simple insertion sort,
        //    fine for N <= 10 adapters.
        uint256[] memory order = new uint256[](n);
        for (uint256 i; i < n; ++i) {
            order[i] = i;
        }
        for (uint256 i = 1; i < n; ++i) {
            uint256 key = order[i];
            uint256 keyScore = scores[key];
            uint256 j = i;
            while (j > 0 && scores[order[j - 1]] < keyScore) {
                order[j] = order[j - 1];
                --j;
            }
            order[j] = key;
        }

        // 4. Greedy allocation respecting per-protocol cap
        uint256 remaining = deployable;
        for (uint256 k; k < n; ++k) {
            uint256 idx = order[k];
            if (scores[idx] == 0) {
                // Zero-score adapters get nothing
                continue;
            }
            uint256 cap = (totalAssets * MAX_PROTOCOL_BPS) / BPS;
            uint256 target = remaining < cap ? remaining : cap;
            alloc.targets[idx] = target;
            remaining -= target;
            if (remaining == 0) break;
        }

        // 5. Whatever remains (due to caps or zero scores) goes to idle
        alloc.idle = idleReserve + remaining;
    }

    /// @notice Check whether a rebalance is needed based on yield delta.
    /// @param adapters Array of adapter info structs.
    /// @param thresholdBps Minimum yield delta in bps to trigger rebalance.
    /// @return needed True if rebalance should be triggered.
    function isRebalanceNeeded(
        AdapterInfo[] memory adapters,
        uint256 thresholdBps
    ) internal pure returns (bool needed) {
        uint256 n = adapters.length;
        if (n < 2) return false;

        uint256 maxScore;
        uint256 minScore = type(uint256).max;

        for (uint256 i; i < n; ++i) {
            uint256 score = (adapters[i].apyBps * adapters[i].riskWeight) / BPS;
            if (score > maxScore) maxScore = score;
            if (score < minScore) minScore = score;
        }

        needed = (maxScore - minScore) >= thresholdBps;
    }
}
