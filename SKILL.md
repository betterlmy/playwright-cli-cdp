---
name: playwright-cli-cdp
description: CDP-only browser control with playwright-cli. Use for launching Chrome in remote debugging mode, attaching exclusively through --cdp endpoints, driving attached pages, inspecting console/network/storage, and sending raw Chrome DevTools Protocol commands. Do not use playwright-cli open, non-CDP browser launches, extension attach, or Playwright test debug attach workflows from this skill.
allowed-tools: Bash(playwright-cli:*) Bash(npx:*) Bash(npm:*) Bash(bash:*) Bash(curl:*) Bash(lsof:*) Bash(pgrep:*) Bash(mkdir:*) Bash(pwsh:*) Bash(powershell:*) Bash(powershell.exe:*)
---

# playwright-cli CDP

## Default behavior

This skill is CDP-only. All browser work must happen through a Chrome DevTools Protocol endpoint and `playwright-cli attach --cdp=...`.

Do not use `playwright-cli open`, `--browser=...`, Firefox/WebKit launches, extension attach, or Playwright test debug attach workflows in this skill. If a CDP endpoint is already reachable, reuse it as-is. If no CDP endpoint exists, start Chrome remote debugging on `127.0.0.1:9222`, attach `playwright-cli` to that endpoint, and use the session name `cdp`.

Keep CDP local. Do not bind the debugging endpoint to `0.0.0.0` or a public interface unless the user explicitly requests it and accepts the security risk.

Never close, kill, restart, detach, or otherwise clean up an existing CDP endpoint or browser just because the task is done. Leave Chrome and the debugging port running unless the user explicitly asks to close it. If the user asks to clean up, prefer `playwright-cli -s=<session> detach` first; only terminate browser processes when the user explicitly asks to close/kill Chrome.

## Quick start

Resolve bundled scripts relative to this skill directory before running them.

macOS, Linux, or WSL2 with a Linux browser:

```bash
bash scripts/check-environment.sh
bash scripts/open-chrome-remote.sh
```

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\check-environment.ps1
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
```

Attach and drive the CDP session:

```bash
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
playwright-cli -s=cdp goto https://example.com
playwright-cli -s=cdp snapshot
playwright-cli -s=cdp click e15
playwright-cli -s=cdp eval "document.title"
```

Start at a URL when useful:

macOS, Linux, or WSL2 with a Linux browser:

```bash
bash scripts/check-environment.sh
bash scripts/open-chrome-remote.sh https://example.com
```

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\check-environment.ps1
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1 https://example.com
```

Then attach:

```bash
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

If the user gives an endpoint, use it directly and do not launch another browser:

```bash
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9223
playwright-cli -s=prod attach --cdp=https://debug.example.internal
```

## Endpoint checks

Run the environment check before starting or attaching unless the task is already in a known-good active CDP session:

```bash
bash scripts/check-environment.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts\check-environment.ps1
```

Before attaching, verify the endpoint when possible:

```bash
curl -fsS http://127.0.0.1:9222/json/version
curl -fsS http://127.0.0.1:9222/json/list
```

If the endpoint is down, start Chrome remote mode with the bundled Bash or PowerShell script for the current platform. If the port is already used by a non-CDP process, inspect it and choose another port via `CDP_PORT`.

macOS, Linux, or WSL2 with a Linux browser:

```bash
lsof -iTCP:9222 -sTCP:LISTEN
CDP_PORT=9333 bash scripts/open-chrome-remote.sh
```

Windows PowerShell:

```powershell
netstat -ano | findstr :9222
$env:CDP_PORT = "9333"
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
```

Then attach:

```bash
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9333
```

## Core commands after attach

Use snapshot refs for normal page interaction.

```bash
playwright-cli -s=cdp snapshot
playwright-cli -s=cdp snapshot --boxes
playwright-cli -s=cdp goto https://playwright.dev
playwright-cli -s=cdp click e3
playwright-cli -s=cdp dblclick e7
playwright-cli -s=cdp fill e5 "user@example.com" --submit
playwright-cli -s=cdp type "search query"
playwright-cli -s=cdp press Enter
playwright-cli -s=cdp hover e4
playwright-cli -s=cdp select e9 "option-value"
playwright-cli -s=cdp upload ./document.pdf
playwright-cli -s=cdp screenshot --filename=page.png
```

Use selectors or Playwright locators when refs are not stable:

```bash
playwright-cli -s=cdp click "#main > button.submit"
playwright-cli -s=cdp click "getByRole('button', { name: 'Submit' })"
playwright-cli -s=cdp click "getByTestId('submit-button')"
```

## Tabs and navigation

```bash
playwright-cli -s=cdp tab-list
playwright-cli -s=cdp tab-new https://example.com/page
playwright-cli -s=cdp tab-select 0
playwright-cli -s=cdp tab-close 1
playwright-cli -s=cdp go-back
playwright-cli -s=cdp go-forward
playwright-cli -s=cdp reload
playwright-cli -s=cdp resize 1440 1000
```

## Console, network, and storage

```bash
playwright-cli -s=cdp console
playwright-cli -s=cdp console error
playwright-cli -s=cdp requests
playwright-cli -s=cdp request 5

playwright-cli -s=cdp cookie-list
playwright-cli -s=cdp cookie-get session_id
playwright-cli -s=cdp cookie-set session_id abc123 --domain=example.com --httpOnly --secure
playwright-cli -s=cdp localstorage-list
playwright-cli -s=cdp localstorage-get token
playwright-cli -s=cdp sessionstorage-list

playwright-cli -s=cdp state-save auth.json
playwright-cli -s=cdp state-load auth.json
```

Use `--raw` for machine-readable pipelines:

```bash
playwright-cli -s=cdp --raw eval "document.title"
playwright-cli -s=cdp --raw snapshot > page.yml
playwright-cli -s=cdp --raw cookie-get session_id
```

## Raw CDP commands

Use `run-code` when the task requires a Chrome DevTools Protocol domain or command that the CLI does not expose directly. Create a CDP session from the active page, enable the needed domain, send commands, and return serializable data.

```bash
playwright-cli -s=cdp run-code "async page => {
  const cdp = await page.context().newCDPSession(page);
  return await cdp.send('Browser.getVersion');
}"
```

```bash
playwright-cli -s=cdp run-code "async page => {
  const cdp = await page.context().newCDPSession(page);
  await cdp.send('Network.enable');
  return await cdp.send('Runtime.evaluate', {
    expression: 'navigator.userAgent',
    returnByValue: true
  });
}"
```

CDP command and parameter names are case-sensitive. Use protocol commands for browser internals, performance metrics, emulation, coverage, security state, and low-level network diagnostics. After the session is attached through `--cdp`, use `playwright-cli` page commands for interaction.

## Session lifecycle

For CDP-attached browsers, leave the external Chrome and CDP port running after the requested task. Do not run `detach`, `close`, `close-all`, `kill-all`, or process-kill commands as normal cleanup.

Only detach or close when the user explicitly asks. If cleanup is requested, prefer `playwright-cli -s=<session> detach` because it leaves the browser and CDP endpoint running.

When multiple CDP endpoints are in use, name sessions by endpoint or purpose:

```bash
playwright-cli -s=local attach --cdp=http://127.0.0.1:9222
playwright-cli -s=staging attach --cdp=http://127.0.0.1:9333
```

## Installation fallback

If the global command is unavailable, try a local version first:

```bash
npx --no-install playwright-cli --version
npx --no-install playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

If no local version exists, install the CLI:

```bash
npm install -g @playwright/cli@latest
```

## References

- CDP startup and troubleshooting: [references/cdp-startup.md](references/cdp-startup.md)
- CDP protocol recipes: [references/cdp-recipes.md](references/cdp-recipes.md)
