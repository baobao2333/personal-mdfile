---
name: godot-ui-acceptance-pass
description: 对已实现的 Godot UI 做聚焦验收：将实现结果与源图、HTML 原型、UI 规格或设计意图对比，并修复明确、低风险的视觉或结构差距。适用于 Godot UI 场景已经实现后，用户希望校验、微调或对齐效果，但不扩大范围。
---

# Godot UI Acceptance Pass

## Goal

Compare the implemented Godot UI with its reference and make small, safe corrections. This is not a redesign pass.

## Workflow

1. Identify the reference: image, HTML prototype, extracted spec, or user notes.
2. Identify the implemented Godot scene(s), theme resources, scripts, and assets.
3. Compare hierarchy, spacing, alignment, text, colors, asset usage, states, and interactions.
4. Fix clear gaps that are local and low-risk.
5. Validate the changed scene with the smallest available project check.
6. Report what changed and what still needs human visual judgment.

## Fix Freely

- broken resource paths
- incorrect labels or obvious text mismatches
- missing obvious containers or wrong alignment
- spacing, size flags, anchors, or margins that clearly contradict the reference
- simple theme/style mismatches
- unconnected button signals when the intended local behavior is explicit

## Do Not Expand Scope

- Do not invent new screens, flows, or business rules.
- Do not redesign the art direction.
- Do not add generic UI systems.
- Do not replace native Godot UI with WebView.
- Do not rewrite unrelated scenes while polishing one screen.

## Final Response

Lead with findings or fixes. Include:

- changed files
- validation run
- remaining visual risks, if any
- a quick ASCII sketch when the layout changed
