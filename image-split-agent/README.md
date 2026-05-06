# Image Split Agent Workspace

This workspace has two parts:

```text
agent/
  instructions/        Agent prompt and workflow notes.
  input/               Source images sent into the splitting agent.
  output/
    html-projects/     Current runnable HTML asset deliveries.
    packages/          ZIP deliveries and repaired ZIP outputs.
    previews/          Contact sheets and preview images.
  archive/
    legacy-html/       Old HTML deliveries kept for reference.

editor/
  apps/
    zip-layer-editor/  Electron editor source app.
  releases/            Packaged editor builds.
```

Keep generated agent deliveries under `agent/output/`.
Keep editor source and builds under `editor/`.
