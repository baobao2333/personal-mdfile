---
name: harmonyvoice-figma-to-code
description: Implement a selected Figma node or frame into the current HarmonyVoice repo with validation. Use when the user provides a Figma selection URL and wants that design translated into existing project components, tokens, layout patterns, routing, and state handling without inventing a parallel UI system.
---

# HarmonyVoice Figma To Code

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

## Required Figma Flow

1. Start with the exact selected node or frame.
2. Fetch design context for that exact selection.
3. If the context is truncated, fetch metadata first and then request only the needed node context.
4. Fetch a screenshot of the selected variant before coding so the visual target is explicit.
5. Reuse the current repo's components, tokens, style tools, layout patterns, routing, state handling, and data-fetch conventions.
6. Translate the design into existing code patterns instead of building a parallel implementation.
7. If Figma returns image or SVG assets, use them directly rather than swapping in placeholders or a new icon set.
8. If the task changes UI structure, include a quick ASCII sketch in the response so the intended layout is obvious.

## Validation

1. Compare the result against the Figma reference for spacing, hierarchy, layout, and responsive behavior.
2. Use browser automation when available to verify the key page behavior.
3. Continue fixing obvious mismatches found during validation.

## Output

Return:

- files changed
- differences from Figma
- what still needs to be added or clarified in Figma
- what you did
- what you verified
- what still needs confirmation
