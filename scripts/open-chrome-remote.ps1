[CmdletBinding()]
param(
  [string]$StartUrl = "about:blank",
  [string]$HostName = "",
  [int]$Port = 0,
  [string]$UserDataDir = "",
  [string]$ChromeBin = "",
  [int]$TimeoutSeconds = 0
)

if (-not $HostName) {
  $HostName = if ($env:CDP_HOST) { $env:CDP_HOST } else { "127.0.0.1" }
}

if (-not $Port) {
  $Port = if ($env:CDP_PORT) { [int]$env:CDP_PORT } else { 9222 }
}

if (-not $UserDataDir) {
  $UserDataDir = if ($env:CDP_USER_DATA_DIR) {
    $env:CDP_USER_DATA_DIR
  } else {
    Join-Path $env:LOCALAPPDATA "playwright-cli-cdp\chrome-profile"
  }
}

if (-not $ChromeBin) {
  $ChromeBin = $env:CHROME_BIN
}

if (-not $TimeoutSeconds) {
  $TimeoutSeconds = 15
  if ($env:CDP_TIMEOUT_SECONDS) {
    [int]::TryParse($env:CDP_TIMEOUT_SECONDS, [ref]$TimeoutSeconds) | Out-Null
  }
}

if ($TimeoutSeconds -lt 1) {
  $TimeoutSeconds = 15
}

$Endpoint = "http://${HostName}:$Port"

function Test-CdpEndpoint {
  param(
    [string]$BaseUrl,
    [int]$RequestTimeoutSeconds = 1
  )

  try {
    Invoke-RestMethod -Uri "$BaseUrl/json/version" -TimeoutSec $RequestTimeoutSeconds | Out-Null
    return $true
  } catch {
    return $false
  }
}

function Find-Chrome {
  if ($ChromeBin -and (Test-Path $ChromeBin)) {
    return $ChromeBin
  }

  $candidates = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Chromium\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Chromium\Application\chrome.exe"
  )

  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path $candidate)) {
      return $candidate
    }
  }

  return $null
}

if (Test-CdpEndpoint $Endpoint) {
  Write-Output "Chrome remote debugging is already available: $Endpoint"
  exit 0
}

$ChromePath = Find-Chrome
if (-not $ChromePath) {
  throw @"
Could not find Chrome, Chromium, or Edge.
Set CHROME_BIN to the browser executable path and retry, for example:
  `$env:CHROME_BIN = "C:\Program Files\Google\Chrome\Application\chrome.exe"
  powershell -ExecutionPolicy Bypass -File scripts\open-chrome-remote.ps1
"@
}

New-Item -ItemType Directory -Force -Path $UserDataDir | Out-Null

$Args = @(
  "--remote-debugging-address=$HostName",
  "--remote-debugging-port=$Port",
  "--user-data-dir=`"$UserDataDir`"",
  "--no-first-run",
  "--no-default-browser-check",
  $StartUrl
)

Start-Process -FilePath $ChromePath -ArgumentList $Args | Out-Null

$Deadline = (Get-Date).AddSeconds($TimeoutSeconds)
while ((Get-Date) -lt $Deadline) {
  if (Test-CdpEndpoint $Endpoint) {
    Write-Output "Chrome remote debugging is available: $Endpoint"
    Write-Output "User data dir: $UserDataDir"
    exit 0
  }
  Start-Sleep -Milliseconds 200
}

throw "Chrome was started but CDP did not become ready at $Endpoint within ${TimeoutSeconds}s."
