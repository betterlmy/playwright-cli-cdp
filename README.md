# playwright-cli-cdp

[中文文档](README.zh-CN.md)

skills.sh: https://www.skills.sh/betterlmy/agent-skills/playwright-cli-cdp

`playwright-cli-cdp` is a CDP-only agent skill for Chrome-family browser automation through Chrome DevTools Protocol (CDP) and `playwright-cli`.

## Skills

| Skill | Description |
|---|---|
| `playwright-cli-cdp` | CDP-only browser control with `playwright-cli` for Chrome-family browsers. |

## Repository layout

```text
skills/
  playwright-cli-cdp/
    SKILL.md
    scripts/
    references/
```

`SKILL.md` keeps the agent-facing workflow. `scripts/` contains the executable helpers. `references/` contains detailed guides the agent loads only when needed.

## Install

Install with the official `skills` CLI:

```bash
npx skills add betterlmy/agent-skills --skill playwright-cli-cdp
```

Install globally for Codex:

```bash
npx skills add betterlmy/agent-skills --skill playwright-cli-cdp -a codex -g -y
```

Install globally for Claude Code:

```bash
npx skills add betterlmy/agent-skills --skill playwright-cli-cdp -a claude-code -g -y
```

## Quick Start

After installing the skill, start a new agent session and ask the agent to use `playwright-cli-cdp` for CDP browser work.

Example prompt:

```text
Use playwright-cli-cdp to open https://example.com through CDP and inspect the page title.
```

## Capabilities

- Page interaction: navigation, click, double-click, type, fill, drag-and-drop, file upload, checkbox, select
- Keyboard and mouse: `press`, `keydown`/`keyup`, `mousemove`, `mousedown`/`mouseup`, `mousewheel`
- Dialog handling with optional confirmation text
- Request routing and network mocking
- Cookie, localStorage, sessionStorage, IndexedDB, and full storage state workflows
- Console and network inspection
- Tracing with DOM snapshots, screenshots, and network activity
- WebM video recording with chapter markers and custom HTML overlays
- Element highlighting, interactive annotation, and Playwright locator generation
- Playwright TypeScript test code generation
- Raw Chrome DevTools Protocol commands through `run-code`

## Requirements

- Git, for downloading and updating the skill.
- `playwright-cli`, installed in the environment where the agent runs browser commands.
- A Chrome-family browser: Chrome, Chromium, or Microsoft Edge.
- Shell access for the agent, because this skill uses bundled scripts.

## Included reference guides

Reference guides live under `skills/playwright-cli-cdp/references/`:

| File | Contents |
|---|---|
| `cdp-startup.md` | CDP startup, cross-platform Chrome launch, port conflict troubleshooting |
| `cdp-recipes.md` | Raw CDP protocol commands: Runtime, Network, Performance, Emulation, Security, Coverage |
| `element-attributes.md` | Inspecting `id`, `class`, `data-*`, and computed style via `eval` |
| `request-mocking.md` | Route commands and advanced mocking patterns with `run-code` |
| `running-code.md` | Geolocation, permissions, media emulation, frames, file download, clipboard, and more |
| `storage-state.md` | Full cookie, localStorage, sessionStorage, IndexedDB, and state save/load reference |
| `test-generation.md` | Collecting generated Playwright code, adding assertions, `toMatchAriaSnapshot` patterns |
| `tracing.md` | Trace output format, use cases, comparison with video and screenshot |
| `video-recording.md` | Basic recording, scripted demos, and the Overlay API |

## Notes

- This is a CDP-only skill. It intentionally avoids Playwright-managed browser launches.
- CDP can expose browser data such as cookies, storage, page content, and network traffic. Review third-party skills before installing them.
- For the agent-facing workflow, read `skills/playwright-cli-cdp/SKILL.md`.

## References

- Skills directory: https://www.skills.sh/
- Skills CLI: https://github.com/vercel-labs/skills
- Claude Code Skills: https://code.claude.com/docs/en/skills
- Claude Code Agent SDK Skills: https://code.claude.com/docs/en/agent-sdk/skills
