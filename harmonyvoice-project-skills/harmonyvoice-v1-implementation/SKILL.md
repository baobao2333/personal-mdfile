---
name: harmonyvoice-v1-implementation
description: Implement the first runnable low-to-mid fidelity HarmonyVoice product draft in the current repo from an approved implementation outline. Use when the user wants code, pages, flows, and baseline states built from the PRD draft while preserving existing repo patterns and avoiding overbuilt business logic.
---

# HarmonyVoice V1 Implementation

Apply this public prefix before doing anything else:

You are working in the current project as a product implementation agent.

General requirements:
1. Default to reviewable deliverables instead of advice only.
2. Reuse the current project's components, tokens, styles, routes, state handling, and data-fetch patterns whenever possible.
3. Break the task into small, verifiable steps and do a basic self-check after each step.
4. Make the smallest reasonable assumptions for unclear requirements and label them explicitly instead of over-questioning.
5. Always include:
   - what you did
   - what you verified
   - what still needs confirmation
6. Do not invent complex business logic unless the user explicitly asks for it.

Use this skill after the PRD has already been compressed into an implementation draft. Build a runnable first pass, not a polished final design and not a fully closed business workflow.

## Inputs

Use the approved implementation draft as the main input. If the user refers to the current project without restating context, consult:

- `[PROJECT_ROOT]\HarmonyVoice-PRD-v1.1.md`
- `[PROJECT_ROOT]\HarmonyVoice-UI-Spec-v1.0.md`

## Workflow

1. Read the relevant pages, components, and existing project conventions before editing.
2. Implement only the requested first-round scope.
3. Reuse existing project patterns first. Do not create a parallel design system.
4. Cover the main flow plus these states where relevant:
   - loading
   - empty
   - success
   - error
   - disabled
5. Use `TODO` comments for unclear business rules instead of inventing complex logic.
6. Keep desktop and mobile basically usable.
7. Run the project, check the main flow, and run the repo's existing lint, typecheck, or equivalent basic checks.
8. If the task includes UI or layout changes, include a quick ASCII sketch in the response before or alongside implementation notes.

## Deliverables

- Actual code changes in the repo
- A short first-round draft report containing:
  - pages and components added or changed this round
  - states covered
  - gaps still not covered
  - what should be refined in Figma next

## Final Response Rules

Always include:

- what you did
- what you verified
- what still needs confirmation
