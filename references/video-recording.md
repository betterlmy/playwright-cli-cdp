# Video Recording

Examples use the Bash wrapper. On Windows PowerShell replace `bash scripts/playwright-cdp.sh` with `powershell -ExecutionPolicy Bypass -File scripts\playwright-cdp.ps1`.

Record browser automation as video (WebM, VP8/VP9 codec). Useful for demos, documentation, and acceptance evidence.

## Basic recording

```bash
bash scripts/playwright-cdp.sh -s=cdp video-start demo.webm
bash scripts/playwright-cdp.sh -s=cdp video-chapter "Getting Started" --description="Opening the homepage" --duration=2000
bash scripts/playwright-cdp.sh -s=cdp goto https://example.com
bash scripts/playwright-cdp.sh -s=cdp click e1
bash scripts/playwright-cdp.sh -s=cdp video-chapter "Filling Form" --description="Entering test data" --duration=2000
bash scripts/playwright-cdp.sh -s=cdp fill e2 "test input"
bash scripts/playwright-cdp.sh -s=cdp video-stop
```

## Scripted demo with overlays

For polished demos with precise timing and visual annotations, write a `run-code` script and execute it with `--filename`.

> `page.screencast` is a playwright-cli internal API injected onto the `Page` object when running inside `run-code`. It is not part of the standard `@playwright/test` public API and will not be available in regular Playwright test files.

1. Run through the scenario interactively to capture all locators and actions.
2. Write the script using `pressSequentially` with character delays and `waitForTimeout` pauses between steps.
3. Execute: `bash scripts/playwright-cdp.sh -s=cdp run-code --filename=demo-script.js`

Overlays are `pointer-events: none` and do not interfere with page interaction.

```js
async page => {
  await page.screencast.start({ path: 'video.webm', size: { width: 1280, height: 800 } });
  await page.goto('https://demo.playwright.dev/todomvc');

  await page.screencast.showChapter('Adding Todo Items', {
    description: 'We will add several items to the todo list.',
    duration: 2000,
  });

  await page.getByRole('textbox', { name: 'What needs to be done?' })
    .pressSequentially('Walk the dog', { delay: 60 });
  await page.getByRole('textbox', { name: 'What needs to be done?' }).press('Enter');
  await page.waitForTimeout(1000);

  await page.screencast.showChapter('Verifying Results', {
    description: 'Checking the item appeared in the list.',
    duration: 2000,
  });

  const annotation = await page.screencast.showOverlay(`
    <div style="position: absolute; top: 8px; right: 8px;
      padding: 6px 12px; background: rgba(0,0,0,0.7);
      border-radius: 8px; font-size: 13px; color: white;">
      Item added successfully
    </div>
  `);

  await page.getByRole('textbox', { name: 'What needs to be done?' })
    .pressSequentially('Buy groceries', { delay: 60 });
  await page.getByRole('textbox', { name: 'What needs to be done?' }).press('Enter');
  await page.waitForTimeout(1500);

  await annotation.dispose();

  const bounds = await page.getByText('Walk the dog').boundingBox();
  await page.screencast.showOverlay(`
    <div style="position: absolute;
      top: ${bounds.y}px; left: ${bounds.x}px;
      width: ${bounds.width}px; height: ${bounds.height}px;
      border: 2px solid red;">
    </div>
    <div style="position: absolute;
      top: ${bounds.y + bounds.height + 5}px;
      left: ${bounds.x + bounds.width / 2}px;
      transform: translateX(-50%);
      padding: 6px; background: #808080;
      border-radius: 10px; font-size: 14px; color: white;">
      Check it out, it is right above this text
    </div>
  `, { duration: 2000 });

  await page.screencast.stop();
}
```

## Overlay API

| Method | Use case |
|---|---|
| `page.screencast.showChapter(title, { description?, duration?, styleSheet? })` | Full-screen chapter card for stage transitions |
| `page.screencast.showOverlay(html, { duration? })` | Custom HTML overlay for callouts, labels, highlights |
| `disposable.dispose()` | Remove a sticky overlay that has no `duration` |
| `page.screencast.hideOverlays()` / `showOverlays()` | Temporarily hide or show all overlays |

## Tracing vs video

| Feature | Video | Tracing |
|---|---|---|
| Output | WebM file | Trace file (Trace Viewer) |
| Shows | Visual recording | DOM snapshots, network, console, actions |
| Best for | Demos, documentation | Debugging, analysis |
| File size | Larger | Smaller |
