# playwright-cli-cdp

[English README](README.md)

`playwright-cli-cdp` 是一个只面向 CDP 的 agent skill，用 Chrome DevTools Protocol (CDP) 和 `playwright-cli` 控制 Chrome 系浏览器。

它不限定某一个 agent runtime。Claude Code、Codex，或者任何支持 `SKILL.md` 文件入口的 filesystem-based skills 的 agent 系统都可以使用。

## 快速开始

先安装 skill，然后开启一个新的 agent 会话，再让 agent 使用 `playwright-cli-cdp` 做 CDP 浏览器任务。

示例 prompt：

```text
Use playwright-cli-cdp to open https://example.com through CDP and inspect the page title.
```

## Claude Code 安装

个人安装，所有项目都可用：

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/betterlmy/playwright-cli-cdp.git ~/.claude/skills/playwright-cli-cdp
```

项目安装，只在当前仓库中使用：

```bash
mkdir -p .claude/skills
git clone https://github.com/betterlmy/playwright-cli-cdp.git .claude/skills/playwright-cli-cdp
```

在项目里启动 Claude Code：

```bash
claude
```

你可以直接用自然语言要求 CDP 浏览器自动化，也可以直接调用：

```text
/playwright-cli-cdp
```

Claude Code 会从 `~/.claude/skills/<skill-name>/SKILL.md` 和项目 `.claude/skills/<skill-name>/SKILL.md` 发现 skills。如果 Claude Code 已经在运行时才新建顶层 skills 目录，需要重启 Claude Code，让它开始监听新目录。

## Codex 安装

个人安装，使用默认 Codex skills 目录：

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
git clone https://github.com/betterlmy/playwright-cli-cdp.git "${CODEX_HOME:-$HOME/.codex}/skills/playwright-cli-cdp"
```

Windows PowerShell：

```powershell
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
New-Item -ItemType Directory -Force (Join-Path $codexHome "skills") | Out-Null
git clone https://github.com/betterlmy/playwright-cli-cdp.git (Join-Path $codexHome "skills\playwright-cli-cdp")
```

安装后重启 Codex，让它重新加载 skills。

然后用自然语言要求 Codex 做 CDP 浏览器任务：

```text
Use playwright-cli-cdp to open https://example.com through CDP and summarize what is on the page.
```

## 依赖要求

- Git，用于下载和更新 skill。
- `playwright-cli`，需要安装在 agent 执行浏览器命令的环境里。
- Chrome 系浏览器：Chrome、Chromium 或 Microsoft Edge。
- agent 需要具备 shell 执行能力，因为这个 skill 带有 bundled scripts。

## 更新

Claude Code 个人安装：

```bash
git -C ~/.claude/skills/playwright-cli-cdp pull
```

Codex 个人安装：

```bash
git -C "${CODEX_HOME:-$HOME/.codex}/skills/playwright-cli-cdp" pull
```

Codex Windows PowerShell：

```powershell
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
git -C (Join-Path $codexHome "skills\playwright-cli-cdp") pull
```

如果 agent 没有自动重新加载 skills，更新后请重启 agent。

## 卸载

Claude Code 个人安装：

```bash
rm -rf ~/.claude/skills/playwright-cli-cdp
```

Codex 个人安装：

```bash
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/playwright-cli-cdp"
```

## 说明

- 这是一个 CDP-only skill，设计上避免使用 Playwright 托管浏览器启动方式。
- CDP 可以暴露 cookie、storage、页面内容、网络流量等浏览器数据。安装第三方 skill 前请先审查内容。
- 如果想了解 agent 调用 skill 之后具体会执行什么，请阅读 `SKILL.md`。

## 参考资料

- Claude Code Skills: https://code.claude.com/docs/en/skills
- Claude Code Agent SDK Skills: https://code.claude.com/docs/en/agent-sdk/skills
- OpenAI Skills Catalog for Codex: https://github.com/openai/skills
