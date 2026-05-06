---
name: ai-game-ui-image-brief
description: 为后续要落到 Godot 原生 UI 的游戏界面准备高质量图片生成 brief。适用于用户想用 OpenAI 或其他图片模型生成移动游戏 UI 视觉稿、风格方向图、界面 mockup、面板、图标或便于切图的参考图，再进入 HTML 原型或 Godot 实现之前。
---

# AI Game UI Image Brief

## Goal

Create image-generation prompts that produce beautiful UI references without making the later Godot build painful. Bias toward separable game UI assets, clear hierarchy, and layout that can become Control nodes, Containers, Theme styles, and TextureRects.

## Workflow

1. Identify the target screen, platform, aspect ratio, and core user action.
2. Ask only for missing essentials if the screen purpose or art style is unclear.
3. Write a prompt that describes the final image and adds Godot-friendly constraints.
4. Include a negative prompt that avoids overly web-specific effects.
5. Provide a short asset-slicing checklist for the next step.

## Prompt Constraints

Prefer:

- mobile game UI, clear component boundaries, readable buttons, game UI asset style
- 9-slice friendly panels, simple layered assets, clean icon slots
- separated background, panels, buttons, icons, character art, badges, status bars
- stable navigation areas, obvious tap targets, consistent spacing
- moderate shadows, simple gradients, readable typography placeholders

Avoid:

- complex glassmorphism, heavy backdrop blur, browser-specific CSS filters
- dense responsive web card grids, tiny text, overlapping decorative layers
- effects that require DOM/CSS behavior to look correct
- full-screen flattened art where panels and controls cannot be separated

## Output Format

Return:

```text
Image prompt:
...

Negative prompt:
...

Suggested assets to slice:
- background
- primary panel
- secondary panel
- buttons
- icons
- character/decoration

Implementation notes:
- likely Godot node families
- effects to bake into images
- effects safe to rebuild with Theme/StyleBoxFlat
```

Keep the result practical. The image is a visual target, not an engine-ready source file.
