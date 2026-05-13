# playwright-cli-cdp

[English README](README.md)

`playwright-cli-cdp` 是一个只面向 CDP 的 agent skill，用 `playwright-cli` 通过 Chrome DevTools Protocol 控制 Chrome 系浏览器。

这个 skill 不使用 `playwright-cli open`、Playwright 托管浏览器、Firefox/WebKit、extension attach，也不使用 Playwright test debug attach 流程。所有浏览器会话都必须通过 CDP endpoint，并使用 `playwright-cli attach --cdp=...` 连接。

## 快速开始

先把 skill 安装到你的 agent skills 目录里，然后开启一个新的 agent 会话，让 skill 列表重新加载。

Codex macOS/Linux：

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/betterlmy/playwright-cli-cdp.git ~/.codex/skills/playwright-cli-cdp
```

Codex Windows PowerShell：

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex\skills" | Out-Null
git clone https://github.com/betterlmy/playwright-cli-cdp.git "$env:USERPROFILE\.codex\skills\playwright-cli-cdp"
```

其他 agent：把这个仓库 clone 到该 agent 的 skills/plugins 目录，或者让 agent 直接读取这个仓库里的 `SKILL.md`。

使用时，用自然语言要求 agent 做 CDP 浏览器任务，例如：

```text
Use playwright-cli-cdp to open https://example.com through CDP and inspect the page title.
```

agent 应该会读取 `SKILL.md`，先跑环境检查，启动或复用 CDP endpoint，通过 `playwright-cli attach --cdp=...` 连接，然后完成你要求的浏览器任务。

更新已有安装：

```bash
git -C ~/.codex/skills/playwright-cli-cdp pull
```

Windows PowerShell：

```powershell
git -C "$env:USERPROFILE\.codex\skills\playwright-cli-cdp" pull
```

## 谁可以使用

这个 skill 不限于 Codex。任何 AI agent、assistant runtime 或自动化系统，只要满足下面条件，都可以使用：

- 能读取 `SKILL.md` 指令。
- 能按当前目录解析 bundled files。
- 能执行 shell 命令和 bundled startup scripts。
- 能使用 `playwright-cli` 连接 CDP endpoint。

Codex 只是支持的宿主之一；这个 workflow 本身是 agent-agnostic 的。

## 平台支持

CDP 由 Chrome 系浏览器提供，macOS、Linux、Windows、WSL2 都可以支持。唯一要求是浏览器暴露了当前环境能访问到的 remote debugging endpoint。

| 平台 | 是否支持 | 启动方式 |
| --- | --- | --- |
| macOS | 支持 | `bash scripts/open-chrome-remote.sh` |
| Linux | 支持 | `bash scripts/open-chrome-remote.sh` |
| Windows | 支持 | `powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1` |
| WSL2 + WSL 内的 Linux Chrome/Chromium | 支持 | 在 WSL2 内执行 `bash scripts/open-chrome-remote.sh` |
| WSL2 连接 Windows Chrome | 支持，但要注意网络连通性 | 先用 PowerShell 脚本启动 Windows Chrome，再从 WSL2 连接可访问的 endpoint |

## 能做什么

- 在启动或连接前检查本地环境。
- 启动开启 remote debugging 的 Chrome、Chromium 或 Edge。
- 将 `playwright-cli` 连接到本地或用户提供的 CDP endpoint。
- 对已连接页面执行 snapshot、点击、输入、导航、标签页、截图、console、network、cookie 和 storage 操作。
- 通过 `playwright-cli run-code` 发送原始 Chrome DevTools Protocol 命令。
- 默认只在本地 `127.0.0.1:9222` 暴露 CDP endpoint。

## 环境检查

preflight 脚本不会启动 Chrome。它们会检查：

- `playwright-cli` 或本地 `npx --no-install playwright-cli` 是否可用。
- `/json/version` endpoint 是否可达。
- 是否能找到 Chrome 系浏览器。
- 基础端口冲突。
- `CDP_HOST=0.0.0.0` 这类高风险绑定。
- WSL2 下没有本地 Linux 浏览器或 endpoint 时的提示。

## 手动操作参考

下面这些命令是 skill 内部会用到的流程。它们适合用来验证安装、排查环境问题，或手动跑一遍 CDP workflow。

### macOS、Linux、或 WSL2 内的 Linux Chrome

在这个 skill 目录下执行：

```bash
bash scripts/check-environment.sh
bash scripts/open-chrome-remote.sh
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
playwright-cli -s=cdp goto https://example.com
playwright-cli -s=cdp snapshot
playwright-cli -s=cdp detach
```

启动 Chrome 时直接打开指定 URL：

```bash
bash scripts/check-environment.sh
bash scripts/open-chrome-remote.sh https://example.com
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

使用自定义端口：

```bash
CDP_PORT=9333 bash scripts/check-environment.sh
CDP_PORT=9333 bash scripts/open-chrome-remote.sh
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9333
```

### Windows PowerShell

在这个 skill 目录下执行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\check-environment.ps1
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
playwright-cli -s=cdp goto https://example.com
playwright-cli -s=cdp snapshot
playwright-cli -s=cdp detach
```

启动 Chrome 时直接打开指定 URL：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\check-environment.ps1
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1 https://example.com
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

使用自定义端口：

```powershell
$env:CDP_PORT = "9333"
powershell -ExecutionPolicy Bypass -File scripts\check-environment.ps1
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9333
```

使用自定义浏览器路径：

```powershell
$env:CHROME_BIN = "C:\Program Files\Google\Chrome\Application\chrome.exe"
powershell -ExecutionPolicy Bypass -File scripts\check-environment.ps1
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
```

### WSL2 连接 Windows Chrome

推荐顺序：

1. 在 Windows PowerShell 里启动 Windows Chrome：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
```

2. 在 WSL2 里测试 localhost 是否可达：

```bash
curl -fsS http://127.0.0.1:9222/json/version
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

3. 如果 WSL2 无法访问 `127.0.0.1:9222`，从 WSL2 获取 Windows host IP。这个方式可能需要让 Chrome 绑定非 localhost 地址，并在 Windows Firewall 放行端口：

```powershell
$env:CDP_HOST = "0.0.0.0"
powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
```

```bash
WINDOWS_HOST=$(awk '/nameserver/ { print $2; exit }' /etc/resolv.conf)
CDP_ENDPOINT="http://${WINDOWS_HOST}:9222" bash scripts/check-environment.sh
curl -fsS "http://${WINDOWS_HOST}:9222/json/version"
playwright-cli -s=cdp attach --cdp="http://${WINDOWS_HOST}:9222"
```

把 CDP 绑定到 `0.0.0.0` 可能会把浏览器数据暴露给网络里的其他机器。只要 `127.0.0.1` 可用，就优先使用 `127.0.0.1`。

## 已有 CDP Endpoint

如果已经有 CDP endpoint，直接连接即可，不要再启动新的浏览器：

```bash
bash scripts/check-environment.sh
playwright-cli -s=cdp attach --cdp=http://127.0.0.1:9222
```

连接前可以先验证 endpoint：

```bash
curl -fsS http://127.0.0.1:9222/json/version
curl -fsS http://127.0.0.1:9222/json/list
```

## 原始 CDP 示例

```bash
playwright-cli -s=cdp run-code "async page => {
  const cdp = await page.context().newCDPSession(page);
  return await cdp.send('Browser.getVersion');
}"
```

## 文件说明

- `SKILL.md`：给 agent 使用的 skill 指令和触发元数据。
- `scripts/check-environment.sh`：在 macOS、Linux 或 WSL2 上检查 Bash 侧前置条件。
- `scripts/check-environment.ps1`：在 Windows 上检查 PowerShell 侧前置条件。
- `scripts/open-chrome-remote.sh`：在 macOS、Linux 或 WSL2 Linux 环境里启动 Chrome 系浏览器的 remote debugging 模式。
- `scripts/open-chrome-remote.ps1`：在 Windows 里启动 Chrome 系浏览器的 remote debugging 模式。
- `references/cdp-startup.md`：启动方式、endpoint 检查、端口冲突、WSL2 注意事项和 profile 说明。
- `references/cdp-recipes.md`：原始 CDP 命令示例。

## 安全说明

CDP 可以访问 cookie、storage、网络流量、页面内容和浏览器内部信息。这个 skill 默认只绑定 `127.0.0.1`。除非用户明确要求并接受风险，不要把 CDP 绑定到 `0.0.0.0` 或公网接口。

## 依赖说明

把 `playwright-cli` 安装在执行 attach 命令的环境里。例如 WSL2 连接 Windows Chrome 时，`playwright-cli` 需要在 WSL2 内可用。

如果全局没有 `playwright-cli`，先尝试本地版本：

```bash
npx --no-install playwright-cli --version
```

如果没有本地版本：

```bash
npm install -g @playwright/cli@latest
```
