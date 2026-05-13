[CmdletBinding()]
param(
  [string]$HostName = "",
  [int]$Port = 0,
  [string]$Endpoint = "",
  [string]$ChromeBin = ""
)

if (-not $HostName) {
  $HostName = if ($env:CDP_HOST) { $env:CDP_HOST } else { "127.0.0.1" }
}

if (-not $Port) {
  $Port = if ($env:CDP_PORT) { [int]$env:CDP_PORT } else { 9222 }
}

$EndpointProvided = [bool]$Endpoint -or [bool]$env:CDP_ENDPOINT

if (-not $Endpoint) {
  $Endpoint = if ($env:CDP_ENDPOINT) { $env:CDP_ENDPOINT } else { "http://${HostName}:$Port" }
}

if (-not $ChromeBin) {
  $ChromeBin = $env:CHROME_BIN
}

$Failures = 0
$Warnings = 0

function Write-Ok {
  param([string]$Message)
  Write-Output "[OK] $Message"
}

function Write-Warn {
  param([string]$Message)
  $script:Warnings++
  Write-Output "[WARN] $Message"
}

function Write-Fail {
  param([string]$Message)
  $script:Failures++
  Write-Output "[FAIL] $Message"
}

function Test-CdpEndpoint {
  param([string]$BaseUrl)

  try {
    Invoke-RestMethod -Uri "$BaseUrl/json/version" -TimeoutSec 1 | Out-Null
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

Write-Output "playwright-cli-cdp environment check"
Write-Output "Endpoint: $Endpoint"
Write-Output ""

Write-Ok "platform: Windows PowerShell"

$PlaywrightCli = Get-Command playwright-cli -ErrorAction SilentlyContinue
if ($PlaywrightCli) {
  $Version = try { (& playwright-cli --version 2>$null | Select-Object -First 1) } catch { "" }
  Write-Ok "playwright-cli is available$(if ($Version) { ": $Version" })"
} else {
  $Npx = Get-Command npx -ErrorAction SilentlyContinue
  if ($Npx) {
    $NpxVersion = try { (& npx --no-install playwright-cli --version 2>$null | Select-Object -First 1) } catch { "" }
    if ($LASTEXITCODE -eq 0 -and $NpxVersion) {
      Write-Ok "local playwright-cli is available through npx: $NpxVersion"
    } else {
      Write-Fail "playwright-cli is not available; install it or provide a local package usable with npx --no-install"
    }
  } else {
    Write-Fail "playwright-cli is not available and npx was not found"
  }
}

$EndpointReady = Test-CdpEndpoint $Endpoint
if ($EndpointReady) {
  Write-Ok "CDP endpoint is reachable: $Endpoint"
} else {
  Write-Warn "CDP endpoint is not reachable yet: $Endpoint"
}

$ChromePath = Find-Chrome
if ($ChromePath) {
  Write-Ok "Chrome-family browser found: $ChromePath"
} elseif ($EndpointReady) {
  Write-Warn "Chrome-family browser was not found locally, but an existing CDP endpoint is reachable"
} else {
  Write-Fail "Chrome, Chromium, or Edge was not found; set CHROME_BIN or provide an existing CDP endpoint"
}

if ($HostName -eq "0.0.0.0") {
  Write-Warn "CDP_HOST=0.0.0.0 can expose browser data to the network; prefer 127.0.0.1 when possible"
}

if (-not $EndpointReady) {
  if ($EndpointProvided) {
    Write-Warn "CDP_ENDPOINT is set; skipped local port $Port conflict check"
  } else {
    try {
      $Listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop | Select-Object -First 1
      if ($Listener) {
        Write-Warn "port $Port is in use but does not look like a reachable CDP endpoint"
      }
    } catch {
      $NetstatOutput = try { netstat -ano | Select-String ":$Port" | Select-Object -First 1 } catch { $null }
      if ($NetstatOutput) {
        Write-Warn "port $Port may be in use but does not look like a reachable CDP endpoint"
      } else {
        Write-Ok "port $Port is available"
      }
    }
  }
}

Write-Output ""
Write-Output "Summary: $Failures failure(s), $Warnings warning(s)"
if ($Failures -gt 0) {
  exit 1
}
