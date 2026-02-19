<div align="center">

# Auto Crypto Company

**A fully autonomous AI crypto company**

12 AI agents, each modeled after crypto-native experts.
They research markets, design protocols, write Solidity, audit contracts, build frontends, and deploy — without human intervention.

Powered by [Claude Code](https://claude.ai/code).

[![Base](https://img.shields.io/badge/Chain-Base-blue)](https://base.org)
[![Foundry](https://img.shields.io/badge/Toolchain-Foundry-orange)](https://book.getfoundry.sh/)
[![Claude Code](https://img.shields.io/badge/Engine-Claude%20Code-purple)](#dependencies)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)
[![Status](https://img.shields.io/badge/Status-Experimental-red)](#disclaimer)

</div>

---

## First Product: Yield Router

**14 agents. Zero human code. One shipped DeFi product.**

Yield Router is a Base-native ERC-4626 yield vault that auto-allocates USDC across Aave, Morpho, and Aerodrome for optimized yield.

**[Live Frontend →](https://altantutar.github.io/yield-router/)**

Built in two pipeline runs:

```
Run 1 — Research to Audit (9 agents)
──────────────────────────────────────
research-hasu        → Market opportunity identified
ceo-armstrong        → GO decision (14-week timeline)
protocol-buterin     → Mechanism design (5 attack vectors)
tokenomics-cobie     → NO TOKEN — fee model, no inflation
defi-kulechov        → 1,163-line product spec
solidity-gakonst     → 2,500 lines Solidity, 47 tests
contracts-samczsun   → Security audit: 2 critical, 4 high (all fixed)
investor-haseeb      → CONDITIONAL INVEST, P($10M TVL) = 35%
infra-karalabe       → Deployment plan + keeper architecture

Run 2 — Design to Ship (5 agents)
──────────────────────────────────────
infra-karalabe       → Deploy scripts, Makefile, mock adapters
interaction-cooper   → UX design: 38 screen states, 3 personas
ui-duarte            → Visual design: 750-line Synapse system
fullstack-dhh        → 3,400-line frontend (vanilla HTML/CSS/JS)
qa-tincho            → QA: 4 bugs found and fixed, PASS
```

## How It Works

You give the agents a mission. They form squads, execute the pipeline, and update shared memory. Each cycle is an independent CLI call. `memories/consensus.md` is the cross-cycle baton.

```
Claude Code session
  ├── reads CLAUDE.md (charter + guardrails)
  ├── reads memories/consensus.md (current state)
  ├── forms Agent Team (3-12 agents as needed)
  ├── executes: research → design → code → audit → deploy
  └── updates memories/consensus.md (handoff)
```

## Team Lineup (12 Crypto-Native Agents)

Each agent is an expert persona with deep domain knowledge, not a generic "you are a developer" prompt.

| Layer | Agent | Persona | Domain |
|-------|-------|---------|--------|
| **Strategy** | `ceo-armstrong` | Brian Armstrong | Protocol direction, compliance, mass-market adoption |
| | `investor-haseeb` | Haseeb Qureshi | Investment gate, game theory, economic sustainability |
| **Protocol** | `protocol-buterin` | Vitalik Buterin | Mechanism design, game theory, upgrade paths |
| | `contracts-samczsun` | samczsun | Security audit, vulnerability analysis. **Mainnet veto power** |
| | `defi-kulechov` | Stani Kulechov | DeFi product design, lending, liquidity mechanics |
| | `tokenomics-cobie` | Cobie | Token design, anti-Ponzi detection, fair launch |
| **Engineering** | `solidity-gakonst` | Georgios Konstantopoulos | Solidity, Foundry, EVM optimization, deployment |
| | `qa-tincho` | Tincho | Smart contract QA, fuzz testing, invariant testing |
| | `infra-karalabe` | Péter Szilágyi | Node infra, RPC, chain indexing, frontend deploy |
| **Business** | `ecosystem-pollak` | Jesse Pollak | Developer ecosystem, L2 strategy, community |
| | `cfo-hayes` | Arthur Hayes | Macro cycles, treasury management, derivatives |
| | `research-hasu` | Hasu | Market structure, MEV, protocol economics |

Plus general-purpose agents for UX (Alan Cooper), UI (Matías Duarte), frontend (DHH), and QA (James Bach) when building consumer-facing products.

## Collaboration Pipelines

| # | Pipeline | Agent Chain |
|---|----------|-------------|
| 1 | **New Protocol** | research-hasu → ceo-armstrong → protocol-buterin → tokenomics-cobie → defi-kulechov → solidity-gakonst → contracts-samczsun → investor-haseeb → infra-karalabe |
| 2 | **DeFi Product Build** | defi-kulechov → protocol-buterin → solidity-gakonst → qa-tincho → contracts-samczsun → investor-haseeb → infra-karalabe |
| 3 | **Frontend + Ship** | interaction-cooper → ui-duarte → fullstack-dhh → qa-tincho → infra-karalabe |
| 4 | **Mainnet Deployment** | solidity-gakonst → qa-tincho → contracts-samczsun → investor-haseeb → infra-karalabe → ecosystem-pollak |
| 5 | **Security Incident** | contracts-samczsun → infra-karalabe → ceo-armstrong → ecosystem-pollak |
| 6 | **Market Assessment** | research-hasu → ceo-armstrong → tokenomics-cobie → cfo-hayes |

## Project Structure

```
auto-company/
├── CLAUDE.md                    # Company charter (mission + guardrails + team)
├── CRYPTO.md                    # Crypto-specific operating rules
├── memories/
│   └── consensus.md             # Shared state across cycles
├── .claude/
│   ├── agents/                  # 12+ agent definitions (expert personas)
│   └── skills/                  # 30+ reusable skills
├── projects/
│   ├── yield-router/            # First product
│   │   ├── src/                 # Solidity contracts
│   │   ├── test/                # Foundry tests (47 passing)
│   │   ├── script/              # Deployment + keeper scripts
│   │   ├── frontend/            # Landing page + dApp
│   │   └── docs/                # UX, UI, QA specs
│   └── pipeline-replay/         # Pipeline visualization
└── docs/                        # Agent outputs by role
    ├── research/                # Market intelligence
    ├── crypto-ceo/              # Strategic decisions
    ├── protocol/                # Mechanism designs
    ├── tokenomics/              # Token assessments
    ├── defi/                    # Product specs
    ├── solidity/                # Implementation notes
    ├── contracts/               # Audit reports
    ├── investor/                # Investment assessments
    ├── infra/                   # Deployment runbooks
    └── marketing/               # Launch strategy
```

## Safety Guardrails

Hard constraints enforced for all agents:

| Rule | Details |
|------|---------|
| No rug pulls | No removing liquidity, hidden mints, or backdoor admin keys |
| No unaudited mainnet | Testnet + `contracts-samczsun` audit before ANY mainnet deploy |
| No private key exposure | Never commit keys, seeds, or wallet secrets |
| No wash trading | No artificial volume or self-dealing |
| No destructive git | No force-push to main, no `gh repo delete` |
| User funds are sacred | Protecting user assets overrides all other priorities |

## Decision Principles

1. **Ship > Plan > Discuss** — if you can ship to testnet, do not over-discuss.
2. **Testnet fast, mainnet careful** — speed on testnet, rigor on mainnet.
3. **Real yield > token emissions** — sustainable revenue before inflationary incentives.
4. **Audit before deploy** — no exceptions, no shortcuts.
5. **Boring technology first** — use battle-tested contracts (OpenZeppelin) unless new approaches give clear 10x upside.
6. **Composability first** — build protocols others can build on.

## Tooling

| Tool | Purpose |
|------|---------|
| Foundry (`forge`/`cast`/`anvil`) | Smart contract dev, testing, deployment |
| OpenZeppelin v5 | Battle-tested contract libraries |
| ethers.js v6 | Wallet connection, on-chain interaction |
| `gh` CLI | GitHub operations |
| `wrangler` | Cloudflare deployment |
| Claude Code | Agent orchestration engine |

## Quick Start

```bash
# Clone
git clone https://github.com/altantutar/auto-company.git
cd auto-company

# Run the Yield Router tests
cd projects/yield-router
forge install
forge build
forge test -vvv    # 47 tests pass

# View the frontend locally
cd frontend
python3 -m http.server 8889
# Open http://localhost:8889
```

## Steering

The team runs autonomously. You steer by editing `memories/consensus.md`:

| Method | Action |
|--------|--------|
| **Change direction** | Edit "Next Action" in `memories/consensus.md` |
| **Review outputs** | Check `docs/*/` for agent artifacts |
| **Review code** | Check `projects/*/` for generated projects |

## Disclaimer

This is an **experimental project**:

- **Costs money**: each agent pipeline consumes model quota
- **Fully autonomous**: agents act without approval prompts; configure guardrails in `CLAUDE.md`
- **Smart contracts are unaudited by humans**: do not deposit real funds without a professional audit
- **No warranty**: review all generated code before any mainnet use

## Acknowledgments

- [nicepkg/auto-company](https://github.com/nicepkg/auto-company) — original Auto Company framework
- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts) — battle-tested Solidity libraries
- [Foundry](https://github.com/foundry-rs/foundry) — Solidity development toolchain
</div>
