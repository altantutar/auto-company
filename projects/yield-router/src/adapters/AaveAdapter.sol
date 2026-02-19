// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {BaseAdapter} from "./BaseAdapter.sol";
import {IYieldRouterAdapter} from "../interfaces/IYieldRouterAdapter.sol";

// ──────────────────────────────────────────────────────────────────────────────
// Minimal Aave V3 interfaces (only what we need)
// ──────────────────────────────────────────────────────────────────────────────

/// @dev Subset of the Aave V3 Pool interface.
interface IAavePool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

/// @dev Subset of IERC20 + Aave aToken view for balance query.
interface IAToken {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev Subset of the Aave V3 data provider for reading supply rate.
interface IAaveDataProvider {
    function getReserveData(address asset)
        external
        view
        returns (
            uint256 unbacked,
            uint256 accruedToTreasuryScaled,
            uint256 totalAToken,
            uint256 totalStableDebt,
            uint256 totalVariableDebt,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            uint40 lastUpdateTimestamp
        );
}

/// @title AaveAdapter
/// @notice Adapter for Aave V3 Base — supplies USDC to earn supply rate.
/// @dev Risk weight: 0.95 (9500). The adapter holds aUSDC on behalf of the vault.
///
///      Base Mainnet addresses:
///        Pool:  0xA238Dd80C259a72e81d7e4664a9801593F98d1c5
///        aUSDC: 0x4e65fE4DbA92790696d040ac24Aa414708F5c0AB
contract AaveAdapter is BaseAdapter {
    using SafeERC20 for IERC20;

    // ──────────────────────────────────────────────────────────────────────────
    // Immutables
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Aave V3 lending pool.
    IAavePool public immutable pool;

    /// @notice aUSDC token on Base.
    IAToken public immutable aToken;

    // ──────────────────────────────────────────────────────────────────────────
    // Constructor
    // ──────────────────────────────────────────────────────────────────────────

    /// @param _vault   The YieldRouterVault address.
    /// @param _asset   USDC address on Base.
    /// @param _pool    Aave V3 Pool address on Base.
    /// @param _aToken  aUSDC address on Base.
    constructor(
        address _vault,
        address _asset,
        address _pool,
        address _aToken
    ) BaseAdapter(_vault, _asset, 9500) {
        pool = IAavePool(_pool);
        aToken = IAToken(_aToken);

        // Max-approve the pool to spend our USDC (once, at deploy time).
        IERC20(_asset).forceApprove(address(_pool), type(uint256).max);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // IYieldRouterAdapter — Views
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc BaseAdapter
    function totalAssets() public view override returns (uint256) {
        return aToken.balanceOf(address(this));
    }

    // currentAPY() inherited from BaseAdapter — updated via setAPY() by vault/keeper.

    /// @inheritdoc IYieldRouterAdapter
    function protocolName() external pure override returns (string memory) {
        return "AaveV3";
    }

    // ──────────────────────────────────────────────────────────────────────────
    // IYieldRouterAdapter — Mutative
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterAdapter
    function deposit(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();
        // Vault has already transferred USDC to this contract.
        pool.supply(asset, amount, address(this), 0);
        emit Deposited(amount);
    }

    /// @inheritdoc IYieldRouterAdapter
    function withdraw(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();
        if (amount > totalAssets()) revert InsufficientBalance();
        pool.withdraw(asset, amount, vault);
        emit Withdrawn(amount);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Internal
    // ──────────────────────────────────────────────────────────────────────────

    function _depositToProtocol(uint256 amount) internal override {
        pool.supply(asset, amount, address(this), 0);
    }

    function _withdrawFromProtocol(uint256 amount) internal override {
        pool.withdraw(asset, amount, address(this));
    }
}
