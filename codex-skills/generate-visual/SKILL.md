---
name: generate-visual
description: Create a Godot 4 visual-only scene layer from a mockup, screenshot, sketch, or explicit layout description. Use when Codex needs to turn an image or layout spec into a `blueprint.json`, `visual_layer.tscn`, placeholder assets, and integration files for an existing Godot project without adding gameplay logic.
---

# Generate Visual

Use this skill to build the visual side of a Godot scene while leaving gameplay code alone.

## Workflow

1. Inspect the provided image, sketch, screenshot, or layout description.
2. Write a `blueprint.json` in the working directory.
3. Run `python <this-skill>/scripts/generate_visual.py <blueprint.json> <output_dir>`.
4. Review the generated files and call out any assumptions that were necessary.
5. Integrate the output into the project only if the user asks for that step.

## Blueprint Shape

Use this structure:

```json
{
  "canvas": { "width": 1080, "height": 720 },
  "scene_type": "2d_topdown | 2d_platformer | 3d | ui",
  "background": {
    "color": "#0a0a2e"
  },
  "elements": [
    {
      "id": "Player",
      "type": "character",
      "description": "player avatar",
      "position": { "x": 200, "y": 360 },
      "size": { "w": 48, "h": 48 },
      "collision_shape": "circle",
      "collision_radius": 22
    },
    {
      "id": "ScoreDisplay",
      "type": "ui_label",
      "position": { "x": 900, "y": 20 },
      "size": { "w": 160, "h": 40 },
      "text": "Score: 0",
      "font_size": 28
    }
  ]
}
```

Keep `id` values stable and path-friendly because the generated node names come directly from them.

## Supported Element Types

| Type | Generated nodes |
| --- | --- |
| `character` | `Node2D -> Sprite2D + CollisionShape2D` |
| `enemy` | `Node2D -> Sprite2D + CollisionShape2D` |
| `collectible` | `Node2D -> Sprite2D + CollisionShape2D` |
| `hazard` | `Node2D -> Sprite2D + CollisionShape2D` |
| `obstacle` | `StaticBody2D -> Sprite2D + CollisionShape2D` |
| `platform` | `StaticBody2D -> Sprite2D + CollisionShape2D` |
| `decoration` | `Sprite2D` |
| `ui_label` | `Label` |
| `ui_button` | `Button` |
| `ui_panel` | `Panel` |
| `camera` | `Camera2D` |

## Output Contract

The script generates:

```text
output_dir/
|-- visual_layer.tscn
|-- INTEGRATION.md
|-- verify.sh
|-- verify.ps1
|-- assets/
|   |-- background.png
|   |-- *.png
|   `-- texture_map.json
`-- scripts/
    `-- verify_visual.gd
```

The scene structure is:

```text
VisualLayer
|-- Background
|-- Entities
|   `-- {id}
|       |-- Sprite2D
|       `-- CollisionShape2D
|-- UI
|   `-- {id}
`-- {camera nodes}
```

Use node paths like:

- `$VisualLayer/Entities/Player`
- `$VisualLayer/Entities/Player/Sprite2D`
- `$VisualLayer/UI/ScoreDisplay`

## Rules

- Do not add gameplay scripts, `project.godot`, or extra logic files.
- Keep the output compatible with Godot 4 scene format.
- Use placeholder art only; do not pretend generated PNGs are final production assets.
- If the image leaves layout details ambiguous, make the smallest reasonable assumption and say so.
- Respect the existing project structure if the user already has a destination folder layout.

## Script

Run the bundled script from this skill directory:

```powershell
python [CODEX_SKILLS_DIR]\generate-visual\scripts\generate_visual.py blueprint.json visual_output
```

If you are not on this machine, resolve the path relative to the skill folder and run the same script.
