---
name: xiaohongshu-mcp
description: Disabled on this machine. Do not use the local Xiaohongshu MCP chain; use the built-in xiaohongshu CLI tool instead.
---

# xiaohongshu-mcp

This skill is intentionally disabled in this environment.

Rules:

1. Do not probe `localhost:18060`.
2. Do not start or use any `xiaohongshu-mcp` service.
3. Do not request QR login for the MCP path.
4. Use the built-in OpenClaw `xiaohongshu` tool, which wraps `xiaohongshu-cli` / `xhs`, for all Xiaohongshu reads.
5. If the user asks to publish or interact, explain that the MCP chain is disabled here and stay on the CLI path unless the user explicitly asks to re-enable MCP.

CLI fallback:

- Check auth: `xhs status --json`
- Current account: `xhs whoami --json`
- Feed: `xhs feed --json`
- Search: `xhs search <query> --json`
- Note detail: `xhs read <id-or-url> --json`
- User: `xhs user <id> --json`
- User posts: `xhs user-posts <id> --json`

When this skill is referenced, immediately state that the MCP chain is disabled on this machine and continue with the CLI fallback.
