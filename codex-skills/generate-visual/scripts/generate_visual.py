#!/usr/bin/env python3
"""
Generate a visual-only Godot scene layer plus placeholder assets.

Usage:
  python generate_visual.py blueprint.json output_dir
"""

import json
import os
import random
import sys


def short_uid():
    return str(random.randint(1000000000, 9999999999))


class VisualTSCNBuilder:
    """Build a visual-only .tscn without gameplay scripts."""

    def __init__(self, canvas_w=1080, canvas_h=720):
        self.canvas_w = canvas_w
        self.canvas_h = canvas_h
        self.ext_resources = []
        self.nodes = []
        self.load_steps = 1

    def add_texture(self, path):
        resource_id = f"res_{self.load_steps}"
        self.ext_resources.append(
            {
                "id": resource_id,
                "type": "Texture2D",
                "path": path,
                "uid": short_uid(),
            }
        )
        self.load_steps += 1
        return resource_id

    def add_node(self, name, node_type, parent="", props=None):
        self.nodes.append(
            {
                "name": name,
                "type": node_type,
                "parent": parent,
                "props": props or {},
            }
        )
        return f"{parent}/{name}" if parent else name

    def build(self):
        lines = [
            f'[gd_scene load_steps={self.load_steps} format=3 uid="uid://{short_uid()}"]',
            "",
        ]

        for resource in self.ext_resources:
            lines.append(
                f'[ext_resource type="{resource["type"]}" '
                f'uid="uid://{resource["uid"]}" '
                f'path="{resource["path"]}" '
                f'id="{resource["id"]}"]'
            )
        lines.append("")

        for node in self.nodes:
            parts = []
            for key, value in node["props"].items():
                if isinstance(value, str) and value.startswith("ExtResource"):
                    parts.append(f"{key}={value}")
                elif isinstance(value, str):
                    parts.append(f'{key}="{value}"')
                elif isinstance(value, bool):
                    parts.append(f'{key}={"true" if value else "false"}')
                else:
                    parts.append(f"{key}={value}")

            parent_attr = f' parent="{node["parent"]}"' if node["parent"] else ""
            props_str = (" " + " ".join(parts)) if parts else ""
            lines.append(
                f'[node name="{node["name"]}" type="{node["type"]}"{parent_attr}{props_str}]'
            )
            lines.append("")

        return "\n".join(lines)


def create_png(width, height, color_rgba):
    import struct
    import zlib

    def chunk(chunk_type, data):
        content = chunk_type + data
        return (
            struct.pack(">I", len(data))
            + content
            + struct.pack(">I", zlib.crc32(content) & 0xFFFFFFFF)
        )

    header = b"\x89PNG\r\n\x1a\n"
    ihdr = chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    row = b"\x00" + bytes(color_rgba) * width
    idat = chunk(b"IDAT", zlib.compress(row * height))
    iend = chunk(b"IEND", b"")
    return header + ihdr + idat + iend


def create_circle_png(radius, color_rgba):
    import struct
    import zlib

    size = radius * 2
    pixels = []
    for y in range(size):
        row = b"\x00"
        for x in range(size):
            dx = x - radius + 0.5
            dy = y - radius + 0.5
            if dx * dx + dy * dy <= radius * radius:
                row += bytes(color_rgba)
            else:
                row += b"\x00\x00\x00\x00"
        pixels.append(row)

    def chunk(chunk_type, data):
        content = chunk_type + data
        return (
            struct.pack(">I", len(data))
            + content
            + struct.pack(">I", zlib.crc32(content) & 0xFFFFFFFF)
        )

    header = b"\x89PNG\r\n\x1a\n"
    ihdr = chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
    idat = chunk(b"IDAT", zlib.compress(b"".join(pixels)))
    iend = chunk(b"IEND", b"")
    return header + ihdr + idat + iend


COLOR_PRESETS = {
    "character": (70, 130, 255, 255),
    "enemy": (255, 60, 60, 255),
    "collectible": (255, 215, 0, 255),
    "obstacle": (100, 100, 100, 255),
    "platform": (80, 180, 80, 255),
    "hazard": (255, 0, 100, 255),
    "decoration": (150, 150, 150, 200),
    "spawner": (200, 100, 255, 128),
}

SKIP_TYPES = {"ui_label", "ui_button", "ui_panel", "camera", "light", "tilemap"}


def hex_to_rgba(hex_color):
    value = hex_color.lstrip("#")
    return (int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16), 255)


def generate_assets(blueprint, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    texture_map = {}
    canvas = blueprint.get("canvas", {"width": 1080, "height": 720})

    background = blueprint.get("background", {})
    with open(os.path.join(output_dir, "background.png"), "wb") as file:
        file.write(
            create_png(
                canvas["width"],
                canvas["height"],
                hex_to_rgba(background.get("color", "#1a1a2e")),
            )
        )
    texture_map["background"] = "background.png"

    for element in blueprint.get("elements", []):
        element_type = element["type"]
        element_id = element["id"]
        if element_type in SKIP_TYPES:
            continue

        color = COLOR_PRESETS.get(element_type, (200, 200, 200, 255))
        width = max(8, element.get("size", {}).get("w", 32))
        height = max(8, element.get("size", {}).get("h", 32))
        radius = min(width, height) // 2
        image = (
            create_circle_png(radius, color)
            if element.get("collision_shape") == "circle"
            else create_png(width, height, color)
        )

        filename = f"{element_id}.png"
        with open(os.path.join(output_dir, filename), "wb") as file:
            file.write(image)
        texture_map[element_id] = filename

    with open(
        os.path.join(output_dir, "texture_map.json"), "w", encoding="utf-8"
    ) as file:
        json.dump(texture_map, file, indent=2, ensure_ascii=False)

    return texture_map


def build_visual_scene(blueprint, texture_map, output_path):
    canvas = blueprint.get("canvas", {"width": 1080, "height": 720})
    builder = VisualTSCNBuilder(canvas["width"], canvas["height"])

    root = builder.add_node("VisualLayer", "Node2D")

    if "background" in texture_map:
        background_texture = builder.add_texture(
            f'res://assets/{texture_map["background"]}'
        )
        builder.add_node(
            "Background",
            "Sprite2D",
            root,
            {
                "texture": f'ExtResource("{background_texture}")',
                "position": f'Vector2({canvas["width"] // 2}, {canvas["height"] // 2})',
            },
        )

    entities = builder.add_node("Entities", "Node2D", root)
    ui = builder.add_node("UI", "CanvasLayer", root)

    for element in blueprint.get("elements", []):
        element_type = element["type"]
        element_id = element["id"]
        position = element.get("position", {"x": 0, "y": 0})
        size = element.get("size", {"w": 32, "h": 32})
        collision_shape = element.get("collision_shape", "rect")
        collision_radius = element.get(
            "collision_radius", min(size["w"], size["h"]) // 2
        )

        if element_type in ("character", "enemy", "collectible", "hazard"):
            container = builder.add_node(
                element_id,
                "Node2D",
                entities,
                {"position": f'Vector2({position["x"]}, {position["y"]})'},
            )

            if element_id in texture_map:
                texture = builder.add_texture(f'res://assets/{texture_map[element_id]}')
                builder.add_node(
                    "Sprite2D",
                    "Sprite2D",
                    container,
                    {"texture": f'ExtResource("{texture}")'},
                )

            if collision_shape == "circle":
                builder.add_node(
                    "CollisionShape2D",
                    "CollisionShape2D",
                    container,
                    {
                        "shape": f"CircleShape2D( radius={collision_radius})",
                        "disabled": True,
                    },
                )
            else:
                builder.add_node(
                    "CollisionShape2D",
                    "CollisionShape2D",
                    container,
                    {
                        "shape": f'RectangleShape2D( size=Vector2({size["w"]}, {size["h"]}))',
                        "disabled": True,
                    },
                )

        elif element_type in ("obstacle", "platform"):
            container = builder.add_node(
                element_id,
                "StaticBody2D",
                entities,
                {
                    "position": f'Vector2({position["x"]}, {position["y"]})',
                    "collision_layer": 0,
                    "collision_mask": 0,
                },
            )
            if element_id in texture_map:
                texture = builder.add_texture(f'res://assets/{texture_map[element_id]}')
                builder.add_node(
                    "Sprite2D",
                    "Sprite2D",
                    container,
                    {"texture": f'ExtResource("{texture}")'},
                )
            builder.add_node(
                "CollisionShape2D",
                "CollisionShape2D",
                container,
                {
                    "shape": f'RectangleShape2D( size=Vector2({size["w"]}, {size["h"]}))'
                },
            )

        elif element_type == "decoration" and element_id in texture_map:
            texture = builder.add_texture(f'res://assets/{texture_map[element_id]}')
            builder.add_node(
                element_id,
                "Sprite2D",
                entities,
                {
                    "texture": f'ExtResource("{texture}")',
                    "position": f'Vector2({position["x"]}, {position["y"]})',
                },
            )

        elif element_type == "ui_label":
            builder.add_node(
                element_id,
                "Label",
                ui,
                {
                    "position": f'Vector2({position["x"]}, {position["y"]})',
                    "size": f'Vector2({size["w"]}, {size["h"]})',
                    "text": element.get("text", ""),
                    "theme_override_font_sizes/font_size": element.get("font_size", 20),
                },
            )

        elif element_type == "ui_button":
            builder.add_node(
                element_id,
                "Button",
                ui,
                {
                    "position": f'Vector2({position["x"]}, {position["y"]})',
                    "size": f'Vector2({size["w"]}, {size["h"]})',
                    "text": element.get("text", "Button"),
                },
            )

        elif element_type == "ui_panel":
            builder.add_node(
                element_id,
                "Panel",
                ui,
                {
                    "position": f'Vector2({position["x"]}, {position["y"]})',
                    "size": f'Vector2({size["w"]}, {size["h"]})',
                },
            )

        elif element_type == "camera":
            zoom = element.get("zoom", 1)
            builder.add_node(
                element_id,
                "Camera2D",
                root,
                {
                    "position": f'Vector2({position["x"]}, {position["y"]})',
                    "zoom": f"Vector2({zoom}, {zoom})",
                },
            )

    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as file:
        file.write(builder.build())
    print(f"[OK] Visual scene: {output_path} ({len(builder.nodes)} nodes)")
    return output_path


def generate_integration_guide(blueprint, output_dir):
    elements = blueprint.get("elements", [])
    characters = [element for element in elements if element["type"] in ("character", "enemy")]
    collectibles = [
        element for element in elements if element["type"] in ("collectible", "hazard")
    ]
    ui_elements = [element for element in elements if element["type"].startswith("ui_")]

    lines = [
        "# Integration Guide",
        "",
        "## Copy files",
        "",
        "```text",
        "your-project/",
        "|-- scenes/",
        "|   `-- visual_layer.tscn",
        "`-- assets/",
        "    `-- *.png",
        "```",
        "",
        "## Instantiate the scene",
        "",
        "```gdscript",
        'var visual = preload("res://scenes/visual_layer.tscn").instantiate()',
        "add_child(visual)",
        "```",
        "",
        "## Reference nodes",
        "",
        "| Purpose | Path | Example |",
        "| --- | --- | --- |",
    ]

    for element in characters:
        element_id = element["id"]
        lines.append(
            f"| {element.get('description', element_id)} visual | "
            f"`$VisualLayer/Entities/{element_id}/Sprite2D` | "
            f"`var sprite = $VisualLayer/Entities/{element_id}/Sprite2D` |"
        )
        lines.append(
            f"| {element.get('description', element_id)} collision | "
            f"`$VisualLayer/Entities/{element_id}/CollisionShape2D` | "
            f"`$VisualLayer/Entities/{element_id}/CollisionShape2D.disabled = false` |"
        )

    for element in collectibles:
        element_id = element["id"]
        lines.append(
            f"| {element.get('description', element_id)} | "
            f"`$VisualLayer/Entities/{element_id}` | "
            f"`$VisualLayer/Entities/{element_id}.visible = false` |"
        )

    for element in ui_elements:
        element_id = element["id"]
        lines.append(
            f"| {element.get('description', element_id)} | "
            f"`$VisualLayer/UI/{element_id}` | "
            f'`$VisualLayer/UI/{element_id}.text = "Updated"` |'
        )

    lines.extend(
        [
            "",
            "## Typical reparent pattern",
            "",
            "```gdscript",
            "func _ready():",
            '    var visual_player = $"../VisualLayer/Entities/Player"',
            '    var sprite = visual_player.get_node("Sprite2D")',
            '    var collision = visual_player.get_node("CollisionShape2D")',
            "    sprite.reparent(self)",
            "    collision.reparent(self)",
            "    collision.disabled = false",
            "    visual_player.queue_free()",
            "```",
            "",
            "## Notes",
            "",
            "1. Collision shapes are disabled by default except for static obstacles and platforms.",
            "2. Node names are copied directly from `blueprint.json` IDs.",
            "3. Placeholder textures are for layout only and should be replaced with final art.",
            "4. The generated scene targets Godot 4 format.",
            "",
        ]
    )

    guide_path = os.path.join(output_dir, "INTEGRATION.md")
    with open(guide_path, "w", encoding="utf-8") as file:
        file.write("\n".join(lines))
    print(f"[OK] Integration guide: {guide_path}")
    return guide_path


def generate_verify_script(blueprint, output_dir):
    expected_nodes = [
        ("VisualLayer", "Node2D", ""),
        ("Background", "Sprite2D", "VisualLayer"),
        ("Entities", "Node2D", "VisualLayer"),
        ("UI", "CanvasLayer", "VisualLayer"),
    ]

    for element in blueprint.get("elements", []):
        element_id = element["id"]
        element_type = element["type"]
        parent = "VisualLayer/UI" if element_type.startswith("ui_") else "VisualLayer/Entities"

        if element_type in ("character", "enemy", "collectible", "hazard"):
            expected_nodes.append((element_id, "Node2D", parent))
            expected_nodes.append((f"{element_id}/Sprite2D", "Sprite2D", f"{parent}/{element_id}"))
            expected_nodes.append(
                (f"{element_id}/CollisionShape2D", "CollisionShape2D", f"{parent}/{element_id}")
            )
        elif element_type in ("obstacle", "platform"):
            expected_nodes.append((element_id, "StaticBody2D", parent))
            expected_nodes.append((f"{element_id}/Sprite2D", "Sprite2D", f"{parent}/{element_id}"))
            expected_nodes.append(
                (f"{element_id}/CollisionShape2D", "CollisionShape2D", f"{parent}/{element_id}")
            )
        elif element_type == "decoration":
            expected_nodes.append((element_id, "Sprite2D", parent))
        elif element_type == "ui_label":
            expected_nodes.append((element_id, "Label", parent))
        elif element_type == "ui_button":
            expected_nodes.append((element_id, "Button", parent))
        elif element_type == "ui_panel":
            expected_nodes.append((element_id, "Panel", parent))
        elif element_type == "camera":
            expected_nodes.append((element_id, "Camera2D", "VisualLayer"))

    checks = []
    for name, node_type, parent in expected_nodes:
        full_path = f"{parent}/{name}" if parent else name
        checks.append(f'    _check("{full_path}", "{node_type}")')

    gdscript = "\n".join(
        [
            "@tool",
            "extends SceneTree",
            "",
            'var visual_layer_scene := "res://scenes/visual_layer.tscn"',
            "var visual_root: Node",
            "var passed := 0",
            "var failed := 0",
            "var errors: Array[String] = []",
            "",
            "func _init():",
            '    print("\\n============================================================")',
            '    print("Visual Layer Verification")',
            '    print("============================================================\\n")',
            "    _check_file(visual_layer_scene)",
            "    var scene = load(visual_layer_scene)",
            "    if not scene:",
            '        _fail("Cannot load scene: " + visual_layer_scene)',
            "        _summary()",
            "        quit(1)",
            "        return",
            "    visual_root = scene.instantiate()",
            "    if not visual_root:",
            '        _fail("Cannot instantiate scene")',
            "        _summary()",
            "        quit(1)",
            "        return",
            '    print("Checking nodes:")',
            *checks,
            '    print("\\nChecking textures:")',
            "    _check_textures(visual_root)",
            "    visual_root.free()",
            "    _summary()",
            "",
            "func _check(path: String, expected_type: String):",
            "    var node = _find_node(path)",
            "    if not node:",
            '        _fail("Missing node: " + path)',
            "        return",
            "    if node.get_class() != expected_type and not _is_type_compatible(node, expected_type):",
            '        _fail("Type mismatch: " + path + " (expected " + expected_type + ", got " + node.get_class() + ")")',
            "        return",
            '    _pass(path + " [" + expected_type + "]")',
            "",
            "func _find_node(path: String) -> Node:",
            "    if not visual_root:",
            "        return null",
            "    return visual_root.get_node_or_null(NodePath(path))",
            "",
            "func _is_type_compatible(node: Node, expected_type: String) -> bool:",
            "    match expected_type:",
            '        "Node2D": return node is Node2D',
            '        "Sprite2D": return node is Sprite2D',
            '        "CollisionShape2D": return node is CollisionShape2D',
            '        "StaticBody2D": return node is StaticBody2D',
            '        "CanvasLayer": return node is CanvasLayer',
            '        "Label": return node is Label',
            '        "Button": return node is Button',
            '        "Panel": return node is Panel',
            '        "Camera2D": return node is Camera2D',
            "        _: return node.get_class() == expected_type",
            "",
            "func _check_textures(node: Node):",
            "    if node is Sprite2D and node.texture:",
            "        var texture = node.texture",
            "        if texture.get_image():",
            '            _pass(node.name + " texture loaded")',
            "        else:",
            '            _fail(node.name + " texture failed to load image data")',
            "    elif node is Sprite2D and not node.texture:",
            '        _warn(node.name + " has no texture assigned")',
            "    for child in node.get_children():",
            "        _check_textures(child)",
            "",
            "func _check_file(path: String):",
            "    if FileAccess.file_exists(path):",
            '        _pass("File exists: " + path)',
            "    else:",
            '        _fail("File missing: " + path)',
            "",
            "func _pass(message: String):",
            "    passed += 1",
            '    print("  [OK] " + message)',
            "",
            "func _fail(message: String):",
            "    failed += 1",
            "    errors.append(message)",
            '    print("  [FAIL] " + message)',
            "",
            "func _warn(message: String):",
            '    print("  [WARN] " + message)',
            "",
            "func _summary():",
            '    print("\\n============================================================")',
            "    if failed == 0:",
            '        print("[OK] ALL PASSED (" + str(passed) + " checks)")',
            "    else:",
            '        print("[FAIL] " + str(failed) + " failed / " + str(passed) + " passed")',
            '        print("\\nErrors:")',
            "        for error in errors:",
            '            print("  - " + error)',
            '    print("============================================================")',
            "    quit(0 if failed == 0 else 1)",
            "",
        ]
    )

    scripts_dir = os.path.join(output_dir, "scripts")
    os.makedirs(scripts_dir, exist_ok=True)

    script_path = os.path.join(scripts_dir, "verify_visual.gd")
    with open(script_path, "w", encoding="utf-8") as file:
        file.write(gdscript)
    print(f"[OK] Verify script: {script_path}")

    shell_script = """#!/bin/bash
GODOT="${1:-godot}"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$PROJECT_DIR/../scripts"

mkdir -p "$TARGET_DIR"
cp "$PROJECT_DIR/scripts/verify_visual.gd" "$TARGET_DIR/"

echo "Verifying visual layer in: $PROJECT_DIR"
"$GODOT" --headless --path "$PROJECT_DIR/.." -s "res://scripts/verify_visual.gd"
"""
    shell_path = os.path.join(output_dir, "verify.sh")
    with open(shell_path, "w", encoding="utf-8", newline="\n") as file:
        file.write(shell_script)
    os.chmod(shell_path, 0o755)

    powershell_script = """param(
    [string]$Godot = "godot"
)

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Join-Path (Join-Path $ProjectDir "..") "scripts"

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Copy-Item (Join-Path $ProjectDir "scripts\\verify_visual.gd") $TargetDir -Force

Write-Host "Verifying visual layer in: $ProjectDir"
& $Godot --headless --path (Join-Path $ProjectDir "..") -s "res://scripts/verify_visual.gd"
exit $LASTEXITCODE
"""
    powershell_path = os.path.join(output_dir, "verify.ps1")
    with open(powershell_path, "w", encoding="utf-8", newline="\n") as file:
        file.write(powershell_script)
    print(f"[OK] Verify wrappers: {shell_path}, {powershell_path}")

    return script_path


def run(blueprint_path, output_dir):
    print("============================================================")
    print("Godot Visual Layer Generator")
    print("============================================================")

    with open(blueprint_path, "r", encoding="utf-8-sig") as file:
        blueprint = json.load(file)

    assets_dir = os.path.join(output_dir, "assets")
    os.makedirs(assets_dir, exist_ok=True)

    print("\n[1/4] Generating assets...")
    texture_map = generate_assets(blueprint, assets_dir)

    print("\n[2/4] Generating visual scene...")
    scene_path = os.path.join(output_dir, "visual_layer.tscn")
    build_visual_scene(blueprint, texture_map, scene_path)

    print("\n[3/4] Generating integration guide...")
    generate_integration_guide(blueprint, output_dir)

    print("\n[4/4] Generating verification scripts...")
    generate_verify_script(blueprint, output_dir)

    print("\n============================================================")
    print("[OK] Done")
    print("============================================================")
    print(f"Output: {output_dir}")


if __name__ == "__main__":
    blueprint = sys.argv[1] if len(sys.argv) > 1 else "blueprint.json"
    output = sys.argv[2] if len(sys.argv) > 2 else "visual_output"
    run(blueprint, output)
