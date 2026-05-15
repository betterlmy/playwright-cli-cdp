# Custom Playwright Code

Examples use the Bash wrapper. On Windows PowerShell replace `bash scripts/playwright-cdp.sh` with `powershell -ExecutionPolicy Bypass -File scripts\playwright-cdp.ps1`.

Use `run-code` to execute arbitrary Playwright code for scenarios the CLI commands do not cover directly.

## Syntax

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  // Playwright code here
  // page.context() is available for browser context operations
}"
```

Load from a file instead of an inline string:

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code --filename=./my-script.js
```

The argument must be a single function expression. `import`, `export`, and `require` are not supported.

## Geolocation

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.context().grantPermissions(['geolocation']);
  await page.context().setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
}"

# London
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.context().grantPermissions(['geolocation']);
  await page.context().setGeolocation({ latitude: 51.5074, longitude: -0.1278 });
}"

# Clear permissions
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.context().clearPermissions();
}"
```

## Permissions

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.context().grantPermissions([
    'geolocation',
    'notifications',
    'camera',
    'microphone'
  ]);
}"

# Grant to a specific origin
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.context().grantPermissions(['clipboard-read'], {
    origin: 'https://example.com'
  });
}"
```

## Media emulation

```bash
# Dark mode
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.emulateMedia({ colorScheme: 'dark' });
}"

# Reduced motion
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.emulateMedia({ reducedMotion: 'reduce' });
}"

# Print media
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.emulateMedia({ media: 'print' });
}"
```

## Wait strategies

```bash
# Wait for network idle
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.waitForLoadState('networkidle');
}"

# Wait for an element to disappear
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.locator('.loading').waitFor({ state: 'hidden' });
}"

# Wait for a JavaScript condition
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.waitForFunction(() => window.appReady === true);
}"

# Wait with explicit timeout
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.locator('.result').waitFor({ timeout: 10000 });
}"
```

## Frames and iframes

```bash
# Interact with an iframe
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  const frame = page.locator('iframe#my-iframe').contentFrame();
  await frame.locator('button').click();
}"

# List all frame URLs
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  return page.frames().map(f => f.url());
}"
```

## File download

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  const downloadPromise = page.waitForEvent('download');
  await page.getByRole('link', { name: 'Download' }).click();
  const download = await downloadPromise;
  await download.saveAs('./downloaded-file.pdf');
  return download.suggestedFilename();
}"
```

## Clipboard

```bash
# Read clipboard (requires permission)
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.context().grantPermissions(['clipboard-read']);
  return await page.evaluate(() => navigator.clipboard.readText());
}"

# Write to clipboard
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.evaluate(text => navigator.clipboard.writeText(text), 'Hello clipboard!');
}"
```

## Page information

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  return {
    title: await page.title(),
    url: page.url(),
    viewport: page.viewportSize()
  };
}"

# Get full page HTML
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  return await page.content();
}"
```

## JavaScript evaluation

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  return await page.evaluate(() => ({
    userAgent: navigator.userAgent,
    language: navigator.language,
    cookiesEnabled: navigator.cookieEnabled
  }));
}"

# Pass arguments into evaluate
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  const multiplier = 5;
  return await page.evaluate(m => document.querySelectorAll('li').length * m, multiplier);
}"
```

## Error handling

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  try {
    await page.getByRole('button', { name: 'Submit' }).click({ timeout: 1000 });
    return 'clicked';
  } catch (e) {
    return 'element not found';
  }
}"
```

## Multi-page data collection

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  const results = [];
  for (let i = 1; i <= 3; i++) {
    await page.goto(\`https://example.com/page/\${i}\`);
    const items = await page.locator('.item').allTextContents();
    results.push(...items);
  }
  return results;
}"
```
