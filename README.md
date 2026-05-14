# playwright-cli-cdp

[中文文档](README.zh-CN.md)

`playwright-cli-cdp` is a CDP-only agent skill for Chrome-family browser automation through Chrome DevTools Protocol (CDP) and `playwright-cli`.

It is not limited to one agent runtime. It can be used by Claude Code, Codex, or any agent system that supports filesystem-based skills with a `SKILL.md` entrypoint.

## Capabilities

- **Page interaction** — navigation, click, double-click, type, fill, drag-and-drop, file upload, checkbox, select
- **Keyboard and mouse** — `press`, `keydown`/`keyup`, `mousemove`, `mousedown`/`mouseup`, `mousewheel`
- **Dialog handling** — accept or dismiss browser dialogs with optional confirmation text
- **Request routing** — intercept and mock network requests by URL pattern; modify real responses or simulate failures
- **Storage** — cookies, localStorage, sessionStorage, IndexedDB, full storage state save and load
- **Console and network** — inspect console logs and network requests
- **Tracing** — capture execution traces with DOM snapshots, screenshots, and network activity
- **Video recording** — record automation as WebM video with chapter markers and custom HTML overlays
- **Debug tools** — element highlighting, interactive annotation, Playwright locator generation
- **Test code generation** — page interaction commands (click, fill, goto, etc.) emit Playwright TypeScript code ready to paste into tests
- **Raw CDP** — send Chrome DevTools Protocol commands directly via `run-code`

## Quick Start

Install the skill, start a new agent session, then ask the agent to use `playwright-cli-cdp` for CDP browser work.

Example prompt:

```text
Use playwright-cli-cdp to open https://example.com through CDP and inspect the page title.
```

## Install For Claude Code

Personal install, available across projects:

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/betterlmy/playwright-cli-cdp.git ~/.claude/skills/playwright-cli-cdp
```

Project install, committed or kept inside one repository:

```bash
mkdir -p .claude/skills
git clone https://github.com/betterlmy/playwright-cli-cdp.git .claude/skills/playwright-cli-cdp
```

Start Claude Code from your project:

```bash
claude
```

Use the skill automatically by asking for CDP browser automation, or invoke it directly:

```text
/playwright-cli-cdp
```

Claude Code discovers skills from `~/.claude/skills/<skill-name>/SKILL.md` and project `.claude/skills/<skill-name>/SKILL.md`. If you create the top-level skills directory while Claude Code is already running, restart Claude Code so it watches the new directory.

## Install For Codex

Personal install, using the default Codex skills directory:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
git clone https://github.com/betterlmy/playwright-cli-cdp.git "${CODEX_HOME:-$HOME/.codex}/skills/playwright-cli-cdp"
```

Windows PowerShell:

```powershell
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
New-Item -ItemType Directory -Force (Join-Path $codexHome "skills") | Out-Null
git clone https://github.com/betterlmy/playwright-cli-cdp.git (Join-Path $codexHome "skills\playwright-cli-cdp")
```

Restart Codex after installing so it picks up the new skill.

Then ask Codex for CDP browser automation:

```text
Use playwright-cli-cdp to open https://example.com through CDP and summarize what is on the page.
```

## Requirements

- Git, for cloning and updating the skill.
- `playwright-cli`, installed in the environment where the agent runs browser commands.
- A Chrome-family browser: Chrome, Chromium, or Microsoft Edge.
- Shell access for the agent, because this skill uses bundled scripts.

## Update

Claude Code personal install:

```bash
git -C ~/.claude/skills/playwright-cli-cdp pull
```

Codex personal install:

```bash
git -C "${CODEX_HOME:-$HOME/.codex}/skills/playwright-cli-cdp" pull
```

Windows PowerShell for Codex:

```powershell
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
git -C (Join-Path $codexHome "skills\playwright-cli-cdp") pull
```

Restart the agent after updating if it does not reload skills automatically.

## Uninstall

Claude Code personal install:

```bash
rm -rf ~/.claude/skills/playwright-cli-cdp
```

Codex personal install:

```bash
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/playwright-cli-cdp"
```

## Included reference guides

The `references/` directory contains detailed guides the agent loads on demand:

| File | Contents |
|---|---|
| `cdp-startup.md` | CDP startup, cross-platform Chrome launch, port conflict troubleshooting |
| `cdp-recipes.md` | Raw CDP protocol commands (Runtime, Network, Performance, Emulation, Security, Coverage) |
| `element-attributes.md` | Inspecting `id`, `class`, `data-*`, and computed style via `eval` |
| `request-mocking.md` | Route commands and advanced mocking patterns with `run-code` |
| `running-code.md` | Geolocation, permissions, media emulation, frames, file download, clipboard, and more |
| `storage-state.md` | Full cookie, localStorage, sessionStorage, IndexedDB, and state save/load reference |
| `test-generation.md` | Collecting generated Playwright code, adding assertions, `toMatchAriaSnapshot` patterns |
| `tracing.md` | Trace output format, use cases, comparison with video and screenshot |
| `video-recording.md` | Basic recording, scripted demos, and the Overlay API |

## Notes

- This is a CDP-only skill. It is intentionally written to avoid Playwright-managed browser launches.
- CDP can expose browser data such as cookies, storage, page content, and network traffic. Review third-party skills before installing them.
- For details on what the agent does after the skill is invoked, read `SKILL.md`.

## References

- Claude Code Skills: https://code.claude.com/docs/en/skills
- Claude Code Agent SDK Skills: https://code.claude.com/docs/en/agent-sdk/skills
- OpenAI Skills Catalog for Codex: https://github.com/openai/skills
