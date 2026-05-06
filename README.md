# personal mdfile

This repository contains sanitized personal skill and agent instruction folders prepared for redistribution.

## Folders

- `codex-skills` (95 files, 47 Markdown): personal Codex skill folders.
- `growth-agents` (7 files, 7 Markdown): file-based Growth app agent instructions.
- `harmonyvoice-project-skills` (12 files, 6 Markdown): project-specific HarmonyVoice skill folders.
- `image-split-agent` (3 files, 3 Markdown): image decomposition agent workspace instructions.
- `openclaw-workspace-agents` (8 files, 8 Markdown): agent instruction files from the OpenClaw workspace.
- `openclaw-workspace-skills` (188 files, 53 Markdown): skill folders from the OpenClaw workspace.

Total packaged files: 313 folder files plus 3 top-level files.
Total Markdown files inside folders: 124.

## Packaging

Skill folders are synced as complete subfolders where possible, including referenced `references/`, `scripts/`, `assets/`, metadata, and license files. Build caches, dependency folders, VCS data, and bytecode caches are excluded.

## Sanitization

The copied files were scanned and rewritten for common sensitive patterns, including API keys, bearer tokens, GitHub/HuggingFace/npm/Slack tokens, email addresses, local Windows user paths, and project absolute paths.

Before public release, do one final human review for business-private names, internal URLs, account IDs, and project-specific confidential details that generic secret patterns cannot reliably detect.

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE).
