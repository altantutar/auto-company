# Common Statistical Pitfalls

## P-Value Misinterpretations

### Pitfall 1: P-Value = Probability Hypothesis is True
**Misconception:** p = .05 means 5% chance the null hypothesis is true.

**Reality:** P-value is the probability of observing data this extreme (or more) *if* the null hypothesis is true. It says nothing about the probability the hypothesis is true.

**Correct interpretation:** "If there were truly no effect, we would observe data this extreme only 5% of the time."

### Pitfall 2: Non-Significant = No Effect
**Misconception:** p > .05 proves there's no effect.

**Reality:** Absence of evidence ≠ evidence of absence. Non-significant results may indicate:
- Insufficient statistical power
- True effect too small to detect
- High variability
- Small sample size

**Better approach:**
- Report confidence intervals
- Conduct power analysis
- Consider equivalence testing

### Pitfall 3: Significant = Important
**Misconception:** Statistical significance means practical importance.

**Reality:** With large samples, trivial effects become "significant." A statistically significant 0.1 IQ point difference is meaningless in practice.

**Better approach:**
- Report effect sizes
- Consider practical significance
- Use confidence intervals

### Pitfall 4: P = .049 vs. P = .051
**Misconception:** These are meaningfully different because one crosses the .05 threshold.

**Reality:** These represent nearly identical evidence. The .05 threshold is arbitrary.

**Better approach:**
- Treat p-values as continuous measures of evidence
- Report exact p-values
- Consider context and prior evidence

### Pitfall 5: One-Tailed Tests Without Justification
**Misconception:** One-tailed tests are free extra power.

**Reality:** One-tailed tests assume effects can only go one direction, which is rarely true. They're often used to artificially boost significance.

**When appropriate:** Only when effects in one direction are theoretically impossible or equivalent to null.

## Multiple Comparisons Problems

### Pitfall 6: Multiple Testing Without Correction
**Problem:** Testing 20 hypotheses at p < .05 gives ~65% chance of at least one false positive.

**Examples:**
- Testing many outcomes
- Testing many subgroups
- Conducting multiple interim analyses
- Testing at multiple time points

**Solutions:**
- Bonferroni correction (divide α by number of tests)
- False Discovery Rate (FDR) control
- Prespecify primary outcome
- Treat exploratory analyses as hypothesis-generating

### Pitfall 7: Subgroup Analysis Fishing
**Problem:** Testing many subgroups until finding significance.

**Why problematic:**
- Inflates false positive rate
- Often reported without disclosure
- "Interaction was significant in women" may be random

**Solutions:**
- Prespecify subgroups
- Use interaction tests, not separate tests
- Require replication
- Correct for multiple comparisons

### Pitfall 8: Outcome Switching
**Problem:** Analyzing many outcomes, reporting only significant ones.

**Detection signs:**
- Secondary outcomes emphasized
- Incomplete outcome reporting
- Discrepancy between registration and publication

**Solutions:**
- Preregister all outcomes
- Report all planned outcomes
- Distinguish primary from secondary

## Sample Size and Power Issues

### Pitfall 9: Underpowered Studies
**Problem:** Small samples have low probability of detecting true effects.

**Consequences:**
- High false negative rate
- Significant results more likely to be false positives
- Overestimated effect sizes (when significant)

**Solutions:**
- Conduct a priori power analysis
- Aim for 80-90% power
- Consider effect size from prior research

### Pitfall 10: Post-Hoc Power Analysis
**Problem:** Calculating power after seeing results is circular and uninformative.

**Why useless:**
- Non-significant results always have low "post-hoc power"
- It recapitulates the p-value without new information

**Better approach:**
- Calculate confidence intervals
- Plan replication with adequate sample
- Conduct prospective power analysis for future studies

### Pitfall 11: Small Sample Fallacy
**Problem:** Trusting results from very small samples.

**Issues:**
