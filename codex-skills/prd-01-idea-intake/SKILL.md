---
name: prd-01-idea-intake
description: Convert a rough product idea, user feedback, or operations request into a structured product problem brief. Use at the very beginning of PRD work. Do not use to write rules, page specs, backend config, or final PRD.
---

# PRD Idea Intake

## Purpose

Turn an unclear idea into a structured brief that separates facts from assumptions. This skill expands the idea enough for product discussion, but it must not over-design the solution.

## Inputs

- Raw idea or request.
- Existing context, if available.
- User, operations, business, or internal stakeholder feedback.

## Process

1. Restate the idea in one paragraph.
2. Identify the likely problem being solved.
3. Identify who is affected.
4. Identify the trigger scenario.
5. Identify why this might matter now.
6. Separate known facts from assumptions.
7. List only the minimum questions that block the next step.

## Do not

- Do not write a full PRD.
- Do not create page-level specs.
- Do not invent backend systems.
- Do not add rankings, audits, permissions, AI automation, analytics, or notifications unless the idea directly requires them.
- Do not use vague claims such as “improve user experience” without naming the concrete friction.

## Output format

```markdown
# 00 Intake Brief: {Feature Name}

## 1. One-line idea
{One sentence}

## 2. Problem statement
{What problem is being solved, not what feature is being built}

## 3. Affected users / roles
| Role | Why affected | Current pain |
|---|---|---|

## 4. Trigger scenario
| Scenario | Trigger | Desired outcome |
|---|---|---|

## 5. Facts, assumptions, and unknowns
| Type | Item | Why it matters |
|---|---|---|
| Fact |  |  |
| Assumption |  |  |
| Decision needed |  |  |

## 6. Non-obvious risks noticed early
| Risk | Why it may matter | Later skill to handle |
|---|---|---|

## 7. Handoff to next stage
Recommended next skill: `prd-02-business-boundary`
```

## Definition of done

A good intake brief makes the idea debatable. It should expose the problem and uncertainty without pretending the solution is already fixed.
