# ZIP Layer Editor

An Electron editor for repairing exported static HTML ZIP packages with Photoshop-like layer controls.

## Use

1. Run the source app with `npm start`.
2. Click `打开 ZIP` and choose an exported project ZIP such as `sweet-playlist-imagegen-delivery.zip`.
3. Select layers from the layer list or directly on the canvas.
4. Drag, resize, rotate, reorder, lock, hide, align, crop, and adjust layers.
5. Use `添加图片` or `添加文字` to add new poster elements.
6. Click `导出 ZIP` to save a repaired ZIP.

## Notes

- The editor keeps the original assets and writes the corrections back as inline styles in `index.html`.
- The app vendors JSZip locally to read and write ZIP files in the browser.
- No project files are uploaded anywhere; ZIP processing happens locally in the browser.
- The `Logs` button shows recent load/export diagnostics. The Electron app also writes a persistent log at `%APPDATA%/zip-layer-editor/logs/editor.log`.
- The default UI language is Simplified Chinese. Switch languages from the toolbar; the preference is saved locally.
- During active iteration, use source mode only. Do not run the packaging script until final acceptance.
