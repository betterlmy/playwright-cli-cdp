# playwright-cli-cdp

[English README](README.md)

skills.sh: https://www.skills.sh/betterlmy/agent-skills/playwright-cli-cdp

`playwright-cli-cdp` 是一个只面向 CDP 的 agent skill，用 Chrome DevTools Protocol (CDP) 和 `playwright-cli` 控制 Chrome 系浏览器。

## Skills

| Skill | 说明 |
|---|---|
| `playwright-cli-cdp` | 基于 `playwright-cli` 和 CDP 控制 Chrome 系浏览器的 agent skill。 |

## 仓库结构

```text
skills/
  playwright-cli-cdp/
    SKILL.md
    scripts/
    references/
```

`SKILL.md` 保存 agent 需要加载的核心流程；`scripts/` 保存可执行辅助脚本；`references/` 保存按需读取的详细参考文档。

## 安装

使用官方 `skills` CLI 安装：

```bash
npx skills add betterlmy/agent-skills --skill playwright-cli-cdp
```

全局安装到 Codex：

```bash
npx skills add betterlmy/agent-skills --skill playwright-cli-cdp -a codex -g -y
```

全局安装到 Claude Code：

```bash
npx skills add betterlmy/agent-skills --skill playwright-cli-cdp -a claude-code -g -y
```

## 快速开始

安装 skill 后，重新开启一个 agent 会话，然后让 agent 使用 `playwright-cli-cdp` 做 CDP 浏览器任务。

示例 prompt：

```text
Use playwright-cli-cdp to open https://example.com through CDP and inspect the page title.
```

## 功能概览

- 页面交互：导航、点击、双击、输入、填表、拖拽、文件上传、复选框、下拉选择
- 键盘和鼠标：`press`、`keydown`/`keyup`、`mousemove`、`mousedown`/`mouseup`、`mousewheel`
- 浏览器弹窗处理，支持传入确认文本
- 请求路由和网络 mock
- Cookie、localStorage、sessionStorage、IndexedDB 和完整 storage state 流程
- Console 和网络请求检查
- 带 DOM snapshot、截图、网络活动的 tracing
- WebM 视频录制，支持章节标记和自定义 HTML overlay
- 元素高亮、交互式标注、Playwright locator 生成
- Playwright TypeScript 测试代码生成
- 通过 `run-code` 直接执行 Chrome DevTools Protocol 命令

## 依赖要求

- Git，用于下载和更新 skill。
- `playwright-cli`，需要安装在 agent 执行浏览器命令的环境里。
- Chrome 系浏览器：Chrome、Chromium 或 Microsoft Edge。
- agent 需要具备 shell 执行能力，因为这个 skill 带有 bundled scripts。

## 内置参考文档

参考文档位于 `skills/playwright-cli-cdp/references/`：

| 文件 | 内容 |
|---|---|
| `cdp-startup.md` | CDP 启动、跨平台 Chrome 启动方式、端口冲突排查 |
| `cdp-recipes.md` | 原始 CDP 协议命令：Runtime、Network、Performance、Emulation、Security、Coverage |
| `element-attributes.md` | 用 `eval` 检查元素的 `id`、`class`、`data-*` 及 computed style |
| `request-mocking.md` | route 命令及用 `run-code` 实现高级 mock 模式 |
| `running-code.md` | 地理位置、权限、媒体模拟、frames、文件下载、剪贴板等完整示例 |
| `storage-state.md` | Cookie、localStorage、sessionStorage、IndexedDB 及 storage state 保存/恢复参考 |
| `test-generation.md` | 收集生成的 Playwright 代码、添加断言、`toMatchAriaSnapshot` 用法 |
| `tracing.md` | Trace 输出格式、使用场景、与视频和截图的对比 |
| `video-recording.md` | 基础录制、脚本化演示、Overlay API 用法 |

## 说明

- 这是一个 CDP-only skill，设计上避免使用 Playwright 托管浏览器启动方式。
- CDP 可以暴露 cookie、storage、页面内容、网络流量等浏览器数据。安装第三方 skill 前请先审查内容。
- agent 侧的真实使用流程请看 `skills/playwright-cli-cdp/SKILL.md`。

## 参考资料

- Skills directory: https://www.skills.sh/
- Skills CLI: https://github.com/vercel-labs/skills
- Claude Code Skills: https://code.claude.com/docs/en/skills
- Claude Code Agent SDK Skills: https://code.claude.com/docs/en/agent-sdk/skills
