// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IYieldRouterAdapter} from "../interfaces/IYieldRouterAdapter.sol";

/// @title BaseAdapter
/// @notice Abstract base contract for all yield adapters. Handles common vault-only
///         access control, asset reference, and the `withdrawAll` helper.
abstract contract BaseAdapter is IYieldRouterAdapter {
    using SafeERC20 for IERC20;

    // ──────────────────────────────────────────────────────────────────────────
    // Immutables
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterAdapter
    address public immutable override vault;

    /// @inheritdoc IYieldRouterAdapter
    address public immutable override asset;

    /// @inheritdoc IYieldRouterAdapter
    uint256 public immutable override riskWeight;

    // ──────────────────────────────────────────────────────────────────────────
    // Constructor
    // ──────────────────────────────────────────────────────────────────────────

    /// @param _vault      The YieldRouterVault address.
    /// @param _asset      The underlying asset (USDC).
    /// @param _riskWeight Risk weight scaled to 1e4.
    constructor(address _vault, address _asset, uint256 _riskWeight) {
        if (_vault == address(0) || _asset == address(0)) revert ZeroAddress();
        vault = _vault;
        asset = _asset;
        riskWeight = _riskWeight;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Modifiers
    // ──────────────────────────────────────────────────────────────────────────

    modifier onlyVault() {
        if (msg.sender != vault) revert OnlyVault();
        _;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Default withdrawAll
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Returns the current balance in the underlying protocol.
    /// @dev Must be overridden by each adapter.
    function totalAssets() public view virtual override returns (uint256);

    /// @inheritdoc IYieldRouterAdapter
    function withdrawAll() external virtual override onlyVault returns (uint256 withdrawn) {
        uint256 balance = totalAssets();
        if (balance > 0) {
            _withdrawFromProtocol(balance);
        }
        // Transfer actual balance received, not the estimated amount
        withdrawn = IERC20(asset).balanceOf(address(this));
        if (withdrawn > 0) {
            IERC20(asset).safeTransfer(vault, withdrawn);
        }
        emit Withdrawn(withdrawn);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // APY feed (H-03 fix)
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Cached APY in basis points, updated by vault/keeper.
    uint256 internal _cachedAPY;

    /// @inheritdoc IYieldRouterAdapter
    function setAPY(uint256 apyBps) external override onlyVault {
        _cachedAPY = apyBps;
    }

    /// @inheritdoc IYieldRouterAdapter
    function currentAPY() external view virtual override returns (uint256) {
        return _cachedAPY;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Internal hooks
    // ──────────────────────────────────────────────────────────────────────────

    /// @dev Override to implement protocol-specific deposit logic.
    ///      The asset tokens are already in this contract when called.
    function _depositToProtocol(uint256 amount) internal virtual;

    /// @dev Override to implement protocol-specific withdrawal logic.
    ///      Must move `amount` of asset back into this contract.
    function _withdrawFromProtocol(uint256 amount) internal virtual;
}
