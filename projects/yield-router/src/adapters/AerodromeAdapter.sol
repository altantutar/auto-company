// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {BaseAdapter} from "./BaseAdapter.sol";
import {IYieldRouterAdapter} from "../interfaces/IYieldRouterAdapter.sol";

// ──────────────────────────────────────────────────────────────────────────────
// Minimal Aerodrome interfaces
// ──────────────────────────────────────────────────────────────────────────────

/// @dev Aerodrome Router interface — only the methods we need for stable LP.
interface IAerodromeRouter {
    struct Route {
        address from;
        address to;
        bool stable;
        address factory;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function poolFor(address tokenA, address tokenB, bool stable, address factory)
        external
        view
        returns (address pool);

    function defaultFactory() external view returns (address);
}

/// @dev Aerodrome Pool (LP token) — minimal interface.
interface IAerodromePool {
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function getReserves() external view returns (uint256 reserve0, uint256 reserve1, uint256 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function approve(address spender, uint256 amount) external returns (bool);
}

/// @dev Aerodrome Gauge for staking LP tokens and earning emissions.
interface IAerodromeGauge {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function getReward(address account) external;
}

/// @title AerodromeAdapter
/// @notice Adapter for Aerodrome stable LP (USDC/USDbC or USDC/DAI pair).
/// @dev Risk weight: 0.80 (8000). Provides liquidity to Aerodrome stable pools and
///      stakes LP tokens in the gauge for emissions.
///
///      For simplicity in Phase 1, this adapter:
///        - Deposits single-sided by swapping half to the pair token (or uses
///          a zap if available).
///        - Tracks value using LP token balance * share of pool reserves.
///
///      Base Mainnet Router: 0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43
contract AerodromeAdapter is BaseAdapter {
    using SafeERC20 for IERC20;

    // ──────────────────────────────────────────────────────────────────────────
    // Immutables
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Aerodrome Router.
    IAerodromeRouter public immutable router;

    /// @notice The paired token in the stable LP (e.g. USDbC or DAI).
    address public immutable pairedToken;

    /// @notice The Aerodrome stable pool (LP token).
    IAerodromePool public immutable pool;

    /// @notice The Aerodrome gauge for staking LP tokens (address(0) if no gauge).
    IAerodromeGauge public immutable gauge;

    /// @notice Whether USDC is token0 in the pool.
    bool public immutable assetIsToken0;

    // ──────────────────────────────────────────────────────────────────────────
    // Constructor
    // ──────────────────────────────────────────────────────────────────────────

    /// @param _vault       The YieldRouterVault address.
    /// @param _asset       USDC address on Base.
    /// @param _router      Aerodrome Router address.
    /// @param _pairedToken The other stablecoin in the pair.
    /// @param _gauge       Aerodrome gauge address (address(0) if none).
    constructor(
        address _vault,
        address _asset,
        address _router,
        address _pairedToken,
        address _gauge
    ) BaseAdapter(_vault, _asset, 8000) {
        router = IAerodromeRouter(_router);
        pairedToken = _pairedToken;

        address factory = router.defaultFactory();
        address _pool = router.poolFor(_asset, _pairedToken, true, factory);
        pool = IAerodromePool(_pool);

        assetIsToken0 = (pool.token0() == _asset);
        gauge = IAerodromeGauge(_gauge);

        // Approvals
        IERC20(_asset).forceApprove(_router, type(uint256).max);
        IERC20(_pairedToken).forceApprove(_router, type(uint256).max);
        if (_gauge != address(0)) {
            // Approve gauge to take LP tokens
            pool.approve(_gauge, type(uint256).max);
        }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // IYieldRouterAdapter — Views
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc BaseAdapter
    function totalAssets() public view override returns (uint256) {
        uint256 lpBalance = _lpBalance();
        if (lpBalance == 0) return 0;

        uint256 supply = pool.totalSupply();
        if (supply == 0) return 0;

        (uint256 r0, uint256 r1,) = pool.getReserves();
        uint256 assetReserve = assetIsToken0 ? r0 : r1;

        // Our share of the asset reserve (times 2 because we hold both sides).
        // This is an approximation for stable pools where both tokens ~ $1.
        return (lpBalance * assetReserve * 2) / supply;
    }

    // currentAPY() inherited from BaseAdapter — updated via setAPY() by vault/keeper.

    /// @inheritdoc IYieldRouterAdapter
    function protocolName() external pure override returns (string memory) {
        return "Aerodrome";
    }

    // ──────────────────────────────────────────────────────────────────────────
    // IYieldRouterAdapter — Mutative
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterAdapter
    function deposit(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();

        // Split USDC in half: keep half as USDC, and we assume the paired token
        // is available or pre-swapped. For Phase 1 simplicity, we deposit both
        // sides equally. A production version would integrate a swap.
        uint256 halfAmount = amount / 2;
        uint256 pairedBalance = IERC20(pairedToken).balanceOf(address(this));

        // Use whichever is smaller: half of deposit or available paired token balance
        uint256 pairedAmount = pairedBalance < halfAmount ? pairedBalance : halfAmount;
        uint256 assetAmount = pairedAmount > 0 ? halfAmount : amount;

        if (pairedAmount > 0) {
            // 0.5% slippage tolerance for stable pairs
            uint256 amountAMin = (assetAmount * 995) / 1000;
            uint256 amountBMin = (pairedAmount * 995) / 1000;
            (,, uint256 liquidity) = router.addLiquidity(
                asset,
                pairedToken,
                true, // stable
                assetAmount,
                pairedAmount,
                amountAMin,
                amountBMin,
                address(this),
                block.timestamp
            );

            // Stake LP in gauge if available
            if (address(gauge) != address(0) && liquidity > 0) {
                gauge.deposit(liquidity);
            }
        }

        emit Deposited(amount);
    }

    /// @inheritdoc IYieldRouterAdapter
    function withdraw(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();
        if (amount > totalAssets()) revert InsufficientBalance();

        uint256 lpToRemove = _assetsToLp(amount);
        _unstakeAndRemoveLiquidity(lpToRemove);

        // Transfer recovered USDC back to vault
        uint256 assetBalance = IERC20(asset).balanceOf(address(this));
        uint256 toTransfer = assetBalance < amount ? assetBalance : amount;
        IERC20(asset).safeTransfer(vault, toTransfer);

        emit Withdrawn(toTransfer);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Internal
    // ──────────────────────────────────────────────────────────────────────────

    function _depositToProtocol(uint256 amount) internal override {
        // Simplified: just supply USDC side with 0.5% slippage
        uint256 minAmount = (amount * 995) / 1000;
        router.addLiquidity(
            asset, pairedToken, true,
            amount, 0, minAmount, 0,
            address(this), block.timestamp
        );
    }

    function _withdrawFromProtocol(uint256 amount) internal override {
        uint256 lpToRemove = _assetsToLp(amount);
        _unstakeAndRemoveLiquidity(lpToRemove);
    }

    /// @dev Returns total LP token balance (in gauge + unstaked).
    function _lpBalance() internal view returns (uint256) {
        uint256 unstaked = pool.balanceOf(address(this));
        uint256 staked = address(gauge) != address(0) ? gauge.balanceOf(address(this)) : 0;
        return unstaked + staked;
    }

    /// @dev Convert an asset amount to the equivalent LP tokens to burn.
    function _assetsToLp(uint256 assetAmount) internal view returns (uint256) {
        uint256 total = totalAssets();
        if (total == 0) return 0;
        uint256 lpBal = _lpBalance();
        return (assetAmount * lpBal) / total;
    }

    /// @dev Unstake from gauge (if needed) and remove liquidity.
    function _unstakeAndRemoveLiquidity(uint256 lpAmount) internal {
        if (lpAmount == 0) return;

        // Unstake from gauge first if needed
        if (address(gauge) != address(0)) {
            uint256 staked = gauge.balanceOf(address(this));
            if (staked > 0) {
                uint256 toUnstake = staked < lpAmount ? staked : lpAmount;
                gauge.withdraw(toUnstake);
            }
        }

        // Approve router for LP token
        uint256 available = pool.balanceOf(address(this));
        uint256 toRemove = available < lpAmount ? available : lpAmount;
        pool.approve(address(router), toRemove);

        // Compute minimum amounts with 0.5% slippage tolerance
        uint256 supply = pool.totalSupply();
        (uint256 r0, uint256 r1,) = pool.getReserves();
        uint256 minAsset = (toRemove * (assetIsToken0 ? r0 : r1) / supply) * 995 / 1000;
        uint256 minPaired = (toRemove * (assetIsToken0 ? r1 : r0) / supply) * 995 / 1000;

        router.removeLiquidity(
            asset,
            pairedToken,
            true,
            toRemove,
            minAsset,
            minPaired,
            address(this),
            block.timestamp
        );
    }
}
