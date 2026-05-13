#!/usr/bin/env bash
set -euo pipefail

HOST="${CDP_HOST:-127.0.0.1}"
PORT="${CDP_PORT:-9222}"
USER_DATA_DIR="${CDP_USER_DATA_DIR:-$HOME/.cache/playwright-cli-cdp/chrome-profile}"
START_URL="${1:-about:blank}"
LOG_FILE="${CDP_LOG_FILE:-/tmp/playwright-cli-cdp-chrome.log}"

endpoint="http://${HOST}:${PORT}"

find_chrome() {
  if [[ -n "${CHROME_BIN:-}" ]]; then
    printf '%s\n' "$CHROME_BIN"
    return 0
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

if curl -fsS "${endpoint}/json/version" >/dev/null 2>&1; then
  printf 'Chrome remote debugging is already available: %s\n' "$endpoint"
  exit 0
fi

chrome_bin="$(find_chrome || true)"
if [[ -z "$chrome_bin" ]]; then
  cat >&2 <<'EOF'
Could not find Chrome, Chromium, or Edge.
Set CHROME_BIN to the browser executable path and retry, for example:
  CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" bash scripts/open-chrome-remote.sh
EOF
  exit 1
fi

mkdir -p "$USER_DATA_DIR"

"$chrome_bin" \
  --remote-debugging-address="$HOST" \
  --remote-debugging-port="$PORT" \
  --user-data-dir="$USER_DATA_DIR" \
  --no-first-run \
  --no-default-browser-check \
  "$START_URL" >"$LOG_FILE" 2>&1 &

for _ in {1..50}; do
  if curl -fsS "${endpoint}/json/version" >/dev/null 2>&1; then
    printf 'Chrome remote debugging is available: %s\n' "$endpoint"
    printf 'User data dir: %s\n' "$USER_DATA_DIR"
    exit 0
  fi
  sleep 0.1
done

cat >&2 <<EOF
Chrome was started but CDP did not become ready at ${endpoint}.
Log file: ${LOG_FILE}
EOF
exit 1
