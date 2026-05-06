---
name: harmonyvoice-code-to-figma
description: Capture the current runnable HarmonyVoice UI into Figma as editable draft screens. Use when a first implementation already exists and the user wants the live UI brought back into Figma for layout, copy, state, and interaction refinement rather than writing more production code first.
---

# HarmonyVoice Code To Figma

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

Use this skill after a runnable first draft exists. The goal is to create editable Figma material from the live interface, not to redesign the whole product from scratch.

## Workflow

1. Confirm the relevant screens can run locally.
2. Capture the live UI into a clearly named Figma file or page, such as `<feature> / Product Draft v1`.
3. Include at least:
   - main page
   - core action page
   - success state
   - empty state
   - error state
4. Mark temporary implementation areas as `needs visual refinement`.
5. Preserve screen names so later implementation can map back cleanly.

## Output

Return:

- target Figma file or page
- screens captured
- areas that still need manual Figma work
- what you did
- what you verified
- what still needs confirmation
