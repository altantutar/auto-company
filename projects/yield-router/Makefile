# ──────────────────────────────────────────────────────────────────────────────
# Yield Router — Makefile
# ──────────────────────────────────────────────────────────────────────────────
#
# Prerequisites:
#   - foundry (forge, cast) installed: https://book.getfoundry.sh/getting-started/installation
#   - .env file populated (copy from .env.example)
#
# Usage:
#   make deploy-testnet      Deploy all contracts to Base Sepolia
#   make keeper-harvest      Run harvest on the vault
#   make keeper-rebalance    Run rebalance on the vault
#   make keeper-update-apys  Update adapter APYs
#   make verify              Verify contracts on Basescan
#
# ──────────────────────────────────────────────────────────────────────────────

# Load .env if present
-include .env

# ── Chain configuration ───────────────────────────────────────────────────────
BASE_SEPOLIA_RPC   ?= https://sepolia.base.org
CHAIN_ID           := 84532
VERIFIER_URL       := https://api-sepolia.basescan.org/api
ETHERSCAN_API_KEY  ?= $(BASESCAN_API_KEY)

# ── Forge defaults ────────────────────────────────────────────────────────────
FORGE_OPTS := --rpc-url $(BASE_SEPOLIA_RPC)
VERIFY_OPTS := --verify --verifier-url $(VERIFIER_URL) --etherscan-api-key $(ETHERSCAN_API_KEY)

# ══════════════════════════════════════════════════════════════════════════════
# Build & Test
# ══════════════════════════════════════════════════════════════════════════════

.PHONY: build test fmt clean

build:
	forge build

test:
	forge test -vvv

fmt:
	forge fmt

clean:
	forge clean

# ══════════════════════════════════════════════════════════════════════════════
# Deployment
# ══════════════════════════════════════════════════════════════════════════════

.PHONY: deploy-testnet deploy-testnet-dry

## Deploy all contracts to Base Sepolia (broadcasts transactions)
deploy-testnet:
	@echo "=== Deploying to Base Sepolia (chain $(CHAIN_ID)) ==="
	@test -n "$(DEPLOYER_PRIVATE_KEY)" || (echo "ERROR: DEPLOYER_PRIVATE_KEY not set" && exit 1)
	@test -n "$(GOVERNANCE_ADDRESS)"   || (echo "ERROR: GOVERNANCE_ADDRESS not set" && exit 1)
	@test -n "$(GUARDIAN_ADDRESS)"     || (echo "ERROR: GUARDIAN_ADDRESS not set" && exit 1)
	@test -n "$(KEEPER_ADDRESS)"       || (echo "ERROR: KEEPER_ADDRESS not set" && exit 1)
	@test -n "$(FEE_RECIPIENT)"        || (echo "ERROR: FEE_RECIPIENT not set" && exit 1)
	forge script script/Deploy.s.sol:Deploy \
		$(FORGE_OPTS) \
		--private-key $(DEPLOYER_PRIVATE_KEY) \
		--broadcast \
		$(VERIFY_OPTS) \
		-vvvv
	@echo ""
	@echo "=== Deployment complete. Save addresses to deployments/base-sepolia.json ==="

## Dry-run deployment (simulate without broadcasting)
deploy-testnet-dry:
	@echo "=== Dry-run: Deploy to Base Sepolia (no broadcast) ==="
	forge script script/Deploy.s.sol:Deploy \
		$(FORGE_OPTS) \
		--private-key $(DEPLOYER_PRIVATE_KEY) \
		-vvvv

# ══════════════════════════════════════════════════════════════════════════════
# Keeper Operations
# ══════════════════════════════════════════════════════════════════════════════

.PHONY: keeper-harvest keeper-rebalance keeper-update-apys keeper-simulate-yield

## Run harvest — accrues performance fees on profit above HWM
keeper-harvest:
	@echo "=== Keeper: Harvest ==="
	@test -n "$(KEEPER_PRIVATE_KEY)" || (echo "ERROR: KEEPER_PRIVATE_KEY not set" && exit 1)
	@test -n "$(VAULT_PROXY)"       || (echo "ERROR: VAULT_PROXY not set" && exit 1)
	forge script script/Keeper.s.sol:KeeperHarvest \
		$(FORGE_OPTS) \
		--broadcast \
		-vvvv

## Run rebalance — redistribute capital across adapters
keeper-rebalance:
	@echo "=== Keeper: Rebalance ==="
	@test -n "$(KEEPER_PRIVATE_KEY)" || (echo "ERROR: KEEPER_PRIVATE_KEY not set" && exit 1)
	@test -n "$(VAULT_PROXY)"       || (echo "ERROR: VAULT_PROXY not set" && exit 1)
	forge script script/Keeper.s.sol:KeeperRebalance \
		$(FORGE_OPTS) \
		--broadcast \
		-vvvv

## Update adapter APYs — pass ADAPTER_APYS as comma-separated bps values
## Example: make keeper-update-apys ADAPTER_APYS="450,620,850"
keeper-update-apys:
	@echo "=== Keeper: Update APYs ==="
	@test -n "$(KEEPER_PRIVATE_KEY)" || (echo "ERROR: KEEPER_PRIVATE_KEY not set" && exit 1)
	@test -n "$(VAULT_PROXY)"       || (echo "ERROR: VAULT_PROXY not set" && exit 1)
	@test -n "$(ADAPTER_APYS)"      || (echo "ERROR: ADAPTER_APYS not set (e.g., '450,620,850')" && exit 1)
	forge script script/Keeper.s.sol:KeeperUpdateAPYs \
		$(FORGE_OPTS) \
		--broadcast \
		-vvvv

## Inject simulated yield into a mock adapter (testnet only)
## Example: make keeper-simulate-yield ADAPTER_INDEX=0 YIELD_AMOUNT=5000000
keeper-simulate-yield:
	@echo "=== Keeper: Simulate Yield ==="
	@test -n "$(KEEPER_PRIVATE_KEY)" || (echo "ERROR: KEEPER_PRIVATE_KEY not set" && exit 1)
	@test -n "$(VAULT_PROXY)"       || (echo "ERROR: VAULT_PROXY not set" && exit 1)
	@test -n "$(ADAPTER_INDEX)"     || (echo "ERROR: ADAPTER_INDEX not set" && exit 1)
	@test -n "$(YIELD_AMOUNT)"      || (echo "ERROR: YIELD_AMOUNT not set (raw USDC, e.g., 5000000)" && exit 1)
	forge script script/Keeper.s.sol:KeeperSimulateYield \
		$(FORGE_OPTS) \
		--broadcast \
		-vvvv

# ══════════════════════════════════════════════════════════════════════════════
# Verification
# ══════════════════════════════════════════════════════════════════════════════

.PHONY: verify verify-vault verify-adapter

## Verify all contracts — requires deployed addresses in env
## Set: VAULT_IMPL, VAULT_PROXY, MOCK_USDC, AAVE_ADAPTER, MORPHO_ADAPTER, AERO_ADAPTER
verify: verify-usdc verify-vault-impl verify-adapters
	@echo "=== All verifications submitted ==="

verify-usdc:
	@test -n "$(MOCK_USDC)" || (echo "ERROR: MOCK_USDC not set" && exit 1)
	forge verify-contract $(MOCK_USDC) \
		script/MockAdapter.sol:MockUSDC \
		--chain-id $(CHAIN_ID) \
		--verifier-url $(VERIFIER_URL) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--watch

verify-vault-impl:
	@test -n "$(VAULT_IMPL)" || (echo "ERROR: VAULT_IMPL not set" && exit 1)
	forge verify-contract $(VAULT_IMPL) \
		src/core/YieldRouterVault.sol:YieldRouterVault \
		--chain-id $(CHAIN_ID) \
		--verifier-url $(VERIFIER_URL) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--watch

verify-adapters:
	@test -n "$(AAVE_ADAPTER)" || (echo "ERROR: AAVE_ADAPTER not set" && exit 1)
	@test -n "$(MORPHO_ADAPTER)" || (echo "ERROR: MORPHO_ADAPTER not set" && exit 1)
	@test -n "$(AERO_ADAPTER)" || (echo "ERROR: AERO_ADAPTER not set" && exit 1)
	forge verify-contract $(AAVE_ADAPTER) \
		script/MockAdapter.sol:MockAdapter \
		--chain-id $(CHAIN_ID) \
		--verifier-url $(VERIFIER_URL) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--watch
	forge verify-contract $(MORPHO_ADAPTER) \
		script/MockAdapter.sol:MockAdapter \
		--chain-id $(CHAIN_ID) \
		--verifier-url $(VERIFIER_URL) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--watch
	forge verify-contract $(AERO_ADAPTER) \
		script/MockAdapter.sol:MockAdapter \
		--chain-id $(CHAIN_ID) \
		--verifier-url $(VERIFIER_URL) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--watch

# ══════════════════════════════════════════════════════════════════════════════
# On-chain inspection (read-only cast calls)
# ══════════════════════════════════════════════════════════════════════════════

.PHONY: status check-vault check-adapters check-roles

## Print vault status summary
status: check-vault check-adapters

check-vault:
	@test -n "$(VAULT_PROXY)" || (echo "ERROR: VAULT_PROXY not set" && exit 1)
	@echo "=== Vault Status ==="
	@echo "Name:            $$(cast call $(VAULT_PROXY) 'name()(string)' --rpc-url $(BASE_SEPOLIA_RPC))"
	@echo "Symbol:          $$(cast call $(VAULT_PROXY) 'symbol()(string)' --rpc-url $(BASE_SEPOLIA_RPC))"
	@echo "Asset:           $$(cast call $(VAULT_PROXY) 'asset()(address)' --rpc-url $(BASE_SEPOLIA_RPC))"
	@echo "Total Assets:    $$(cast call $(VAULT_PROXY) 'totalAssets()(uint256)' --rpc-url $(BASE_SEPOLIA_RPC))"
	@echo "High Water Mark: $$(cast call $(VAULT_PROXY) 'highWaterMark()(uint256)' --rpc-url $(BASE_SEPOLIA_RPC))"
	@echo "Deposit Cap:     $$(cast call $(VAULT_PROXY) 'depositCap()(uint256)' --rpc-url $(BASE_SEPOLIA_RPC))"
	@echo "Perf Fee (bps):  $$(cast call $(VAULT_PROXY) 'performanceFeeBps()(uint256)' --rpc-url $(BASE_SEPOLIA_RPC))"
	@echo "Paused:          $$(cast call $(VAULT_PROXY) 'paused()(bool)' --rpc-url $(BASE_SEPOLIA_RPC))"
	@echo "Fee Recipient:   $$(cast call $(VAULT_PROXY) 'feeRecipient()(address)' --rpc-url $(BASE_SEPOLIA_RPC))"

check-adapters:
	@test -n "$(VAULT_PROXY)" || (echo "ERROR: VAULT_PROXY not set" && exit 1)
	@echo ""
	@echo "=== Adapters ==="
	@cast call $(VAULT_PROXY) "getAdapters()(address[])" --rpc-url $(BASE_SEPOLIA_RPC)

# ══════════════════════════════════════════════════════════════════════════════
# Smoke Test (testnet only)
# ══════════════════════════════════════════════════════════════════════════════

.PHONY: smoke-test

## Run a full deposit -> rebalance -> yield -> harvest -> withdraw cycle
## Requires: DEPLOYER_PRIVATE_KEY, VAULT_PROXY, MOCK_USDC
smoke-test:
	@echo "=== Smoke Test ==="
	@test -n "$(DEPLOYER_PRIVATE_KEY)" || (echo "ERROR: DEPLOYER_PRIVATE_KEY not set" && exit 1)
	@test -n "$(VAULT_PROXY)"         || (echo "ERROR: VAULT_PROXY not set" && exit 1)
	@test -n "$(MOCK_USDC)"           || (echo "ERROR: MOCK_USDC not set" && exit 1)
	@echo "[1] Approve vault to spend USDC..."
	cast send $(MOCK_USDC) "approve(address,uint256)" $(VAULT_PROXY) $$(cast --max-uint) \
		--rpc-url $(BASE_SEPOLIA_RPC) --private-key $(DEPLOYER_PRIVATE_KEY)
	@echo "[2] Deposit 100 USDC..."
	cast send $(VAULT_PROXY) "deposit(uint256,address)" 100000000 $$(cast wallet address --private-key $(DEPLOYER_PRIVATE_KEY)) \
		--rpc-url $(BASE_SEPOLIA_RPC) --private-key $(DEPLOYER_PRIVATE_KEY)
	@echo "[3] Check total assets..."
	cast call $(VAULT_PROXY) "totalAssets()(uint256)" --rpc-url $(BASE_SEPOLIA_RPC)
	@echo "[4] Check share balance..."
	cast call $(VAULT_PROXY) "balanceOf(address)(uint256)" $$(cast wallet address --private-key $(DEPLOYER_PRIVATE_KEY)) \
		--rpc-url $(BASE_SEPOLIA_RPC)
	@echo "=== Smoke test deposit complete. Run keeper-rebalance next. ==="

# ══════════════════════════════════════════════════════════════════════════════
# Help
# ══════════════════════════════════════════════════════════════════════════════

.PHONY: help

help:
	@echo "Yield Router Makefile"
	@echo ""
	@echo "Build & Test:"
	@echo "  make build                Build contracts"
	@echo "  make test                 Run test suite"
	@echo "  make fmt                  Format Solidity files"
	@echo "  make clean                Clean build artifacts"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-testnet       Deploy to Base Sepolia (broadcast)"
	@echo "  make deploy-testnet-dry   Dry-run deployment (no broadcast)"
	@echo ""
	@echo "Keeper Operations:"
	@echo "  make keeper-harvest       Run harvest"
	@echo "  make keeper-rebalance     Run rebalance"
	@echo "  make keeper-update-apys   Update APYs (set ADAPTER_APYS)"
	@echo "  make keeper-simulate-yield  Inject yield (set ADAPTER_INDEX, YIELD_AMOUNT)"
	@echo ""
	@echo "Verification:"
	@echo "  make verify               Verify all contracts on Basescan"
	@echo ""
	@echo "Inspection:"
	@echo "  make status               Print vault status"
	@echo "  make smoke-test           Run deposit smoke test"
