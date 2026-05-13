# playwright-cli-cdp

[中文文档](README.zh-CN.md)

`playwright-cli-cdp` is a CDP-only agent skill for controlling Chrome-family browsers through the Chrome DevTools Protocol with `playwright-cli`.

This skill does not use `playwright-cli open`, Playwright-managed browser launches, Firefox/WebKit, extension attach, or Playwright test debug attach workflows. Every browser session must attach through a CDP endpoint with `playwright-cli attach --cdp=...`.

## Who Can Use It

This skill is not limited to Codex. Any AI agent, assistant runtime, or automation system can use it if it can:

- Read the `SKILL.md` instructions.
- Resolve bundled files relative to this directory.
- Run shell commands and the bundled startup scripts.
- Use `playwright-cli` to attach to CDP endpoints.

Codex is one supported host, but the workflow is intentionally agent-agnostic.

## Platform Support

CDP is supported by Chrome-family browsers on macOS, Linux, Windows, and WSL2. The only requirement is that the browser exposes a reachable remote debugging endpoint.

| Platform | Supported | Startup path |
| --- | --- | --- |
| macOS | Yes | `bash scripts/open-chrome-remote.sh` |
| Linux | Yes | `bash scripts/open-chrome-remote.sh` |
| Windows | Yes | `powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1` |
| WSL2 with Linux Chrome/Chromium | Yes | `bash scripts/open-chrome-remote.sh` inside WSL2 |
| WSL2 connecting to Windows Chrome | Yes, with networking caveats | Start Windows Chrome with the PowerShell script, then attach from WSL2 to a reachable endpoint |

## What It Does

- Starts Chrome, Chromium, or Edge with remote debugging enabled.
- Attaches `playwright-cli` to a local or user-provided CDP endpoint.
- Drives attached pages with snapshots, clicks, typing, navigation, tabs, screenshots, console logs, network logs, cookies, and storage commands.
- Sends raw Chrome DevTools Protocol commands through `playwright-cli run-code`.
- Keeps the default CDP endpoint local at `127.0.0.1:9222`.

## Quick Start

### macOS, Linux, or WSL2 with Linux Chrome

From this skill directory:

```bash
bash scripts/open-chrome-remote.sh
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
playwright-cli -s=cdp goto https://example.com
playwright-cli -s=cdp snapshot
playwright-cli -s=cdp detach
```

Start Chrome at a URL:

```bash
bash scripts/open-chrome-remote.sh https://example.com
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

Use a custom port:

```bash
CDP_PORT=9333 bash scripts/open-chrome-remote.sh
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9333
```

### Windows PowerShell

From this skill directory:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
playwright-cli -s=cdp goto https://example.com
playwright-cli -s=cdp snapshot
playwright-cli -s=cdp detach
```

Start Chrome at a URL:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1 https://example.com
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

Use a custom port:

```powershell
$env:CDP_PORT = "9333"
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9333
```

Use a custom browser path:

```powershell
$env:CHROME_BIN = "C:\Program Files\Google\Chrome\Application\chrome.exe"
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
```

### WSL2 Connecting to Windows Chrome

Recommended order:

1. Start Windows Chrome from Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
```

2. From WSL2, test whether localhost forwarding works:

```bash
curl -fsS http://127.0.0.1:9222/json/version
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

3. If WSL2 cannot reach `127.0.0.1:9222`, use the Windows host IP from WSL2. This may require starting Chrome with a non-localhost bind and allowing the port through Windows Firewall:

```powershell
$env:CDP_HOST = "0.0.0.0"
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
```

```bash
WINDOWS_HOST=$(awk '/nameserver/ { print $2; exit }' /etc/resolv.conf)
curl -fsS "http://${WINDOWS_HOST}:9222/json/version"
playwright-cli -s=cdp attach --cdp="http://${WINDOWS_HOST}:9222"
```

Binding CDP to `0.0.0.0` can expose browser data to other machines on the network. Prefer `127.0.0.1` whenever it is reachable.

## Existing CDP Endpoint

If a CDP endpoint already exists, attach to it directly:

```bash
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

Verify the endpoint first:

```bash
curl -fsS http://127.0.0.1:9222/json/version
curl -fsS http://127.0.0.1:9222/json/list
```

## Raw CDP Example

```bash
playwright-cli -s=cdp run-code "async page => {
  const cdp = await page.context().newCDPSession(page);
  return await cdp.send('Browser.getVersion');
}"
```

## Files

- `SKILL.md`: Agent-facing skill instructions and trigger metadata.
- `scripts/open-chrome-remote.sh`: Starts Chrome-family browsers in remote debugging mode on macOS, Linux, or WSL2 Linux environments.
- `scripts/open-chrome-remote.ps1`: Starts Chrome-family browsers in remote debugging mode on Windows.
- `references/cdp-startup.md`: Startup, endpoint checks, port conflicts, WSL2 notes, and profile guidance.
- `references/cdp-recipes.md`: Raw CDP command examples.

## Security

CDP can expose cookies, storage, network traffic, page content, and browser internals. By default, this skill binds remote debugging to `127.0.0.1`. Do not bind CDP to `0.0.0.0` or a public interface unless the user explicitly requests it and accepts the risk.

## Installation Notes

Install `playwright-cli` in the environment where you run the attach command. For example, if WSL2 attaches to Windows Chrome, `playwright-cli` must be available inside WSL2.

If `playwright-cli` is not available globally, try a local version:

```bash
npx --no-install playwright-cli --version
```

If no local version exists:

```bash
npm install -g @playwright/cli@latest
```
