---
name: harmonyvoice-prd-breakdown
description: Break a PRD into a structured implementation draft for the current HarmonyVoice project before any coding starts. Use when the user provides a PRD, feature brief, acceptance notes, or scope statement and wants a page map, component list, state matrix, boundary cases, open questions, and a minimal first iteration scope without implementation.
---

# HarmonyVoice PRD Breakdown

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

Use this skill to turn product input into a first-pass implementation draft only. Do not write code, do not produce final visual design, and do not drift into long architecture essays.

## Inputs

Prefer the user's latest PRD or requirement block. When the user says "current project" and does not paste the PRD again, consult:

- `[PROJECT_ROOT]\HarmonyVoice-PRD-v1.1.md`
- `[PROJECT_ROOT]\HarmonyVoice-UI-Spec-v1.0.md`

## Workflow

1. Read the provided PRD and the surrounding project docs only far enough to understand scope, user roles, and key flows.
2. Compress the requirement into a product implementation draft for the first iteration.
3. Mark every inferred point under `Assumption` instead of presenting it as confirmed fact.
4. Keep the scope small and implementation-oriented.
5. Stop after the draft. Do not start coding.

## Output Format

Return the result in this exact order. If the user requests Chinese headings, keep the same order and use the user's Chinese labels:

1. goals
2. main user flow
3. page list
4. page goals and core actions
5. component list
6. state matrix
   - loading
   - empty
   - success
   - error
   - disabled
   - permission / role differences
7. key copy and hint placement
8. edge cases and exception paths
9. open questions
10. recommended first implementation slice

## Working Rules

- Keep the result directly usable as a first product draft.
- Prefer concise bullets over prose walls.
- If the PRD mixes MVP and later-stage ideas, trim the first iteration to the minimum coherent slice.
- If UI structure is discussed, include a small ASCII page map or flow sketch.
- Always end with:
  - what you did
  - what you verified
  - what still needs confirmation
