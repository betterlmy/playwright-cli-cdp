#!/usr/bin/env bash
set -euo pipefail

HOST="${CDP_HOST:-127.0.0.1}"
PORT="${CDP_PORT:-9222}"
USER_DATA_DIR="${CDP_USER_DATA_DIR:-$HOME/.cache/playwright-cli-cdp/chrome-profile}"
START_URL="${1:-about:blank}"
LOG_FILE="${CDP_LOG_FILE:-/tmp/playwright-cli-cdp-chrome.log}"
TIMEOUT_SECONDS="${CDP_TIMEOUT_SECONDS:-15}"

endpoint="http://${HOST}:${PORT}"

case "$TIMEOUT_SECONDS" in
  ''|*[!0-9]*) TIMEOUT_SECONDS=15 ;;
esac
if (( TIMEOUT_SECONDS < 1 )); then
  TIMEOUT_SECONDS=15
fi

probe_endpoint() {
  curl -fsS --max-time 1 "${endpoint}/json/version" >/dev/null 2>&1
}

wait_for_endpoint() {
  local deadline=$((SECONDS + TIMEOUT_SECONDS))
  while (( SECONDS < deadline )); do
    if probe_endpoint; then
      return 0
    fi
    sleep 0.2
  done
  probe_endpoint
}

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

launch_chrome() {
  local args=(
    "--remote-debugging-address=$HOST"
    "--remote-debugging-port=$PORT"
    "--user-data-dir=$USER_DATA_DIR"
    "--no-first-run"
    "--no-default-browser-check"
    "$START_URL"
  )

  if [[ "$(uname -s 2>/dev/null || true)" == "Darwin" && "$chrome_bin" == *.app/Contents/MacOS/* ]]; then
    local app_path="${chrome_bin%%.app/*}.app"
    if [[ -d "$app_path" && -x /usr/bin/open ]]; then
      /usr/bin/open -n -a "$app_path" --args "${args[@]}" >>"$LOG_FILE" 2>&1
      return 0
    fi
  fi

  if command -v setsid >/dev/null 2>&1; then
    setsid "$chrome_bin" "${args[@]}" >"$LOG_FILE" 2>&1 </dev/null &
  else
    nohup "$chrome_bin" "${args[@]}" >"$LOG_FILE" 2>&1 </dev/null &
  fi
}

if probe_endpoint; then
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

launch_chrome

if wait_for_endpoint; then
  printf 'Chrome remote debugging is available: %s\n' "$endpoint"
  printf 'User data dir: %s\n' "$USER_DATA_DIR"
  exit 0
fi

cat >&2 <<EOF
Chrome was started but CDP did not become ready at ${endpoint} within ${TIMEOUT_SECONDS}s.
Log file: ${LOG_FILE}
EOF
exit 1
