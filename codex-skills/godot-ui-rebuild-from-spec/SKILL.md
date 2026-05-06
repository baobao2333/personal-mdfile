---
name: godot-ui-rebuild-from-spec
description: 根据 UI 规格、截图或 HTML 提取出的交付说明，在 Godot 4 中用 Control 节点、Container、Theme、StyleBox、TextureRect、Button/TextureButton、Tween、AnimationPlayer 和 GDScript 重建原生 UI。适用于 Codex 需要在 Godot 项目里根据结构化规格实现游戏 UI，而不是嵌入 WebView 或直接转换 HTML/CSS。
---

# Godot UI Rebuild From Spec

## Goal

Implement the requested interface as Godot-native UI. Treat HTML, CSS, or screenshots as references, not source code to translate literally.

## Before Editing

1. Locate the Godot project root and existing UI scenes, themes, scripts, and asset conventions.
2. Read nearby scenes/scripts before creating files.
3. Reuse existing nodes, themes, resources, and naming patterns where they already exist.
4. Keep the change scoped to the requested screen or component.

## Mapping Guide

Use these defaults unless the project already has a stronger convention:

| Web idea | Godot default |
| --- | --- |
| `div` | Control, PanelContainer, MarginContainer |
| flex column | VBoxContainer |
| flex row | HBoxContainer |
| grid | GridContainer |
| absolute layer | Control anchors and offsets |
| image | TextureRect |
| button | Button or TextureButton |
| text | Label or RichTextLabel |
| modal | PopupPanel or custom Control scene |
| card/panel | PanelContainer + StyleBoxFlat or NinePatchRect |
| CSS animation | Tween or AnimationPlayer |
| click handler | `pressed` signal |
| route/page | scene switch or Control visibility |

## Implementation Rules

- Prefer Containers for layout. Use manual anchors/offsets for intentionally fixed overlays.
- Use Theme and StyleBoxFlat for reusable simple shapes.
- Use TextureRect, NinePatchRect, or baked textures for complex art, shadows, masks, and ornate panels.
- Do not introduce WebView, Chromium, HTML rendering, or CSS emulation unless the user explicitly asks.
- Do not create broad UI frameworks or generic converters.
- Keep GDScript logic minimal: state, signals, and screen-specific interactions only.
- Leave missing art as clearly named placeholders only when the asset is unavailable.

## Verification

Run the smallest relevant Godot validation available in the repo. If a scene can be opened or rendered by an existing command, use it. Otherwise, inspect the generated `.tscn`, scripts, and resource paths for broken references.

When UI/UX changed, include a quick ASCII sketch in the final response.
