$PageTimeoutMs = 15000

if ($env:PLAYWRIGHT_MCP_TIMEOUT_NAVIGATION) {
  [int]::TryParse($env:PLAYWRIGHT_MCP_TIMEOUT_NAVIGATION, [ref]$PageTimeoutMs) | Out-Null
}

if ($env:PLAYWRIGHT_CLI_CDP_PAGE_TIMEOUT_MS) {
  [int]::TryParse($env:PLAYWRIGHT_CLI_CDP_PAGE_TIMEOUT_MS, [ref]$PageTimeoutMs) | Out-Null
}

if ($PageTimeoutMs -lt 1) {
  $PageTimeoutMs = 15000
}

$env:PLAYWRIGHT_MCP_TIMEOUT_NAVIGATION = [string]$PageTimeoutMs

$PlaywrightCli = Get-Command playwright-cli -ErrorAction SilentlyContinue
if ($PlaywrightCli) {
  & playwright-cli @args
  exit $LASTEXITCODE
}

$Npx = Get-Command npx -ErrorAction SilentlyContinue
if ($Npx) {
  & npx --no-install playwright-cli @args
  exit $LASTEXITCODE
}

Write-Error "playwright-cli was not found. Install @playwright/cli globally or in the current project."
exit 127
