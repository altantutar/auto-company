// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IYieldRouterAdapter
/// @notice Interface for protocol adapters that the YieldRouterVault uses to deploy capital.
/// @dev Each adapter wraps a single DeFi protocol and exposes a uniform interface for
///      deposit, withdrawal, balance queries, and APY reporting. Adapters are immutable
///      contracts that hold no user funds directly — they operate on behalf of the vault.
interface IYieldRouterAdapter {
    // ──────────────────────────────────────────────────────────────────────────
    // Events
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Emitted when the adapter deposits assets into the underlying protocol.
    event Deposited(uint256 amount);

    /// @notice Emitted when the adapter withdraws assets from the underlying protocol.
    event Withdrawn(uint256 amount);

    // ──────────────────────────────────────────────────────────────────────────
    // Errors
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Caller is not the authorized vault.
    error OnlyVault();

    /// @notice Deposit amount is zero.
    error ZeroAmount();

    /// @notice Address is zero.
    error ZeroAddress();

    /// @notice Withdrawal would exceed adapter balance.
    error InsufficientBalance();

    // ──────────────────────────────────────────────────────────────────────────
    // Views
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice The vault that this adapter serves.
    function vault() external view returns (address);

    /// @notice The underlying asset (USDC).
    function asset() external view returns (address);

    /// @notice Returns the current balance of the adapter in the underlying protocol,
    ///         denominated in the asset token (USDC).
    function totalAssets() external view returns (uint256);

    /// @notice Returns the current annualised yield in basis points (e.g. 500 = 5.00%).
    /// @dev    Adapters may read on-chain rate oracles or compute trailing yield.
    function currentAPY() external view returns (uint256);

    /// @notice Risk weight of this protocol, scaled to 1e4 (e.g. 9500 = 0.95).
    /// @dev    Set at construction time, immutable.
    function riskWeight() external view returns (uint256);

    /// @notice Human-readable identifier for the adapter (e.g. "MorphoBlue", "AaveV3").
    function protocolName() external view returns (string memory);

    // ──────────────────────────────────────────────────────────────────────────
    // Mutative
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Deposit `amount` of the asset into the underlying protocol.
    /// @dev    Only callable by the vault. The vault must have transferred `amount`
    ///         to this adapter before calling.
    /// @param amount The amount of the asset to deposit.
    function deposit(uint256 amount) external;

    /// @notice Withdraw `amount` of the asset from the underlying protocol and send
    ///         it back to the vault.
    /// @dev    Only callable by the vault.
    /// @param amount The amount of the asset to withdraw.
    function withdraw(uint256 amount) external;

    /// @notice Withdraw all assets from the underlying protocol and send them to the vault.
    /// @dev    Only callable by the vault. Used for emergency exits.
    /// @return withdrawn The actual amount withdrawn.
    function withdrawAll() external returns (uint256 withdrawn);

    /// @notice Update the cached APY value. Only callable by the vault.
    /// @param apyBps The new APY in basis points.
    function setAPY(uint256 apyBps) external;
}
