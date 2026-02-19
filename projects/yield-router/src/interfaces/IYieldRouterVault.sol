// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IYieldRouterAdapter} from "./IYieldRouterAdapter.sol";

/// @title IYieldRouterVault
/// @notice Interface for the Yield Router ERC-4626 vault.
/// @dev Extends the standard ERC-4626 interface with yield routing, fee management,
///      and multi-protocol allocation capabilities.
interface IYieldRouterVault {
    // ──────────────────────────────────────────────────────────────────────────
    // Events
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Emitted when harvest() is called and performance fees are minted.
    event Harvested(uint256 totalAssets, uint256 profit, uint256 feeShares);

    /// @notice Emitted after a successful rebalance across adapters.
    event Rebalanced(uint256 totalAssets);

    /// @notice Emitted when an adapter is added to the vault.
    event AdapterAdded(address indexed adapter);

    /// @notice Emitted when an adapter is removed from the vault.
    event AdapterRemoved(address indexed adapter);

    /// @notice Emitted when the deposit cap is updated.
    event DepositCapUpdated(uint256 oldCap, uint256 newCap);

    /// @notice Emitted when the performance fee is updated.
    event PerformanceFeeUpdated(uint256 oldFee, uint256 newFee);

    /// @notice Emitted when the fee recipient is updated.
    event FeeRecipientUpdated(address oldRecipient, address newRecipient);

    /// @notice Emitted when the idle buffer target is updated.
    event IdleBufferUpdated(uint256 oldBuffer, uint256 newBuffer);

    /// @notice Emitted when the rebalance threshold is updated.
    event RebalanceThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);

    /// @notice Emitted on emergency withdrawal from a specific adapter.
    event EmergencyWithdrawal(address indexed adapter, uint256 amount);

    // ──────────────────────────────────────────────────────────────────────────
    // Errors
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Deposit amount is below the minimum.
    error BelowMinDeposit(uint256 amount, uint256 minDeposit);

    /// @notice Deposit would exceed the vault cap.
    error DepositCapExceeded(uint256 totalAfter, uint256 cap);

    /// @notice The adapter is already registered.
    error AdapterAlreadyExists(address adapter);

    /// @notice The adapter is not registered.
    error AdapterNotFound(address adapter);

    /// @notice Fee exceeds the maximum allowed (10%).
    error FeeTooHigh(uint256 fee);

    /// @notice Address is zero.
    error ZeroAddress();

    /// @notice Insufficient liquidity after pulling from adapters.
    error InsufficientLiquidity(uint256 requested, uint256 available);

    /// @notice No profit to harvest.
    error NothingToHarvest();

    /// @notice Adapter array is at max capacity.
    error TooManyAdapters();

    /// @notice Invalid parameter value.
    error InvalidParameter();

    // ──────────────────────────────────────────────────────────────────────────
    // Views
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Returns the list of active adapters.
    function getAdapters() external view returns (address[] memory);

    /// @notice Returns the current deposit cap in asset units.
    function depositCap() external view returns (uint256);

    /// @notice Returns the minimum deposit in asset units.
    function minDeposit() external view returns (uint256);

    /// @notice Returns the performance fee in basis points (e.g. 1000 = 10%).
    function performanceFeeBps() external view returns (uint256);

    /// @notice Returns the address that receives minted fee shares.
    function feeRecipient() external view returns (address);

    /// @notice Returns the high-water mark for fee calculation.
    function highWaterMark() external view returns (uint256);

    /// @notice Returns the idle buffer target in basis points.
    function idleBufferBps() external view returns (uint256);

    /// @notice Returns the rebalance threshold in basis points.
    function rebalanceThresholdBps() external view returns (uint256);

    // ──────────────────────────────────────────────────────────────────────────
    // Mutative — Keeper
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Harvest yield, accrue performance fees, and update the high-water mark.
    function harvest() external;

    /// @notice Update the cached APY values for all adapters.
    /// @param apyBps Array of APY values in basis points, one per adapter.
    function updateAdapterAPYs(uint256[] calldata apyBps) external;

    /// @notice Rebalance capital across adapters using the Allocator algorithm.
    function rebalance() external;

    // ──────────────────────────────────────────────────────────────────────────
    // Mutative — Governance
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Add a new adapter to the vault.
    function addAdapter(address adapter) external;

    /// @notice Remove an adapter from the vault (must have zero balance).
    function removeAdapter(address adapter) external;

    /// @notice Update the deposit cap.
    function setDepositCap(uint256 newCap) external;

    /// @notice Update the performance fee (max 10%).
    function setPerformanceFee(uint256 newFeeBps) external;

    /// @notice Update the fee recipient.
    function setFeeRecipient(address newRecipient) external;

    /// @notice Update the idle buffer target.
    function setIdleBuffer(uint256 newBufferBps) external;

    /// @notice Update the rebalance threshold.
    function setRebalanceThreshold(uint256 newThresholdBps) external;

    // ──────────────────────────────────────────────────────────────────────────
    // Mutative — Guardian
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Pause deposits (withdrawals remain active).
    function pause() external;

    /// @notice Unpause deposits.
    function unpause() external;

    /// @notice Emergency withdraw all assets from a specific adapter.
    function emergencyWithdraw(address adapter) external;
}
