---
name: harmonyvoice-small-iteration
description: Apply one small, tightly scoped follow-up iteration from a Figma selection in the HarmonyVoice repo. Use when the user wants only one to three specific UI adjustments without changing business rules, broad page structure, or unrelated files.
---

# HarmonyVoice Small Iteration

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

## Scope Discipline

- Only handle the one to three explicit change points for this round.
- Do not change business rules.
- Do not broadly restructure the page.
- Prefer adjusting existing components over adding parallel ones.
- Touch only files directly related to the requested iteration.

Suitable tasks include:

- information hierarchy tweaks
- empty or error state polish
- form layout adjustments
- one component state refinement
- mobile adaptation
- one dialog, list, or card alignment pass

## Workflow

1. Read the current implementation and the provided Figma selection.
2. Narrow the task to the exact requested changes before editing.
3. Implement the small iteration only.
4. Verify behavior before and after the change.
5. Confirm the original main flow still works.
6. Include a quick ASCII sketch if the UI arrangement itself changes.

## Output

Return:

- change list for this round
- verification results
- remaining differences not handled
- what you did
- what you verified
- what still needs confirmation
