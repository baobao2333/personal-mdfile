---
name: extract-ui-spec-from-html
description: 从 HTML、React、Tailwind、shadcn/ui、Lovable 导出、截图或 Web 原型中提取结构化 UI 实现规格，供后续在 Godot 中原生重建界面。适用于用户已有 Web 原型，需要组件树、设计 token、资源清单、状态与交互说明，而不是直接把 HTML 转成 Godot。
---

# Extract UI Spec From HTML

## Goal

Translate a web prototype into a compact, engine-neutral UI spec. Do not preserve DOM details for their own sake. Capture visual hierarchy, components, tokens, assets, states, and interactions that Godot can rebuild natively.

## Workflow

1. Inspect the HTML/React/CSS and any reference screenshots.
2. Identify the real screen structure: background, navigation, panels, repeated items, controls, overlays.
3. Extract design tokens that affect implementation: colors, type scale, spacing, radii, shadows, panel sizes, button sizes.
4. Map assets: images, icons, gradients, masks, and effects that should be baked or rebuilt.
5. Record interaction/state behavior: button actions, modal states, selected/disabled states, animations, transitions.
6. Produce a structured spec without adding new product behavior.

## What To Ignore

- Tailwind class names unless they reveal spacing, color, or layout intent.
- React component names that are only technical wrappers.
- CSS tricks that do not materially affect the visible UI.
- Web routing or application architecture unless it changes screen state.

## Output Format

Return Markdown with these sections:

```markdown
## Screen
- name:
- target size:
- primary action:

## Component Tree
```text
Screen
  Background
  TopBar
  MainPanel
    ...
```

## Design Tokens
| Token | Value | Notes |
| --- | --- | --- |

## Asset List
| Asset | Source | Godot use |
| --- | --- | --- |

## States And Interactions
| Element | State/action | Notes |
| --- | --- | --- |

## Godot Handoff Notes
- suggested Control/Container mapping
- effects to bake into textures
- effects safe for Theme/StyleBoxFlat
```

If the user asks for a machine-readable handoff, provide JSON with the same information. Keep the schema simple and local to the task.
