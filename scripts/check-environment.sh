#!/usr/bin/env bash
set -uo pipefail

HOST="${CDP_HOST:-127.0.0.1}"
PORT="${CDP_PORT:-9222}"
ENDPOINT="${CDP_ENDPOINT:-http://${HOST}:${PORT}}"

failures=0
warnings=0

ok() {
  printf '[OK] %s\n' "$1"
}

warn() {
  warnings=$((warnings + 1))
  printf '[WARN] %s\n' "$1"
}

fail() {
  failures=$((failures + 1))
  printf '[FAIL] %s\n' "$1"
}

find_chrome() {
  if [[ -n "${CHROME_BIN:-}" ]]; then
    if [[ -x "$CHROME_BIN" ]]; then
      printf '%s\n' "$CHROME_BIN"
      return 0
    fi
    return 1
  fi

  local candidates=(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    "google-chrome"
    "google-chrome-stable"
    "chromium"
    "chromium-browser"
    "microsoft-edge"
    "microsoft-edge-stable"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ "$candidate" == */* && -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
    if [[ "$candidate" != */* ]] && command -v "$candidate" >/dev/null 2>&1; then
      command -v "$candidate"
      return 0
    fi
  done

  return 1
}

printf 'playwright-cli-cdp environment check\n'
printf 'Endpoint: %s\n\n' "$ENDPOINT"

case "$(uname -s 2>/dev/null || printf unknown)" in
  Darwin) ok "platform: macOS" ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      ok "platform: WSL2/Linux"
    else
      ok "platform: Linux"
    fi
    ;;
  *) warn "platform could not be identified; continue if Chrome-family CDP is reachable" ;;
esac

if command -v playwright-cli >/dev/null 2>&1; then
  version="$(playwright-cli --version 2>/dev/null | head -n 1 || true)"
  ok "playwright-cli is available${version:+: $version}"
elif command -v npx >/dev/null 2>&1 && npx --no-install playwright-cli --version >/dev/null 2>&1; then
  version="$(npx --no-install playwright-cli --version 2>/dev/null | head -n 1 || true)"
  ok "local playwright-cli is available through npx${version:+: $version}"
else
  fail "playwright-cli is not available; install it or provide a local package usable with npx --no-install"
fi

if command -v curl >/dev/null 2>&1; then
  ok "curl is available"
else
  fail "curl is required by the Bash startup and endpoint checks"
fi

endpoint_ready=false
if command -v curl >/dev/null 2>&1 && curl -fsS "${ENDPOINT}/json/version" >/dev/null 2>&1; then
  endpoint_ready=true
  ok "CDP endpoint is reachable: ${ENDPOINT}"
else
  warn "CDP endpoint is not reachable yet: ${ENDPOINT}"
fi

chrome_path="$(find_chrome || true)"
if [[ -n "$chrome_path" ]]; then
  ok "Chrome-family browser found: ${chrome_path}"
elif [[ "$endpoint_ready" == true ]]; then
  warn "Chrome-family browser was not found locally, but an existing CDP endpoint is reachable"
else
  fail "Chrome, Chromium, or Edge was not found; set CHROME_BIN or provide an existing CDP endpoint"
fi

if [[ "$HOST" == "0.0.0.0" ]]; then
  warn "CDP_HOST=0.0.0.0 can expose browser data to the network; prefer 127.0.0.1 when possible"
fi

if [[ "$endpoint_ready" != true ]]; then
  if [[ -n "${CDP_ENDPOINT:-}" ]]; then
    warn "CDP_ENDPOINT is set; skipped local port ${PORT} conflict check"
  elif command -v lsof >/dev/null 2>&1; then
    if lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
      warn "port ${PORT} is in use but does not look like a reachable CDP endpoint"
    else
      ok "port ${PORT} is available"
    fi
  else
    warn "lsof is not available; skipped port conflict check"
  fi
fi

if grep -qi microsoft /proc/version 2>/dev/null && [[ "$endpoint_ready" != true && -z "$chrome_path" ]]; then
  warn "WSL2 note: start Windows Chrome with scripts/open-chrome-remote.ps1, then attach to localhost or the Windows host IP"
fi

printf '\nSummary: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
if [[ "$failures" -gt 0 ]]; then
  exit 1
fi
