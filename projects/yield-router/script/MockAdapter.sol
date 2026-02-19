// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IYieldRouterAdapter} from "../src/interfaces/IYieldRouterAdapter.sol";

// ──────────────────────────────────────────────────────────────────────────────
// MockUSDC — Mintable test token with 6 decimals
// ──────────────────────────────────────────────────────────────────────────────

/// @title MockUSDC
/// @notice Mintable ERC-20 for testnet deployment. Anyone can mint.
/// @dev DO NOT use in production. This is for Base Sepolia testnet only.
contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin (Test)", "USDC") {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    /// @notice Mint tokens to any address. No access control — testnet only.
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// MockAdapter — Simplified yield adapter with time-based yield accrual
// ──────────────────────────────────────────────────────────────────────────────

/// @title MockAdapter
/// @notice Testnet adapter that simulates yield accrual. Configurable APY via
///         the vault's updateAdapterAPYs() call or direct setAPY().
///
/// @dev Yield accrual model:
///      - Tracks a `lastAccrualTimestamp` and a `_cachedAPY` (in bps).
///      - On every view call to `totalAssets()`, computes elapsed time since
///        last accrual and adds proportional yield to the reported balance.
///      - On every mutative call (deposit/withdraw/simulateYield), yield is
///        "materialized" — the internal balance is updated and USDC is minted
///        to cover the accrued amount.
///
///      This means the adapter mints USDC out of thin air to simulate yield.
///      Only valid on testnet with a MockUSDC that has public mint().
///
/// @dev The adapter holds real USDC tokens. When the vault calls deposit(),
///      the adapter already received the tokens via safeTransfer. When
///      withdraw() is called, the adapter transfers tokens back to the vault.
contract MockAdapter is IYieldRouterAdapter {
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

    /// @notice Human-readable name for this mock adapter instance.
    string private _name;

    // ──────────────────────────────────────────────────────────────────────────
    // State
    // ──────────────────────────────────────────────────────────────────────────

    /// @dev Internal tracked balance (does NOT include pending accrued yield).
    uint256 internal _balance;

    /// @dev Cached APY in basis points, set by vault or keeper.
    uint256 internal _cachedAPY;

    /// @dev Timestamp of last yield materialization.
    uint256 internal _lastAccrualTimestamp;

    /// @dev Owner of the adapter — can call simulateYield() and setAPY().
    address public owner;

    // ──────────────────────────────────────────────────────────────────────────
    // Constants
    // ──────────────────────────────────────────────────────────────────────────

    /// @dev Seconds in a 365-day year, used for APY calculations.
    uint256 private constant SECONDS_PER_YEAR = 365 days;

    /// @dev Basis points denominator.
    uint256 private constant BPS = 10_000;

    // ──────────────────────────────────────────────────────────────────────────
    // Constructor
    // ──────────────────────────────────────────────────────────────────────────

    /// @param _vault      The YieldRouterVault proxy address.
    /// @param _asset      The USDC (or MockUSDC) address.
    /// @param _riskWeight Risk weight in 1e4 scale (e.g., 9500 = 0.95).
    /// @param name_       Human-readable protocol name (e.g., "MockAaveV3").
    /// @param _owner      Address that can call simulateYield() and manual setAPY().
    constructor(address _vault, address _asset, uint256 _riskWeight, string memory name_, address _owner) {
        if (_vault == address(0) || _asset == address(0)) revert ZeroAddress();
        vault = _vault;
        asset = _asset;
        riskWeight = _riskWeight;
        _name = name_;
        owner = _owner;
        _lastAccrualTimestamp = block.timestamp;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Modifiers
    // ──────────────────────────────────────────────────────────────────────────

    modifier onlyVault() {
        if (msg.sender != vault) revert OnlyVault();
        _;
    }

    modifier onlyOwnerOrVault() {
        if (msg.sender != vault && msg.sender != owner) revert OnlyVault();
        _;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // IYieldRouterAdapter — Views
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterAdapter
    function totalAssets() external view override returns (uint256) {
        return _balance + _pendingYield();
    }

    /// @inheritdoc IYieldRouterAdapter
    function currentAPY() external view override returns (uint256) {
        return _cachedAPY;
    }

    /// @inheritdoc IYieldRouterAdapter
    function protocolName() external view override returns (string memory) {
        return _name;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // IYieldRouterAdapter — Mutative
    // ──────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IYieldRouterAdapter
    function deposit(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();
        _materializeYield();
        _balance += amount;
        emit Deposited(amount);
    }

    /// @inheritdoc IYieldRouterAdapter
    function withdraw(uint256 amount) external override onlyVault {
        if (amount == 0) revert ZeroAmount();
        _materializeYield();
        if (amount > _balance) revert InsufficientBalance();
        _balance -= amount;
        IERC20(asset).safeTransfer(vault, amount);
        emit Withdrawn(amount);
    }

    /// @inheritdoc IYieldRouterAdapter
    function withdrawAll() external override onlyVault returns (uint256 withdrawn) {
        _materializeYield();
        withdrawn = _balance;
        _balance = 0;
        if (withdrawn > 0) {
            IERC20(asset).safeTransfer(vault, withdrawn);
        }
        emit Withdrawn(withdrawn);
    }

    /// @inheritdoc IYieldRouterAdapter
    function setAPY(uint256 apyBps) external override onlyOwnerOrVault {
        _materializeYield();
        _cachedAPY = apyBps;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Testnet helpers
    // ──────────────────────────────────────────────────────────────────────────

    /// @notice Manually inject yield into the adapter (testnet only).
    /// @dev Mints MockUSDC to this contract and increases the tracked balance.
    ///      Use this to simulate instant yield for smoke testing without
    ///      waiting for time-based accrual.
    /// @param amount Amount of USDC yield to inject.
    function simulateYield(uint256 amount) external {
        if (msg.sender != owner && msg.sender != vault) revert OnlyVault();
        MockUSDC(asset).mint(address(this), amount);
        _balance += amount;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Internal
    // ──────────────────────────────────────────────────────────────────────────

    /// @dev Compute pending yield based on elapsed time and current APY.
    ///      yield = balance * apyBps * elapsed / (BPS * SECONDS_PER_YEAR)
    function _pendingYield() internal view returns (uint256) {
        if (_balance == 0 || _cachedAPY == 0) return 0;
        uint256 elapsed = block.timestamp - _lastAccrualTimestamp;
        if (elapsed == 0) return 0;
        return (_balance * _cachedAPY * elapsed) / (BPS * SECONDS_PER_YEAR);
    }

    /// @dev Materialize pending yield: mint MockUSDC and add to balance.
    function _materializeYield() internal {
        uint256 yield_ = _pendingYield();
        _lastAccrualTimestamp = block.timestamp;
        if (yield_ > 0) {
            MockUSDC(asset).mint(address(this), yield_);
            _balance += yield_;
        }
    }
}
