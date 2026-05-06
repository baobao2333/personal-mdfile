---
name: harmonyvoice-acceptance-pass
description: Run a final acceptance pass across the HarmonyVoice PRD, Figma, and current implementation, then fix clear low-risk gaps. Use when the user wants a release-minded comparison of rules, structure, components, states, and copy without expanding scope into new features.
---

# HarmonyVoice Acceptance Pass

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

## Inputs

Use these three sources together:

1. PRD or acceptance criteria
2. latest Figma page or selection
3. current implementation in this repo

## Workflow

1. Compare PRD, Figma, and implementation for:
   - rules
   - page structure
   - components
   - state coverage
   - copy
2. Fix only clear, low-risk, unambiguous issues.
3. Do not expand scope or invent new requirements.
4. Move unclear items into a confirmation list instead of silently changing behavior.
5. Run the most relevant project checks before finishing.

## Output Format

Return results in this exact order. If the user requests Chinese headings, keep the same order and use the user's Chinese labels:

1. passed items
2. fixed items
3. known issues not fixed
4. open confirmations
5. checks to run before merge

Then append:

- what you did
- what you verified
- what still needs confirmation
