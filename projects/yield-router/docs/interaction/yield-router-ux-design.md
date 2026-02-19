# Yield Router: Interaction Design Specification

**Author:** interaction-cooper (Interaction Design Director)
**Date:** 2026-02-19
**Status:** FINAL -- Ready for UI Designer (ui-duarte) and Frontend Engineer (fullstack-dhh)
**Predecessors:** defi-kulechov product spec, protocol-buterin mechanism design, ceo-armstrong strategic direction, tokenomics-cobie no-token assessment

---

## 0. Design Philosophy for This Product

Before defining flows and screens, the design team must internalize one principle: **trust is the interaction**.

Every pixel, every loading state, every label on this interface either builds or erodes the user's confidence that their money is safe. This is not an e-commerce checkout where a bad experience means a lost sale. This is a financial application where a confusing interface means a user either deposits money they do not understand the risk of, or walks away from a product that would genuinely help them. Both outcomes are design failures.

DeFi interfaces have a specific problem: they expose the implementation model (transaction hashes, gas fees, approval flows, block confirmations) instead of the presentation model (your money is growing). Our job is to build the presentation model that is honest about the mechanism but never forces the user to think like a blockchain engineer.

Alan Cooper's law applies here directly: the software should behave like a considerate human assistant who manages your savings -- it tells you what matters, handles the plumbing silently, remembers your preferences, and never asks you a question it could answer itself.

---

## 1. User Personas

### 1.1 Primary Persona: Maya -- The Stablecoin Saver

**Who she is:** Maya is 32, a freelance product designer who earns a portion of her income in crypto. She keeps $15K-$50K in USDC on Coinbase as a stable reserve. She has used Coinbase for 4 years, has a Coinbase Wallet, and has bridged to Base a few times to try NFTs and simple DeFi apps. She is not a DeFi native -- she does not monitor lending rates or manage LP positions. She understands "deposit and earn yield" but not "ERC-4626 share price accounting."

**Goals:**
- Life Goal: Financial independence. She wants her savings to work for her without becoming a second job.
- Experience Goal: Feel confident and in control. She wants to understand what is happening with her money without needing a DeFi education.
- End Goal: Deposit USDC, earn a competitive yield, withdraw when she needs to. That is it.

**Pain points:**
- She has tried Aave directly but found the interface confusing (what is "supply APY" vs "borrow APY"? Why are there health factors?). She deposited once and left it.
- She has heard of Morpho but the curator/market structure feels too complex. She does not want to evaluate individual lending markets.
- She is suspicious of DeFi protocols that promise high APY because she lost money on UST/Luna. The word "yield" triggers caution, not excitement.
- She hates multi-step transactions. "Approve then deposit" feels like the interface is broken the first time she encounters it.

**Technical comfort:** Can connect a wallet, sign transactions, and bridge to Base. Cannot read a smart contract or interpret a block explorer. Does not know what gas is, but has seen small fees deducted.

**What she needs from our interface:**
- One number: the APY she is earning right now, net of all fees
- One action: deposit or withdraw
- One reassurance: her money is safe (or at least, what the risks are, in plain language)

**Maya is the Primary Persona. Every design decision must make Maya completely satisfied. If a feature confuses Maya, redesign it. If a flow requires knowledge Maya does not have, simplify it. No exceptions.**

### 1.2 Secondary Persona: Daniel -- The DeFi-Native Whale

**Who he is:** Daniel is 28, a full-time DeFi user who manages $200K-$1M across multiple protocols. He has positions on Morpho, Aave, Aerodrome, and several other Base protocols. He reads Solidity, monitors Dune dashboards, and evaluates protocols by their contracts and audit reports. He already optimizes yield manually and is evaluating whether Yield Router can do it better than he can.

**Goals:**
- Life Goal: Build wealth through DeFi expertise.
- Experience Goal: Transparency and control. He wants to verify every claim the protocol makes.
- End Goal: Maximize risk-adjusted yield on his stablecoin allocation while reducing his manual rebalancing time.

**Pain points:**
- He does not trust protocols that hide information. If he cannot see the exact allocation breakdown, adapter addresses, and contract source code, he will not deposit.
- He has been rugged before. He checks timelocks, multisig configurations, and audit reports before depositing.
- He finds most DeFi UIs either too dumbed-down (hiding information he needs) or too cluttered (showing irrelevant data).

**Technical comfort:** Expert. Reads contracts, uses block explorers, runs simulations.

**What he needs from our interface:**
- Full allocation breakdown by protocol and market
- Direct links to all contract addresses on Basescan
- Audit report and security documentation
- Real-time vault parameters (fee, cap, idle buffer, adapter list)
- Historical performance data

**Design implication:** Daniel's needs are met through an "Advanced" or "Details" view that is accessible but never forced on Maya. The default view serves Maya; the detailed view serves Daniel.

### 1.3 Tertiary Persona: Priya -- The DAO Treasury Manager

**Who she is:** Priya manages the treasury for a 50-person DAO with $500K-$2M in USDC. She reports to a multisig committee that must approve large transactions. She evaluates yield opportunities on behalf of the DAO, writes proposals, and presents risk assessments to non-technical committee members.

**Goals:**
- Life Goal: Advance her career in DAO operations.
- Experience Goal: Justify her recommendations with clear data. She needs to show the committee that this is safe and productive.
- End Goal: Park DAO treasury USDC in a yield-bearing position that does not require active management and that the committee can verify independently.

**Pain points:**
- She needs exportable data (CSV, PDF) for treasury reports.
- She needs clear risk documentation she can share with non-technical committee members.
- Multi-sig deposit flows are more complex (propose -> approve -> execute).
- She worries about deposit caps blocking a large DAO deposit.

**Technical comfort:** Intermediate. Understands DeFi concepts but does not read Solidity. Uses Safe (multi-sig wallet) regularly.

**What she needs from our interface:**
- Clear risk disclosures that she can screenshot or link for committee review
- Deposit cap visibility (can the DAO deposit its intended amount?)
- Performance tracking over time (monthly/quarterly views)
- Safe (multi-sig) wallet compatibility

**Design implication:** Priya is served by the same interface as Maya and Daniel, but we must ensure Safe wallet compatibility works cleanly, and that vault parameter information is linkable/shareable.

---

## 2. Information Architecture and Navigation

### 2.1 Site Structure

Yield Router is a single site with two modes: the **marketing surface** (landing page) and the **application surface** (dApp). They live on the same domain and share navigation, but serve different purposes.

```
yieldrouter.xyz
|
+-- / (Landing Page)
|   |-- Hero section
|   |-- How It Works
|   |-- Live Stats
|   |-- Security & Trust
|   |-- FAQ
|   |-- Footer
|
+-- /app (dApp -- requires wallet connection)
|   |-- /app/deposit (Deposit tab -- default view)
|   |-- /app/portfolio (Portfolio tab)
|   |-- /app/withdraw (Withdraw tab)
|   |-- /app/vault (Vault Info tab)
|
+-- /docs (External link to documentation)
```

**Key decision: single site, not two separate properties.** The landing page and dApp are on the same domain under the same navigation shell. This reduces friction (the user does not need to navigate to a different site to use the product) and maintains trust continuity (same visual identity throughout).

### 2.2 Global Navigation Bar

Present on every page. Fixed to the top of the viewport.

```
+----------------------------------------------------------------------+
|  [Yield Router Logo]    Deposit  |  Portfolio  |  Withdraw  |  Vault |
|                                                                      |
|                                          [Connect Wallet] / [0x...F] |
+----------------------------------------------------------------------+
```

**Behavior:**
- On the landing page: navigation tabs (Deposit, Portfolio, Withdraw, Vault) are visible but grayed out with a subtle label "Connect wallet to start." Clicking any of them scrolls to the landing page CTA or opens the wallet connection modal.
- On the dApp: tabs are active. The currently selected tab is visually highlighted.
- Wallet button: shows "Connect Wallet" when disconnected, shows a truncated address + Jazzicon/avatar when connected.
- The logo always links back to the landing page.

**Mobile behavior:** Navigation tabs collapse into a bottom tab bar (standard mobile pattern: 4 tabs at bottom of screen). The wallet connection button moves to the top-right corner. The logo becomes smaller and left-aligned.

### 2.3 Tab Structure Rationale

Four tabs, not more. Every tab maps to a user goal:

| Tab | User Goal | Maya's Question |
|-----|-----------|-----------------|
| **Deposit** | Put money in | "I want to start earning yield." |
| **Portfolio** | See how my money is doing | "How much have I earned?" |
| **Withdraw** | Take money out | "I need my money back." |
| **Vault** | Understand the product | "Is this safe? How does it work?" |

There is no "Settings" tab. There is nothing for the user to configure. The vault handles everything. This is intentional -- the product's value proposition is "you do not need to think about it." A settings page would undermine that.

---

## 3. Landing Page Flow

### 3.1 Purpose

The landing page converts a visitor into a depositor. The conversion funnel is:

```
Visitor arrives (via link, search, CT referral)
    |
    v
Understands what this is (Hero -- 5 seconds)
    |
    v
Understands how it works (How It Works -- 30 seconds)
    |
    v
Sees social proof that it works (Live Stats -- 10 seconds)
    |
    v
Trusts that it is safe (Security section -- 60 seconds)
    |
    v
Has remaining questions answered (FAQ -- as needed)
    |
    v
Clicks "Connect Wallet" or "Start Earning" (CTA)
```

Total time to conversion for Maya: under 3 minutes. Daniel will spend longer on the Security section and may click through to contracts and audit reports. That is fine -- the page structure supports both speeds.

### 3.2 Section-by-Section Design

#### Section 1: Hero

**Layout:** Full viewport height. Clean background (no gradients, no animations). Large headline centered.

**Content:**

```
Headline:     Your USDC. Earning more. Automatically.
Subheadline:  Yield Router auto-optimizes your stablecoin yield across
              Base's top protocols. No lock-ups. No token. Just yield.

[Live APY Badge: "Current net APY: 7.2%"]

[Primary CTA: "Start Earning"]   [Secondary CTA: "See How It Works"]
```

**Interaction notes:**
- The Live APY Badge reads from the vault contract in real-time. It shows the net APY (after the 10% performance fee), not the gross APY. Never show the gross number -- that is what the user does not get.
- "Start Earning" opens the wallet connection flow if not connected, or scrolls to the dApp deposit view if already connected.
- "See How It Works" smooth-scrolls to Section 2.
- No auto-playing animations. No particle effects. No "Web3 vibes." Clean, professional, trustworthy. Think Stripe, not PancakeSwap.

**Why this works for Maya:** She understands the headline immediately. USDC earns yield. It is automatic. Three seconds. The APY badge gives her the one number she cares about.

#### Section 2: How It Works

**Layout:** Three steps, horizontal on desktop, stacked vertically on mobile.

```
Step 1                    Step 2                    Step 3
[Deposit Icon]            [Router Icon]             [Growth Icon]

Deposit USDC              We optimize               You earn
Connect your wallet       Yield Router allocates     Watch your balance
and deposit any amount    your USDC across Aave,     grow. Withdraw
of USDC.                  Morpho, and Aerodrome      anytime. No lock-ups,
                          to find the best yield.    no penalties.

                          [Simple allocation bar
                           showing 3 protocols]
```

**Interaction notes:**
- Each step uses a simple icon (line art, not illustrative). The icons communicate the concept without requiring reading.
- Step 2 includes a small animated allocation bar showing proportions in Aave (blue), Morpho (purple), Aerodrome (teal). The bar slowly shifts proportions to suggest rebalancing. This is the only animation on the page and it is subtle.
- Below the three steps, a single line: "You receive yrUSDC -- a standard ERC-4626 vault share that grows in value as yield accrues."
- "ERC-4626" links to a tooltip or the FAQ explaining what this means in plain language.

**Why this works for Maya:** Three steps. She does not need to understand allocation algorithms or risk weights. "We optimize" is sufficient. Daniel, who wants more, will click through to the Vault Info tab.

#### Section 3: Live Stats

**Layout:** Four large numbers in a row, read from the vault contract.

```
+-----------+-----------+----------+-----------+
|           |           |          |           |
|  $4.2M    |  7.2%     |  312     |  $180K    |
|  TVL      |  Net APY  |  Users   |  Yield    |
|           |           |          |  Paid     |
+-----------+-----------+----------+-----------+
```

**Data sources:**
- TVL: `totalAssets()` from vault contract, formatted as USD
- Net APY: calculated from recent harvest data, displayed as annualized percentage after fees
- Users: count of unique yrUSDC holders (indexed off-chain from Transfer events)
- Yield Paid: cumulative yield distributed to depositors since launch (indexed from Harvest events)

**Interaction notes:**
- Numbers update in real-time (poll every 30 seconds or subscribe to new blocks).
- When numbers update, they animate with a subtle count-up (not a flash or blink).
- If data is loading, show a skeleton placeholder, not a spinner. Spinners signal "something is wrong" in a financial context.
- Each stat has a small (i) icon that expands a tooltip explaining what the number means.

**Why this works for Maya:** Social proof. Other people have deposited. Real money has been earned. The numbers are large and confident. She does not need to understand what TVL means -- the size of the number and the "$" sign communicate "this is real."

#### Section 4: Security and Trust

**Layout:** Two columns. Left: trust signals as a checklist. Right: brief explanatory text.

```
Security First

[check] Audited by [Auditor Name]         Our smart contracts have been
[check] Open source on GitHub              independently reviewed. All code
[check] Non-custodial -- withdraw anytime  is public. Your funds are never
[check] No token -- fees only              locked. We earn only when you earn.
[check] 48-hour timelock on all changes
[check] Max 10% fee -- hardcoded forever   [Link: Read the full audit report]
                                           [Link: View contracts on Basescan]
                                           [Link: Read our security docs]
```

**Interaction notes:**
- Each checklist item has a green checkmark icon. Green = safety. This is a culturally universal signal.
- Links to the audit report, Basescan contracts, and security documentation open in new tabs.
- Below this section, a yellow-bordered callout box with risk disclosures:

```
+------------------------------------------------------------------+
|  Risks to understand before depositing                           |
|                                                                  |
|  - Smart contract risk: Yield Router and the protocols it uses   |
|    (Morpho, Aave, Aerodrome) are software. Software can have    |
|    bugs. An exploit could result in partial or total loss.       |
|                                                                  |
|  - Yield variability: APY changes based on market conditions.    |
|    Past performance does not guarantee future returns.           |
|                                                                  |
|  - This is not a bank. There is no FDIC insurance or            |
|    equivalent protection.                                        |
+------------------------------------------------------------------+
```

**Why this works for Maya:** The checklist format is scannable. She sees "audited," "open source," "withdraw anytime" and feels reassured. The risk callout is honest without being alarming. It is in a visually distinct box so it does not blend into marketing copy -- that distinction matters for trust.

**Why this works for Daniel:** The three links (audit, contracts, docs) are his on-ramp to deep verification. He will click all three before depositing.

#### Section 5: FAQ

**Layout:** Accordion-style. Closed by default, each question expands to reveal the answer.

**Questions (in this order -- ordered by frequency of concern, not alphabetical):**

1. "What happens to my USDC after I deposit?"
2. "What is yrUSDC?"
3. "How is the APY calculated?"
4. "What are the fees?"
5. "Can I withdraw anytime?"
6. "What are the risks?"
7. "Who controls the vault?"
8. "Is there a token?"
9. "What wallets are supported?"
10. "What is the minimum deposit?"

**Interaction notes:**
- Only one FAQ item is open at a time. Opening a new one closes the previous.
- Answers are concise (2-4 sentences max). Link to documentation for longer explanations.
- The FAQ section has an anchor link (#faq) so it can be shared directly.

#### Section 6: Footer CTA

**Layout:** Full-width section with a repeated CTA.

```
Ready to put your USDC to work?

[Start Earning -- Connect Wallet]

Yield Router is built on Base. Your deposits are always withdrawable.
Performance fee: 10% of yield earned. No management fees. No token.
```

**Footer below:** Links to GitHub, Documentation, Basescan, Twitter/X, Discord (if applicable). Legal disclaimer link. Copyright.

---

## 4. dApp User Flows

### 4.1 Connect Wallet Flow

**Trigger:** User clicks "Connect Wallet" (in nav bar or CTA button).

**Flow:**

```
State: Not Connected
    |
    v
[Modal: Choose your wallet]
    - Coinbase Wallet (prioritized -- first in list, slightly larger)
    - MetaMask
    - WalletConnect
    - Rabby
    |
    v
User selects wallet
    |
    v
Wallet extension/app prompts for connection approval
    |
    v
State: Connecting (brief loading indicator in the modal)
    |
    +-- If wrong network (not Base):
    |     [Modal updates: "Switch to Base network"]
    |     [Button: "Switch to Base"]
    |     Clicking triggers network switch in wallet
    |
    +-- If correct network:
          |
          v
    State: Connected
    Nav bar updates: shows truncated address + Jazzicon
    Modal closes automatically
    Page transitions to /app/deposit (if on landing page)
    or stays on current dApp tab (if already in dApp)
```

**Interaction notes:**
- Coinbase Wallet is first in the list because Base is Coinbase's L2 and our Primary Persona (Maya) likely uses it. This is not favoritism -- it is serving the most common case first.
- If the user has previously connected, their wallet is remembered (via localStorage). On return visits, show a "Reconnect" state instead of the full wallet picker. One click to reconnect, not two.
- The network switch prompt is not a separate modal or page. It is an inline update to the connection modal. Reducing the number of modals reduces cognitive load.
- If wallet connection fails (user rejects, extension not installed), show a clear error message inside the modal: "Connection was cancelled. Try again?" Never show a technical error message. Never show an error code.

**Wallet compatibility requirements:**
- Coinbase Wallet (browser extension + mobile deep link)
- MetaMask (browser extension + mobile deep link)
- WalletConnect v2 (covers 100+ mobile wallets)
- Rabby (growing user base on Base)
- Safe (multi-sig) via WalletConnect -- critical for Priya's DAO use case

### 4.2 Deposit Flow

This is the most important flow in the entire product. Every friction point here costs depositors.

**Pre-conditions:** Wallet connected, on Base network, user has USDC balance > 0.

**Screen: Deposit Tab (/app/deposit)**

```
+------------------------------------------------------------------+
|                                                                  |
|  Deposit USDC                                                    |
|                                                                  |
|  +----------------------------------------------------+         |
|  |  Amount                                  [MAX]      |         |
|  |                                                     |         |
|  |  [______________________] USDC                      |         |
|  |                                                     |         |
|  |  Wallet balance: 12,450.00 USDC                     |         |
|  +----------------------------------------------------+         |
|                                                                  |
|  You will receive: ~12,283.47 yrUSDC                             |
|  Current share price: 1.0136 USDC per yrUSDC                    |
|  Net APY: 7.2%                                                   |
|                                                                  |
|  [Deposit USDC]  (primary button, full width)                    |
|                                                                  |
|  Vault deposit cap: $1,000,000 / $4,200,000 remaining           |
|  Minimum deposit: 10 USDC                                        |
|                                                                  |
+------------------------------------------------------------------+
```

**Detailed interaction sequence:**

```
Step 1: User enters amount
    - Input field accepts numeric input only
    - Live formatting with commas (e.g., "12,450.00")
    - "MAX" button fills wallet's full USDC balance
    - Below input: "Wallet balance: XX,XXX.XX USDC" (reads balanceOf)
    - Below input: "You will receive: ~XX,XXX.XX yrUSDC" (calls previewDeposit)
    - Share price and net APY displayed as contextual info
    |
    v
Step 2: Validation (instant, as user types)
    - Amount > 0: enable button
    - Amount >= minDeposit (10 USDC): enable button
    - Amount <= wallet balance: enable button
    - Amount would not exceed deposit cap: enable button
    - Any validation failure: button disabled, inline error message appears
      below the input (not a toast, not a modal -- inline, immediate)
    |
    v
Step 3: User clicks "Deposit USDC"
    |
    +-- Check: Has user approved the vault to spend their USDC?
    |   |
    |   +-- NO: Button label changes to "Approve USDC"
    |   |       User clicks -> wallet prompts approval transaction
    |   |       UI shows: "Approving USDC..." with a subtle loading state
    |   |       On approval confirmation:
    |   |         Button label changes back to "Deposit USDC"
    |   |         User clicks -> proceed to deposit
    |   |
    |   +-- YES (sufficient allowance): Proceed to deposit directly
    |
    v
Step 4: Deposit transaction
    - Button shows loading state: "Depositing..." (spinner inside button)
    - Wallet prompts transaction signature
    - User signs
    |
    v
Step 5: Transaction submitted
    - Button becomes "Transaction Pending..."
    - Below button: "View on Basescan" link (links to pending tx)
    - The rest of the page remains interactive (user can see their
      balance, read info, etc.). Do NOT show a full-screen blocking overlay.
    |
    v
Step 6: Transaction confirmed
    - Button resets to "Deposit USDC"
    - Success message slides in below the form (not a modal, not a toast
      that disappears -- a persistent inline success message):

      +----------------------------------------------------------+
      |  [check icon] Deposited 12,450.00 USDC successfully      |
      |  You received 12,283.47 yrUSDC                           |
      |  Transaction: 0xabc...def [link to Basescan]              |
      |                                               [Dismiss]   |
      +----------------------------------------------------------+

    - Wallet balance updates to new amount
    - "You will receive" field resets
```

**Critical interaction decisions:**

1. **Approval + Deposit as one conceptual action.** Maya does not know what "approval" means. From her perspective, she is depositing USDC. If approval is needed, the button label changes but the flow feels like one action, not two. We handle Permit2 or EIP-2612 under the hood when available. If the user has already approved Permit2 globally (many Base users have), the deposit is a single transaction.

2. **No confirmation modal before depositing.** Confirmation modals are interaction theater -- they train users to click "Confirm" without reading. Instead, we show all relevant information inline (amount, shares received, share price, APY) before the user clicks. The act of reviewing and clicking "Deposit USDC" is the confirmation.

3. **No full-screen loading overlay during transaction pending.** The user should be able to continue reading or navigate to other tabs while their transaction confirms. A blocking overlay communicates "something might be wrong" and creates anxiety. An inline "pending" state communicates "this is processing normally."

4. **Persistent success message, not a toast.** Toasts disappear after a few seconds. For a financial transaction, the user needs to see the confirmation for as long as they want. The message persists until they dismiss it or navigate away.

### 4.3 Portfolio View

**Screen: Portfolio Tab (/app/portfolio)**

This is the screen Maya checks most often. It answers: "How is my money doing?"

```
+------------------------------------------------------------------+
|                                                                  |
|  Your Position                                                   |
|                                                                  |
|  +----------------------------------------------------+         |
|  |                                                     |         |
|  |  $12,614.20                                         |         |
|  |  Current Value                                      |         |
|  |                                                     |         |
|  |  +$164.20 earned (+1.32%)                           |         |
|  |  since your first deposit on Jan 12, 2026           |         |
|  |                                                     |         |
|  +----------------------------------------------------+         |
|                                                                  |
|  +----------------------------------------------------+         |
|  |  Shares held      12,283.47 yrUSDC                  |         |
|  |  Share price       1.0269 USDC                       |         |
|  |  Net APY           7.2%                              |         |
|  |  Your share of TVL 0.3%                              |         |
|  +----------------------------------------------------+         |
|                                                                  |
|  Yield History                              [7D] [30D] [ALL]    |
|  +----------------------------------------------------+         |
|  |                                                     |         |
|  |  [Simple line chart: portfolio value over time]     |         |
|  |  X-axis: dates    Y-axis: USDC value                |         |
|  |                                                     |         |
|  +----------------------------------------------------+         |
|                                                                  |
|  Vault Allocation                                                |
|  +----------------------------------------------------+         |
|  |  [Horizontal stacked bar]                           |         |
|  |                                                     |         |
|  |  Aave V3       32%  |  Morpho Blue  45%  |         |         |
|  |  Aerodrome     18%  |  Idle Buffer   5%  |         |         |
|  +----------------------------------------------------+         |
|                                                                  |
+------------------------------------------------------------------+
```

**Data and calculations:**
- "Current Value" = user's yrUSDC balance * current pricePerShare. This is the headline number. It is always displayed in USDC terms, not in yrUSDC units.
- "Earned" = Current Value - total deposited (tracked via Deposit events for this address). Displayed as both absolute USDC and percentage.
- "Since your first deposit" = timestamp of user's first Deposit event.
- Share price = `convertToAssets(1e6) / 1e6` (for USDC with 6 decimals).
- Net APY = annualized from recent harvest performance data.
- Yield History chart = portfolio value over time, reconstructed from on-chain events (Deposit, Withdraw, and share price changes from Harvest events). Stored in an off-chain indexer for fast retrieval.
- Vault Allocation = from `getAdapterActualWeight()` for each adapter, plus idle buffer.

**Interaction notes:**
- The "Current Value" number is the most prominent element. Large font, top of page. Maya sees this number and immediately knows if things are good.
- The "+$164.20 earned" is in green text. This is a deliberate emotional design choice: green means growth, safety, positive. If the vault somehow had a loss (extremely unlikely with the high-water mark), this would display in yellow (not red -- red triggers panic) with a note explaining the situation.
- The chart defaults to "ALL" time range (since the user's first deposit). 7D and 30D are secondary options.
- The allocation bar uses color-coded segments. Each segment is labeled with the protocol name and percentage. Tapping/hovering a segment shows the USDC amount allocated. This gives Maya a visual sense of diversification without requiring her to understand what it means. Daniel uses this to verify allocation logic.
- If the user has no position (zero yrUSDC), the portfolio view shows: "You have no deposits yet. [Deposit USDC to start earning.]" with a link to the deposit tab.

### 4.4 Withdraw Flow

**Screen: Withdraw Tab (/app/withdraw)**

```
+------------------------------------------------------------------+
|                                                                  |
|  Withdraw USDC                                                   |
|                                                                  |
|  +----------------------------------------------------+         |
|  |  Amount                                  [MAX]      |         |
|  |                                                     |         |
|  |  [______________________] USDC                      |         |
|  |                                                     |         |
|  |  Available to withdraw: 12,614.20 USDC              |         |
|  |  (12,283.47 yrUSDC at 1.0269 USDC/share)           |         |
|  +----------------------------------------------------+         |
|                                                                  |
|  You will burn: ~12,283.47 yrUSDC                                |
|  You will receive: ~12,614.20 USDC                               |
|                                                                  |
|  [Withdraw USDC]  (primary button, full width)                   |
|                                                                  |
+------------------------------------------------------------------+
```

**Flow:**

```
Step 1: User enters USDC amount to withdraw
    - Input is in USDC terms (not yrUSDC shares)
    - "MAX" fills the maximum withdrawable amount
    - "Available to withdraw" shows user's full position value in USDC
    - Below: shows yrUSDC shares that will be burned (from previewWithdraw)
    |
    v
Step 2: Validation
    - Amount > 0
    - Amount <= maxWithdraw (from vault contract)
    - If amount exceeds available liquidity: show warning
      "This amount exceeds current vault liquidity. You may receive
       a partial withdrawal. [Learn more]"
    |
    v
Step 3: User clicks "Withdraw USDC"
    - Wallet prompts transaction signature
    |
    v
Step 4: Transaction submitted
    - "Transaction Pending..." with Basescan link
    |
    v
Step 5: Confirmed
    - Inline success message:
      "Withdrew 12,614.20 USDC. 12,283.47 yrUSDC burned.
       Transaction: 0x... [Basescan link]"
    - Balance updates
```

**Interaction decisions:**

1. **Input is in USDC, not yrUSDC.** Maya thinks in dollars. She wants to withdraw "$5,000 worth." She does not want to calculate how many yrUSDC shares equal $5,000. The input accepts USDC amounts and we calculate the share burn amount behind the scenes. The shares burned are shown as secondary information below the input.

2. **Partial withdrawal is silent, not alarming.** If the vault needs to unwind positions to fulfill the withdrawal, the user does not need to know about it. The withdrawal is atomic (one transaction). Internally, the vault may pull from Aave or Morpho, but the user just sees "withdrawing..." and then "done." The only case where we surface complexity is if the vault cannot fully fulfill the withdrawal due to extreme liquidity constraints. This is an edge case that the product spec says is "extremely unlikely" given the 5% idle buffer, but we design for it anyway.

3. **No withdrawal fee confirmation.** There is no withdrawal fee. We do not need to show "Fee: $0.00" -- that would imply fees are possible. Just show the amount in and amount out.

### 4.5 Vault Info View

**Screen: Vault Info Tab (/app/vault)**

This tab serves Daniel (deep verification) and Priya (risk documentation for committee). Maya may never visit it, and that is fine.

```
+------------------------------------------------------------------+
|                                                                  |
|  Vault Details                                                   |
|                                                                  |
|  Vault address      0x1234...5678  [copy] [Basescan link]       |
|  Asset              USDC                                         |
|  Share token         yrUSDC                                       |
|  Standard           ERC-4626                                     |
|                                                                  |
|  +----------------------------------------------------+         |
|  |  Parameters                                         |         |
|  |                                                     |         |
|  |  Performance fee   10% of yield earned               |         |
|  |  Max fee (hardcoded) 10% -- can never increase       |         |
|  |  Management fee    None                              |         |
|  |  Withdrawal fee    None                              |         |
|  |  Deposit cap       $1,000,000                        |         |
|  |  Minimum deposit   10 USDC                           |         |
|  |  Idle buffer       5%                                |         |
|  |  Rebalance threshold 200 bps                         |         |
|  |  Timelock delay    48 hours                          |         |
|  +----------------------------------------------------+         |
|                                                                  |
|  +----------------------------------------------------+         |
|  |  Adapters (Yield Sources)                           |         |
|  |                                                     |         |
|  |  1. Aave V3 USDC Supply                             |         |
|  |     Address: 0xaaaa...bbbb [Basescan]               |         |
|  |     Balance: $1,340,000                              |         |
|  |     Current APY: 6.8%                                |         |
|  |     Status: Active                                   |         |
|  |                                                     |         |
|  |  2. Morpho Blue USDC/cbBTC (Gauntlet)               |         |
|  |     Address: 0xcccc...dddd [Basescan]               |         |
|  |     Balance: $1,890,000                              |         |
|  |     Current APY: 8.2%                                |         |
|  |     Status: Active                                   |         |
|  |                                                     |         |
|  |  3. Morpho Blue USDC/cbETH (Gauntlet)               |         |
|  |     Address: 0xeeee...ffff [Basescan]               |         |
|  |     Balance: $630,000                                |         |
|  |     Current APY: 7.5%                                |         |
|  |     Status: Active                                   |         |
|  |                                                     |         |
|  |  Idle Buffer: $340,000 (8.1%)                        |         |
|  +----------------------------------------------------+         |
|                                                                  |
|  +----------------------------------------------------+         |
|  |  Security                                           |         |
|  |                                                     |         |
|  |  Audit report      [Auditor Name] -- [PDF link]     |         |
|  |  Source code        [GitHub link]                    |         |
|  |  Governance         3-of-5 multisig + 48h timelock  |         |
|  |  Guardian           2-of-3 multisig (separate keys) |         |
|  |  Pending changes    None                             |         |
|  |  Bug bounty         $25,000 [Details]                |         |
|  +----------------------------------------------------+         |
|                                                                  |
|  +----------------------------------------------------+         |
|  |  Risk Disclosures                                   |         |
|  |                                                     |         |
|  |  [Full text of all 5 mandatory risk disclosures     |         |
|  |   from product spec Section 5.4]                    |         |
|  +----------------------------------------------------+         |
|                                                                  |
+------------------------------------------------------------------+
```

**Interaction notes:**
- Every address is copiable (click to copy) and links to Basescan.
- "Pending changes" shows any governance proposals in the timelock queue. If there are pending changes, this section highlights in yellow with details of what is proposed and when it executes. This is critical for Daniel's trust evaluation.
- Adapter APY values are read in real-time from the adapter contracts.
- The Security section is designed to be screenshot-able and linkable for Priya's committee reports.

---

## 5. Key Interaction Patterns

### 5.1 Loading States

Every piece of data on the dApp comes from the blockchain or an indexer. Loading is inherent. How we handle it determines whether the user feels "this is working" or "this is broken."

**Rules:**

1. **Skeleton loaders for initial data.** When a page loads, show gray placeholder rectangles where numbers will appear. This communicates "data is coming" without the anxiety of a spinner.

2. **No spinners in the main content area.** Spinners are reserved for in-button loading states (during transaction submission). A spinner on a financial number means "we do not know how much money you have right now" -- that is anxiety-inducing.

3. **Stale data with freshness indicators.** If a blockchain query takes longer than 5 seconds, show the last known value with a small "updated 30s ago" timestamp. Stale data is better than no data for a financial app.

4. **Transaction states are a 4-step progression:**
   - Idle (button is ready)
   - Waiting for wallet (button shows "Confirm in wallet...")
   - Pending (button shows "Transaction pending..." with Basescan link)
   - Confirmed/Failed (inline success or error message)

5. **Never show an empty state without guidance.** If the user has no deposits, show "You have no deposits yet" with a CTA to deposit. If data fails to load, show "Unable to load data. [Retry]" -- not a blank page, not a generic error.

### 5.2 Error States

Errors in DeFi apps fall into two categories: user errors (fixable) and system errors (not fixable by the user). We handle them differently.

**User errors (inline, immediate, actionable):**

| Error Condition | Message | Location |
|-----------------|---------|----------|
| Amount below minimum | "Minimum deposit is 10 USDC." | Below input field |
| Amount exceeds balance | "You only have XX USDC in your wallet." | Below input field |
| Amount exceeds deposit cap | "This deposit would exceed the vault cap. Maximum additional deposit: $XX." | Below input field |
| Withdrawal exceeds position | "You can withdraw up to XX USDC." | Below input field |
| Wrong network | "Please switch to Base network." | In connection modal |
| Insufficient gas (ETH for gas) | "You need a small amount of ETH on Base for transaction fees. [Bridge ETH to Base]" | Below the action button |

**System errors (gentle, honest, non-technical):**

| Error Condition | Message | Location |
|-----------------|---------|----------|
| Transaction reverted | "This transaction could not be completed. This may be due to a temporary network issue. Please try again in a few minutes." | Inline, below button |
| Vault paused (deposits) | "Deposits are temporarily paused while the team investigates a potential issue. Your existing deposits are safe and you can withdraw at any time." | Banner at top of dApp, yellow background |
| RPC failure | "Unable to connect to the Base network. Retrying..." with auto-retry | Banner at top of dApp |
| Wallet disconnected unexpectedly | "Your wallet was disconnected. [Reconnect]" | Banner at top of dApp |
| Transaction rejected by user | "Transaction cancelled." (No further action needed.) | Inline, below button, disappears after 5 seconds |

**Rules for error messages:**
- Never show transaction hashes in error messages. The hash is meaningless to Maya.
- Never show Solidity error messages (revert reasons like "ERC20InsufficientAllowance"). Translate every revert reason into human language.
- Never blame the user. "Transaction failed" not "You submitted an invalid transaction."
- Always provide a next step. "Try again," "Reduce amount," or "Contact support."

### 5.3 Success Confirmations

Every successful transaction gets a persistent, inline confirmation with a link to the transaction on Basescan. The confirmation stays visible until the user dismisses it or navigates away.

**Template:**

```
+----------------------------------------------------------+
|  [green check icon]                                      |
|                                                          |
|  [Action] completed successfully                         |
|  [Details: amount, shares, etc.]                         |
|                                                          |
|  Transaction: 0xabc...def  [View on Basescan]            |
|                                              [Dismiss]   |
+----------------------------------------------------------+
```

**Examples:**
- Deposit: "Deposited 5,000.00 USDC. You received 4,932.41 yrUSDC."
- Withdraw: "Withdrew 3,000.00 USDC. Burned 2,959.50 yrUSDC."
- Approval: "USDC spending approved. You can now deposit."

### 5.4 Real-Time Data Updates

**What updates in real-time (per-block or every 15 seconds):**
- TVL
- Net APY
- Share price
- User's current value (Portfolio page)
- Wallet USDC balance
- Vault allocation percentages

**What updates less frequently (every 5 minutes or on user action):**
- User's total earned
- Yield history chart
- Adapter APY values

**What updates only on page load:**
- Vault parameters (fee, cap, timelock)
- Adapter list
- Security information

**Update animation:** When a number changes, it performs a brief (200ms) fade transition from old value to new value. No counting animation on real-time updates -- that is distracting when it happens every 15 seconds. The count-up animation is only used on the landing page stats (which are first-load only).

### 5.5 Vault Paused State

When the vault is paused (deposits disabled, withdrawals still active):

**Landing page:** A yellow banner appears at the top: "Deposits are temporarily paused. Existing depositors can withdraw at any time. [Learn more]"

**dApp Deposit tab:** The deposit form is replaced with a message: "Deposits are temporarily paused while the team investigates a potential issue. Your existing deposits are safe and withdrawable. We will update this page when deposits resume."

**dApp Portfolio tab:** Normal display, plus a yellow banner: "Deposits are paused. Withdrawals are unaffected."

**dApp Withdraw tab:** Normal operation. No change. Withdrawals always work. The withdraw tab should never, under any circumstances, show a "paused" state.

---

## 6. Screen Inventory

Every unique screen and state the user can encounter, ordered by navigation flow.

### 6.1 Landing Page Screens

| # | Screen | Description |
|---|--------|-------------|
| L1 | Landing Page (default) | Full landing page with Hero, How It Works, Stats, Security, FAQ, Footer CTA. No wallet connected. |
| L2 | Landing Page (wallet connected) | Same content, but nav bar shows wallet address and dApp tabs are active. "Start Earning" buttons now link directly to /app/deposit. |

### 6.2 Wallet Connection Screens

| # | Screen | Description |
|---|--------|-------------|
| W1 | Wallet Picker Modal | Modal overlay with list of supported wallets (Coinbase Wallet, MetaMask, WalletConnect, Rabby). |
| W2 | Connecting State | Modal shows "Connecting to [wallet name]..." with a subtle progress indicator. |
| W3 | Wrong Network | Modal shows "Please switch to Base" with a "Switch Network" button. |
| W4 | Connection Failed | Modal shows "Connection failed. [Try again]" with reason if available (e.g., "Wallet extension not detected"). |
| W5 | Reconnect Prompt | For returning users: "Reconnect to [previous wallet]? [Connect] [Use different wallet]" |

### 6.3 Deposit Tab Screens

| # | Screen | Description |
|---|--------|-------------|
| D1 | Deposit (empty) | Amount input is empty. "Deposit USDC" button is disabled. Wallet balance shown. Share price and APY displayed. |
| D2 | Deposit (amount entered) | User has entered a valid amount. Preview shows yrUSDC to receive. Button is enabled. |
| D3 | Deposit (validation error) | Invalid amount entered. Inline error message below input. Button disabled. |
| D4 | Deposit (approval needed) | Button label changes to "Approve USDC." Explainer text: "First time depositing? You need to approve USDC spending first." |
| D5 | Deposit (approving) | Button shows "Approving..." Wallet prompt is open. |
| D6 | Deposit (approval pending) | Button shows "Approval pending..." with Basescan link. |
| D7 | Deposit (ready after approval) | Approval confirmed. Button reverts to "Deposit USDC." |
| D8 | Deposit (confirming in wallet) | Button shows "Confirm in wallet..." Wallet prompt is open. |
| D9 | Deposit (transaction pending) | Button shows "Depositing..." with Basescan link. |
| D10 | Deposit (success) | Inline success message with amount deposited, yrUSDC received, tx link. Form resets. |
| D11 | Deposit (failed) | Inline error message with human-readable reason and "Try again" guidance. |
| D12 | Deposit (vault paused) | Form replaced with "Deposits paused" message. Withdraw CTA offered instead. |
| D13 | Deposit (cap reached) | Deposit cap reached. Message: "The vault has reached its deposit cap of $X. Check back later or follow us for updates when the cap is raised." |

### 6.4 Portfolio Tab Screens

| # | Screen | Description |
|---|--------|-------------|
| P1 | Portfolio (with position) | Full portfolio view: current value, earned, share details, yield chart, allocation bar. |
| P2 | Portfolio (no position) | "You have no deposits yet. [Deposit USDC to start earning.]" |
| P3 | Portfolio (loading) | Skeleton loaders in place of all numbers and charts. |
| P4 | Portfolio (vault paused banner) | Normal portfolio display with yellow "Deposits paused" banner. Withdrawals unaffected. |

### 6.5 Withdraw Tab Screens

| # | Screen | Description |
|---|--------|-------------|
| WD1 | Withdraw (empty) | Amount input is empty. "Withdraw USDC" button is disabled. Available balance shown. |
| WD2 | Withdraw (amount entered) | Valid amount entered. Preview shows yrUSDC to burn and USDC to receive. Button enabled. |
| WD3 | Withdraw (validation error) | Amount exceeds position or is invalid. Inline error. |
| WD4 | Withdraw (confirming in wallet) | Button shows "Confirm in wallet..." |
| WD5 | Withdraw (transaction pending) | Button shows "Withdrawing..." with Basescan link. |
| WD6 | Withdraw (success) | Inline success with amount withdrawn, shares burned, tx link. |
| WD7 | Withdraw (failed) | Inline error with reason and retry guidance. |
| WD8 | Withdraw (no position) | "You have no deposits to withdraw." with deposit CTA. |
| WD9 | Withdraw (liquidity warning) | "This amount exceeds current vault liquidity" warning displayed before user submits. |

### 6.6 Vault Info Tab Screens

| # | Screen | Description |
|---|--------|-------------|
| V1 | Vault Info (normal) | Full vault details: parameters, adapter list with balances/APY, security info, risk disclosures. |
| V2 | Vault Info (pending governance change) | Same as V1 but with yellow "Pending Changes" section showing queued timelock proposals and execution timestamps. |
| V3 | Vault Info (vault paused) | Same as V1 but with a red "Vault Paused" status indicator and explanation. |

### 6.7 Global States

| # | Screen | Description |
|---|--------|-------------|
| G1 | No wallet connected (dApp) | If user navigates directly to /app/*, show content with "Connect wallet to interact" where action buttons would be. Data (TVL, APY, allocation) is still visible -- wallet-less visitors can browse. |
| G2 | Network error | Top banner: "Unable to connect to Base network. Retrying..." Auto-retry every 10 seconds. |
| G3 | Mobile responsive | All screens adapt to mobile viewport. Bottom tab navigation. Stacked layouts. Touch-friendly input fields (larger hit targets). |

---

## 7. Mobile-Specific Considerations

### 7.1 Navigation

Desktop top bar becomes a bottom tab bar on mobile (standard iOS/Android pattern). Four tabs: Deposit, Portfolio, Withdraw, Vault. Wallet connection button moves to top-right corner of the screen.

### 7.2 Input

- Amount input fields have `inputmode="decimal"` to trigger a numeric keyboard on mobile.
- "MAX" button has a large enough touch target (minimum 44x44px per Apple HIG).
- Buttons are full-width on mobile for easy thumb reach.

### 7.3 Deep Links

Support deep links for wallet connection from mobile wallet apps:
- `yieldrouter.xyz/app/deposit?connect=coinbase` opens the deposit tab and auto-triggers Coinbase Wallet connection.
- This enables one-tap deposit from wallet app browsers.

### 7.4 Responsive Breakpoints

| Breakpoint | Layout Adaptation |
|------------|-------------------|
| >= 1024px | Full desktop layout. Side-by-side elements where applicable. |
| 768-1023px | Tablet layout. Reduced padding. Stats grid becomes 2x2 instead of 4x1. |
| < 768px | Mobile layout. Stacked single-column. Bottom tab nav. Full-width buttons. |

---

## 8. Interaction Anti-Patterns to Avoid

These are patterns common in DeFi apps that violate good interaction design principles. The frontend team must not implement any of these.

| Anti-Pattern | Why It Is Bad | What To Do Instead |
|--------------|---------------|-------------------|
| Full-screen loading overlay during transactions | Creates anxiety. User feels trapped. Cannot do anything while waiting. | Inline loading state on the button. Rest of page remains interactive. |
| Toast notifications for financial events | Toasts disappear. Financial confirmations must persist until dismissed. | Inline, persistent success/error messages. |
| Technical jargon in error messages | "ERC20InsufficientAllowance" means nothing to Maya. | "You need to approve USDC spending first." |
| Separate approve and deposit pages | Two separate interactions for one user goal. | Single page, button label changes from "Approve" to "Deposit." |
| Showing gas estimates prominently | Gas on Base is < $0.05. Showing it gives Maya the impression this is expensive. | Show gas only if it is unusually high (> $1). Otherwise, hide it. |
| Asking for yrUSDC share input | Users think in USDC, not vault shares. | Input is always in USDC. Share conversions shown as secondary info. |
| Auto-refreshing that resets user input | Data refresh should never clear an amount the user is typing. | Refresh data in background, update display fields, but never touch input fields. |
| "Are you sure?" confirmation modals | Trains users to click "Yes" without reading. Does not actually prevent errors. | Show all information inline before the action button. Make the button label specific ("Deposit 5,000 USDC" not "Confirm"). |
| Countdown timers for transaction confirmation | Creates artificial urgency and anxiety. | Show "Transaction pending..." with no time estimate. Base confirms in ~2 seconds. |
| Dark patterns (pre-checked max deposit, etc.) | Violates trust. Unethical in a financial application. | All inputs start empty. User explicitly chooses their amount. |

---

## 9. Accessibility Requirements

### 9.1 Minimum Standards

- WCAG 2.1 AA compliance for all interactive elements.
- All interactive elements are keyboard-navigable (Tab, Enter, Escape).
- All images and icons have alt text.
- Color is never the sole indicator of state (always pair with text or icons).
- Minimum contrast ratio of 4.5:1 for normal text, 3:1 for large text.
- Form fields have associated labels (not just placeholder text).

### 9.2 Screen Reader Considerations

- Transaction status changes are announced via ARIA live regions.
- The allocation chart has a text alternative ("Aave V3: 32%, Morpho Blue: 45%, Aerodrome: 18%, Idle: 5%").
- Modal dialogs trap focus appropriately and can be closed with Escape.

---

## 10. Handoff Notes for UI Designer (ui-duarte)

1. **Visual tone:** Professional, clean, trustworthy. Reference: Stripe's dashboard, not Uniswap's swap interface. No neon gradients, no "crypto" aesthetic. Think "digital bank" not "DeFi degen tool."

2. **Color palette:** Use blue or navy as the primary color (trust, stability, finance). Green for positive values and success states. Yellow/amber for warnings. Red only for critical errors (and use sparingly). Avoid purple-heavy DeFi palettes that signal "speculative."

3. **Typography:** A clean sans-serif. Inter, Satoshi, or similar. Numbers should use a tabular (monospaced) figure variant so columns of numbers align properly.

4. **The landing page is a sales page.** It needs to convert. The dApp is a utility. It needs to be invisible. These are different design problems and should feel slightly different within a shared design system.

5. **Protocol logos:** We reference Aave, Morpho, and Aerodrome in the allocation display. Use their official logos with permission. This is borrowed trust -- recognizable logos signal "we integrate with real protocols, not scam forks."

## 11. Handoff Notes for Frontend Engineer (fullstack-dhh)

1. **Wallet connection:** Use wagmi + viem + ConnectKit or RainbowKit. Prioritize Coinbase Wallet in the wallet list.

2. **Contract reads:** Use wagmi hooks (useReadContract, useWatchContractEvent) for real-time data. Poll share price and totalAssets every 15 seconds. Do not over-poll -- Base blocks are every 2 seconds but data does not change meaningfully per block.

3. **Transaction flow:** Use wagmi's useWriteContract with explicit status handling. Map every possible transaction status (idle, pending wallet confirmation, pending on-chain, confirmed, reverted) to the UI states defined above.

4. **Off-chain indexer:** We need an indexer (Goldsky, The Graph, or a custom lightweight indexer) for: user deposit/withdrawal history, cumulative yield earned per address, total unique depositor count, historical APY data. The dApp cannot compute these from pure contract reads.

5. **Error handling:** Intercept all contract revert reasons and map them to human-readable messages. Build a mapping table from the custom errors in `IYieldRouterVault.sol` to the error messages defined in Section 5.2.

6. **Permit2/EIP-2612:** Detect if the user has Permit2 approved globally. If yes, use the permit flow for single-tx deposits. If no, fall back to standard approve + deposit (but make it feel like one flow as described in Section 4.2).

7. **Mobile wallets:** Test the full flow on Coinbase Wallet mobile browser, MetaMask mobile browser, and via WalletConnect deep links. Mobile wallet UX is often the weak point of DeFi apps.

---

*This document reflects the interaction design analysis of interaction-cooper. It defines the complete user experience for Yield Router's landing page and dApp. The UI designer should use this as the behavioral specification for all screens, and the frontend engineer should use it as the interaction contract for implementation. All design decisions are grounded in the Primary Persona (Maya) and the principle that trust is the product.*
