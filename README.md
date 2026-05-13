# playwright-cli-cdp

[中文文档](README.zh-CN.md)

`playwright-cli-cdp` is a CDP-only agent skill for Chrome-family browser automation through Chrome DevTools Protocol (CDP) and `playwright-cli`.

It is not limited to one agent runtime. It can be used by Claude Code, Codex, or any agent system that supports filesystem-based skills with a `SKILL.md` entrypoint.

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

## Notes

- This is a CDP-only skill. It is intentionally written to avoid Playwright-managed browser launches.
- CDP can expose browser data such as cookies, storage, page content, and network traffic. Review third-party skills before installing them.
- For details on what the agent does after the skill is invoked, read `SKILL.md`.

## References

- Claude Code Skills: https://code.claude.com/docs/en/skills
- Claude Code Agent SDK Skills: https://code.claude.com/docs/en/agent-sdk/skills
- OpenAI Skills Catalog for Codex: https://github.com/openai/skills
