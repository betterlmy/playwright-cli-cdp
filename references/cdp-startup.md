# CDP Startup and Troubleshooting

This skill is CDP-only. Start or reuse a Chrome DevTools Protocol endpoint, then attach with `playwright-cli attach --cdp=...`.

## Platform support

| Platform | Supported | Startup path |
| --- | --- | --- |
| macOS | Yes | `bash scripts/open-chrome-remote.sh` |
| Linux | Yes | `bash scripts/open-chrome-remote.sh` |
| Windows | Yes | `powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1` |
| WSL2 with Linux Chrome/Chromium | Yes | `bash scripts/open-chrome-remote.sh` inside WSL2 |
| WSL2 connecting to Windows Chrome | Yes, with networking caveats | Start Windows Chrome with PowerShell, then attach from WSL2 to a reachable endpoint |

## macOS, Linux, or WSL2 Linux browser

Use the bundled Bash script to launch Chrome remote debugging with an isolated profile:

```bash
bash scripts/open-chrome-remote.sh
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

The Bash script defaults to:

- Host: `127.0.0.1`
- Port: `9222`
- Profile: `$HOME/.cache/playwright-cli-cdp/chrome-profile`
- First page: `about:blank`

Override defaults with environment variables:

```bash
CDP_PORT=9333 bash scripts/open-chrome-remote.sh https://example.com
CDP_USER_DATA_DIR=/tmp/chrome-cdp-profile bash scripts/open-chrome-remote.sh
CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" bash scripts/open-chrome-remote.sh
```

Manual macOS startup:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-address=127.0.0.1 \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/.cache/playwright-cli-cdp/chrome-profile" \
  --no-first-run \
  --no-default-browser-check
```

Manual Linux startup:

```bash
google-chrome \
  --remote-debugging-address=127.0.0.1 \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/.cache/playwright-cli-cdp/chrome-profile" \
  --no-first-run \
  --no-default-browser-check
```

## Windows PowerShell

Use the bundled PowerShell script:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

The PowerShell script defaults to:

- Host: `127.0.0.1`
- Port: `9222`
- Profile: `%LOCALAPPDATA%\playwright-cli-cdp\chrome-profile`
- First page: `about:blank`

Override defaults with environment variables:

```powershell
$env:CDP_PORT = "9333"
$env:CDP_USER_DATA_DIR = "$env:TEMP\chrome-cdp-profile"
$env:CHROME_BIN = "C:\Program Files\Google\Chrome\Application\chrome.exe"
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1 https://example.com
```

Manual Windows startup:

```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" `
  --remote-debugging-address=127.0.0.1 `
  --remote-debugging-port=9222 `
  --user-data-dir="$env:LOCALAPPDATA\playwright-cli-cdp\chrome-profile" `
  --no-first-run `
  --no-default-browser-check
```

## WSL2 connecting to Windows Chrome

There are two valid WSL2 setups:

- Chrome/Chromium installed inside WSL2: use the Bash script and attach to `http://127.0.0.1:9222` from WSL2.
- Windows Chrome controlled from WSL2: start Windows Chrome with the PowerShell script, then attach from WSL2 to whichever endpoint WSL2 can reach.

Recommended checks from WSL2:

```bash
curl -fsS http://127.0.0.1:9222/json/version
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

If WSL2 cannot reach Windows Chrome through `127.0.0.1`, use the Windows host IP. This may require starting Chrome with `CDP_HOST=0.0.0.0` in Windows PowerShell and allowing the port through Windows Firewall:

```powershell
$env:CDP_HOST = "0.0.0.0"
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
```

```bash
WINDOWS_HOST=$(awk '/nameserver/ { print $2; exit }' /etc/resolv.conf)
curl -fsS "http://${WINDOWS_HOST}:9222/json/version"
playwright-cli -s=cdp attach --cdp="http://${WINDOWS_HOST}:9222"
```

Use the `0.0.0.0` bind only when needed. It can expose CDP to other machines on the network.

## Verify endpoint

```bash
curl -fsS http://127.0.0.1:9222/json/version
curl -fsS http://127.0.0.1:9222/json/list
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

If `/json/version` fails, Chrome is not listening on that host and port. If `/json/list` is empty, open a tab in Chrome or pass a startup URL to the script.

## Port conflicts

macOS/Linux/WSL2:

```bash
lsof -iTCP:9222 -sTCP:LISTEN
CDP_PORT=9333 bash scripts/open-chrome-remote.sh
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9333
```

Windows PowerShell:

```powershell
netstat -ano | findstr :9222
$env:CDP_PORT = "9333"
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9333
```

Prefer changing ports over killing unknown processes. Kill a process only when the user explicitly asks or it is clearly the stale Chrome remote instance started for the task.

## Existing Chrome profiles

Do not attach remote debugging to the user's daily Chrome profile by default. Use an isolated `--user-data-dir` so cookies, extensions, and profile locks do not interfere with the task.

If the user explicitly wants their logged-in Chrome, ask for the intended profile or endpoint. A browser launched without `--remote-debugging-port` cannot be attached by endpoint until restarted with remote debugging enabled.

## Security

CDP can inspect pages, cookies, local storage, network traffic, and browser internals. Keep it bound to `127.0.0.1` unless the user explicitly asks for a remote bind and understands the exposure.
