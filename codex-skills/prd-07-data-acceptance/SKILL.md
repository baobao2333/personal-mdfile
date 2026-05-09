---
name: prd-07-data-acceptance
description: Define success metrics, event tracking needs, and QA acceptance criteria for a PRD. Use after rules, flows, pages, and admin needs are drafted. Do not use to invent unrelated dashboards or vanity metrics.
---

# PRD Data & Acceptance

## Purpose

Make the PRD measurable and testable. This skill defines what “done” means for product, engineering, QA, and operations.

## Inputs

- Business boundary.
- Rule model.
- Flow model.
- Page spec.
- Admin config spec, if any.

## Process

1. Define success metrics tied to the business goal.
2. Define guardrail metrics tied to cost, abuse, failure, or operations burden.
3. Define event tracking only where decisions need data.
4. Define acceptance scenarios for happy path, branch paths, and exceptions.
5. Mark metrics that require data pipeline confirmation.

## Metrics rules

- Do not list metrics for decoration.
- Every metric must answer a product or operations question.
- If a metric does not affect a decision, remove it.
- Define denominator and time window where relevant.
- Separate product outcome metrics from system health and risk metrics.

## Acceptance rules

- Write cases from user-visible behavior and product rules.
- Include edge cases from the rule and flow models.
- Each case must have precondition, action, and expected result.
- Do not write implementation-specific test steps unless the user provided implementation constraints.

## Output format

```markdown
# 06 Data & Acceptance: {Feature Name}

## 1. Product success metrics
| Metric | Definition | Why needed | Decision it supports |
|---|---|---|---|

## 2. Guardrail metrics
| Metric | Definition | Risk monitored | Alert / review trigger |
|---|---|---|---|

## 3. Event tracking
| Event | Trigger timing | Key parameters | Success / failure distinction | Notes |
|---|---|---|---|---|

## 4. Acceptance criteria
| Case ID | Scenario | Precondition | Action | Expected result | Priority |
|---|---|---|---|---|---|

## 5. Data confirmation needed
| Item | Why uncertain | Who confirms |
|---|---|---|

## 6. Handoff to next stage
Recommended next skill: `prd-08-risk-debt-review`
```

## Definition of done

This stage is complete when QA can write test cases and the product manager can explain how launch success will be judged.
