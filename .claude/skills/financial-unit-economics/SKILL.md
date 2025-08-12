---
name: financial-unit-economics
description: Use when evaluating business model viability, analyzing profitability per customer/product/transaction, validating startup metrics (CAC, LTV, payback period), making pricing decisions, assessing scalability, comparing business models, or when user mentions unit economics, CAC/LTV ratio, contribution margin, customer profitability, break-even analysis, or needs to determine if a business can be profitable at scale.
---
# Financial Unit Economics

## Table of Contents
- [Purpose](#purpose)
- [When to Use](#when-to-use)
- [What Is It?](#what-is-it)
- [Workflow](#workflow)
- [Common Patterns](#common-patterns)
- [Guardrails](#guardrails)
- [Quick Reference](#quick-reference)

## Purpose

Financial Unit Economics analyzes the profitability of individual units (customers, products, transactions) to determine if a business model is viable and scalable. This skill guides you through calculating key metrics (CAC, LTV, contribution margin), interpreting ratios, conducting cohort analysis, and making data-driven decisions about pricing, marketing spend, and growth strategy.

## When to Use

Use this skill when:

- **Business model validation**: Determine if startup/new product can be profitable at scale
- **Pricing decisions**: Set prices based on target margins and customer economics
- **Marketing spend**: Assess ROI of acquisition channels, optimize CAC
- **Growth strategy**: Decide when to scale (raise funding, increase spend) based on unit economics
- **Product roadmap**: Prioritize features that improve retention or reduce churn (increase LTV)
- **Investor pitch**: Demonstrate business model viability with CAC, LTV, payback metrics
- **Channel optimization**: Compare profitability across customer segments or acquisition channels
- **Subscription models**: Analyze recurring revenue, churn, cohort retention curves
- **Marketplace economics**: Model take rate, supply/demand side economics, liquidity
- **Financial planning**: Forecast cash flow, runway, burn rate based on unit economics

Trigger phrases: "unit economics", "CAC/LTV", "customer acquisition cost", "lifetime value", "contribution margin", "payback period", "customer profitability", "break-even", "cohort analysis", "is this business viable?"

## What Is It?

**Financial Unit Economics** is the practice of measuring profitability at the most granular level (per customer, product, or transaction) to understand if revenue from a single unit exceeds the cost to acquire and serve it.

**Core components**:
- **CAC (Customer Acquisition Cost)**: Total sales/marketing spend ÷ new customers acquired
- **LTV (Lifetime Value)**: Revenue from customer over their lifetime minus variable costs
- **Contribution Margin**: (Revenue - Variable Costs) ÷ Revenue (as %)
- **LTV/CAC Ratio**: Measures return on acquisition investment (target: 3:1 or higher)
- **Payback Period**: Months to recover CAC from customer revenue
- **Cohort Analysis**: Track metrics over time for customer groups (by acquisition month/channel)

**Quick example:**

**Scenario**: SaaS startup, subscription model ($100/month), analyzing unit economics.

**Metrics**:
- **CAC**: $20k marketing spend, 100 new customers → CAC = $200
- **Monthly revenue per customer**: $100
- **Variable costs**: $20/customer/month (hosting, support)
- **Gross margin**: ($100 - $20) / $100 = 80%
- **Monthly churn**: 5% → Average lifetime = 1 / 0.05 = 20 months
- **LTV**: $100 revenue × 20 months × 80% margin = $1,600
- **LTV/CAC**: $1,600 / $200 = 8:1 ✓ (healthy, >3:1)
- **Payback period**: $200 CAC ÷ ($100 × 80% margin) = 2.5 months ✓ (good, <12 months)

**Interpretation**: Strong unit economics. Each customer generates 8× their acquisition cost. Can profitably scale marketing spend. Payback in 2.5 months means fast capital recovery.

**Core benefits**:
- **Early warning system**: Detect unsustainable business models before scaling losses
- **Data-driven growth**: Know when unit economics justify increasing spend
- **Channel optimization**: Identify which acquisition channels are profitable
- **Pricing power**: Quantify impact of price changes on profitability
- **Investor confidence**: Demonstrate path to profitability with clear metrics

## Workflow

Copy this checklist and track your progress:

```
Unit Economics Analysis Progress:
- [ ] Step 1: Define the unit
- [ ] Step 2: Calculate CAC
- [ ] Step 3: Calculate LTV
- [ ] Step 4: Assess contribution margin
- [ ] Step 5: Analyze cohorts
- [ ] Step 6: Interpret and recommend
```

**Step 1: Define the unit**

What is your unit of analysis? (Customer, product SKU, transaction, subscription). See [resources/template.md](resources/template.md#unit-definition-template).

**Step 2: Calculate CAC**

Total acquisition costs (sales + marketing) ÷ new units acquired. Break down by channel if applicable. See [resources/template.md](resources/template.md#cac-calculation-template) and [resources/methodology.md](resources/methodology.md#1-customer-acquisition-cost-cac).

**Step 3: Calculate LTV**

Revenue over unit lifetime minus variable costs. Use cohort data for retention/churn. See [resources/template.md](resources/template.md#ltv-calculation-template) and [resources/methodology.md](resources/methodology.md#2-lifetime-value-ltv).

**Step 4: Assess contribution margin**

(Revenue - Variable Costs) ÷ Revenue. Identify levers to improve margin. See [resources/template.md](resources/template.md#contribution-margin-template) and [resources/methodology.md](resources/methodology.md#3-contribution-margin-analysis).

**Step 5: Analyze cohorts**

Track retention, LTV, payback by customer cohort (acquisition month/channel/segment). See [resources/template.md](resources/template.md#cohort-analysis-template) and [resources/methodology.md](resources/methodology.md#4-cohort-analysis).

**Step 6: Interpret and recommend**

Assess LTV/CAC ratio, payback period, cash efficiency. Make recommendations (pricing, channels, growth). See [resources/template.md](resources/template.md#interpretation-template) and [resources/methodology.md](resources/methodology.md#5-interpreting-unit-economics).

Validate using [resources/evaluators/rubric_financial_unit_economics.json](resources/evaluators/rubric_financial_unit_economics.json). **Minimum standard**: Average score ≥ 3.5.

## Common Patterns

**Pattern 1: SaaS Subscription Model**
- **Key metrics**: MRR, ARR, churn rate, LTV/CAC, payback period, CAC payback
- **Calculation**: LTV = ARPU × Gross Margin % ÷ Churn Rate
- **Benchmarks**: LTV/CAC ≥3:1, Payback <12 months, Churn <5% monthly (B2C) or <2% (B2B)
- **Levers**: Reduce churn (increase LTV), upsell/cross-sell (increase ARPU), optimize channels (reduce CAC)
- **When**: Subscription business, recurring revenue, retention critical

**Pattern 2: E-commerce / Transactional**
- **Key metrics**: AOV (Average Order Value), repeat purchase rate, contribution margin per order, CAC
