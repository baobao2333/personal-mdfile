---
name: prd-09-prd-compressor
description: Compress all PRD stage artifacts into a concise review-ready PRD for engineering, design, QA, and operations. Use at the end of the PRD workflow or when an AI-generated PRD is too long, vague, or mixed. Do not use to invent new requirements.
---

# PRD Compressor

## Purpose

Turn stage artifacts into a final PRD that is short enough to review and precise enough to execute.

This skill must compress, not expand.

## Inputs

- Intake brief.
- Business boundary.
- Rule model.
- Flow model.
- Page interaction spec.
- Admin config spec.
- Data and acceptance spec.
- Risk and debt review.

## Compression rules

1. Preserve decisions; remove brainstorming.
2. Preserve rules; remove slogans.
3. Preserve boundaries; remove speculative future features.
4. Preserve unknowns; do not fake certainty.
5. Move non-blocking details to appendix or later version.
6. Convert vague wording into explicit product language.
7. If a section is not actionable by engineering, design, QA, operations, or PM, delete or rewrite it.
8. Do not convert unresolved `Decision needed`, `Rule gap`, or `Needs history check` items into final decisions.
9. If blocking decisions remain, mark the PRD as not review-ready and list the exact owner or confirmation needed.

## Forbidden phrases unless immediately defined

- “提升用户体验”
- “增强互动感”
- “后台灵活配置”
- “系统智能判断”
- “根据用户行为推荐”
- “后续优化”
- “异常情况按默认处理”
- “具体由研发实现”
- “运营手动处理即可”

## Output format

```markdown
# PRD: {Feature Name}

## 0. Review conclusion
| Item | Conclusion |
|---|---|
| Version goal |  |
| This version does |  |
| This version does not do |  |
| Biggest decision needed |  |
| Biggest risk |  |

## 1. Background and problem
{Short, concrete problem statement}

## 2. Goals and non-goals
### Goals
| Goal | Success meaning |
|---|---|

### Non-goals
| Non-goal | Reason |
|---|---|

## 3. Scope
| Scope item | Included? | Notes |
|---|---:|---|

## 4. Roles and permissions
| Role | View | Operate | Restrictions |
|---|---|---|---|

## 5. Core rules
| Rule ID | Trigger | Condition | Result | User-facing behavior |
|---|---|---|---|---|

## 6. Flow summary
### User flow
{Mermaid or concise numbered flow}

### System judgment flow
{Mermaid or concise numbered flow}

### Key exceptions
| Exception | Handling |
|---|---|

## 7. Page and interaction requirements
| Page / component | Required content | Actions | States |
|---|---|---|---|

## 8. Admin and operations requirements
| Requirement | Must-have? | Notes |
|---|---:|---|

## 9. Data and acceptance
### Metrics
| Metric | Definition | Why needed |
|---|---|---|

### Acceptance criteria
| Case | Precondition | Action | Expected result |
|---|---|---|---|

## 10. Risks and decisions
| Type | Item | Owner | Status |
|---|---|---|---|

## Appendix: deferred items
| Item | Reason deferred | Revisit trigger |
|---|---|---|
```

## Definition of done

The final PRD is done when:

- Engineering can estimate without guessing intent.
- Design knows what information and states must be represented.
- QA can write test cases.
- Operations knows what it can and cannot control.
- PM can see every remaining sign-off item.
- The document no longer sounds like AI generated expansion.
