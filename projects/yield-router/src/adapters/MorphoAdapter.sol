// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {BaseAdapter} from "./BaseAdapter.sol";
import {IYieldRouterAdapter} from "../interfaces/IYieldRouterAdapter.sol";

// ──────────────────────────────────────────────────────────────────────────────
// Minimal Morpho Blue interfaces
// ──────────────────────────────────────────────────────────────────────────────

/// @dev Market parameters for Morpho Blue.
struct MarketParams {
    address loanToken;
    address collateralToken;
    address oracle;
    address irm;
    uint256 lltv;
}

/// @dev Morpho Blue core interface — only the methods we need.
interface IMorphoBlue {
    function supply(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        bytes memory data
    ) external returns (uint256 assetsSupplied, uint256 sharesSupplied);

    function withdraw(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        address receiver
    ) external returns (uint256 assetsWithdrawn, uint256 sharesWithdrawn);

    /// @dev Returns (supplyShares, borrowShares, collateral) for a given user in a market.
    function position(bytes32 id, address user)
        external
        view
        returns (uint256 supplyShares, uint128 borrowShares, uint128 collateral);

    /// @dev Returns market state: totalSupplyAssets, totalSupplyShares, totalBorrowAssets,
    ///      totalBorrowShares, lastUpdate, fee.
    function market(bytes32 id)
        external
        view
        returns (
            uint128 totalSupplyAssets,
            uint128 totalSupplyShares,
            uint128 totalBorrowAssets,
            uint128 totalBorrowShares,
            uint128 lastUpdate,
            uint128 fee
        );

    function idToMarketParams(bytes32 id) external view returns (MarketParams memory);
}

/// @title MorphoAdapter
/// @notice Adapter for Morpho Blue — supplies USDC to a specific Morpho market.
/// @dev Risk weight: 0.90 (9000).
///
///      Base Mainnet Morpho Blue: 0xBBBBBBBBBB9cC5e90e3b3Af64bdAF62C37EEFFCb
///
///      The market ID is set at construction time. The adapter supplies USDC as the
///      loan token and earns the supply rate.
contract MorphoAdapter is BaseAdapter {
    using SafeERC20 for IERC20;

    // ──────────────────────────────────────────────────────────────────────────
    // Immutables
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Morpho Blue core contract.
    IMorphoBlue public immutable morpho;

    /// @notice The market ID this adapter supplies into.
    bytes32 public immutable marketId;

    /// @notice Cached market parameters (set once at construction).
    MarketParams public marketParams;

    // ──────────────────────────────────────────────────────────────────────────
    // Constructor
    // ──────────────────────────────────────────────────────────────────────────

    /// @param _vault    The YieldRouterVault address.
    /// @param _asset    USDC address on Base.
    /// @param _morpho   Morpho Blue address on Base.
    /// @param _marketId The Morpho market ID to supply into.
    constructor(
        address _vault,
        address _asset,
        address _morpho,
        bytes32 _marketId
    ) BaseAdapter(_vault, _asset, 9000) {
        morpho = IMorphoBlue(_morpho);
        marketId = _marketId;
        marketParams = morpho.idToMarketParams(_marketId);

        // Max-approve Morpho to spend our USDC.
        IERC20(_asset).forceApprove(_morpho, type(uint256).max);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // IYieldRouterAdapter — Views
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc BaseAdapter
    function totalAssets() public view override returns (uint256) {
        (uint256 supplyShares,,) = morpho.position(marketId, address(this));
        if (supplyShares == 0) return 0;

        (uint128 totalSupplyAssets, uint128 totalSupplyShares,,,,) = morpho.market(marketId);
        if (totalSupplyShares == 0) return 0;

        // Convert our shares to assets: assets = supplyShares * totalSupplyAssets / totalSupplyShares
        return (supplyShares * uint256(totalSupplyAssets)) / uint256(totalSupplyShares);
    }

    // currentAPY() inherited from BaseAdapter — updated via setAPY() by vault/keeper.

    /// @inheritdoc IYieldRouterAdapter
    function protocolName() external pure override returns (string memory) {
        return "MorphoBlue";
    }

    // ──────────────────────────────────────────────────────────────────────────
    // IYieldRouterAdapter — Mutative
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterAdapter
    function deposit(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();
        // Vault has already transferred USDC to this contract.
        morpho.supply(marketParams, amount, 0, address(this), "");
        emit Deposited(amount);
    }

    /// @inheritdoc IYieldRouterAdapter
    function withdraw(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();
        if (amount > totalAssets()) revert InsufficientBalance();
        morpho.withdraw(marketParams, amount, 0, address(this), vault);
        emit Withdrawn(amount);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Internal
    // ──────────────────────────────────────────────────────────────────────────

    function _depositToProtocol(uint256 amount) internal override {
        morpho.supply(marketParams, amount, 0, address(this), "");
    }

    function _withdrawFromProtocol(uint256 amount) internal override {
        morpho.withdraw(marketParams, amount, 0, address(this), address(this));
    }
}
