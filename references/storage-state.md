# Storage Management

Examples use the Bash wrapper. On Windows PowerShell replace `bash scripts/playwright-cdp.sh` with `powershell -ExecutionPolicy Bypass -File scripts\playwright-cdp.ps1`.

Manage cookies, localStorage, sessionStorage, and full browser storage state. CDP attach connects to the external browser's existing profile and may include real session data — be aware of sensitive information before saving state files.

## Storage state

Save and restore complete browser state (cookies + localStorage).

```bash
# Save to an auto-generated filename
bash scripts/playwright-cdp.sh -s=cdp state-save

# Save to a specific file
bash scripts/playwright-cdp.sh -s=cdp state-save auth.json

# Load storage state
bash scripts/playwright-cdp.sh -s=cdp state-load auth.json
# Reload the page so cookies take effect
bash scripts/playwright-cdp.sh -s=cdp goto https://example.com
```

Saved files follow this structure:

```json
{
  "cookies": [
    {
      "name": "session_id",
      "value": "abc123",
      "domain": "example.com",
      "path": "/",
      "expires": 1735689600,
      "httpOnly": true,
      "secure": true,
      "sameSite": "Lax"
    }
  ],
  "origins": [
    {
      "origin": "https://example.com",
      "localStorage": [
        { "name": "theme", "value": "dark" }
      ]
    }
  ]
}
```

## Cookies

```bash
bash scripts/playwright-cdp.sh -s=cdp cookie-list
bash scripts/playwright-cdp.sh -s=cdp cookie-list --domain=example.com
bash scripts/playwright-cdp.sh -s=cdp cookie-list --path=/api
bash scripts/playwright-cdp.sh -s=cdp cookie-get session_id
bash scripts/playwright-cdp.sh -s=cdp cookie-set session_id abc123
bash scripts/playwright-cdp.sh -s=cdp cookie-set session_id abc123 \
  --domain=example.com --path=/ --httpOnly --secure --sameSite=Lax
bash scripts/playwright-cdp.sh -s=cdp cookie-set remember_me token123 --expires=1735689600
bash scripts/playwright-cdp.sh -s=cdp cookie-delete session_id
bash scripts/playwright-cdp.sh -s=cdp cookie-clear
```

For multiple cookies or complex options use `run-code`:

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.context().addCookies([
    { name: 'session_id', value: 'sess_abc123', domain: 'example.com', path: '/', httpOnly: true },
    { name: 'prefs', value: JSON.stringify({ theme: 'dark' }), domain: 'example.com', path: '/' }
  ]);
}"
```

## localStorage

```bash
bash scripts/playwright-cdp.sh -s=cdp localstorage-list
bash scripts/playwright-cdp.sh -s=cdp localstorage-get token
bash scripts/playwright-cdp.sh -s=cdp localstorage-set theme dark
bash scripts/playwright-cdp.sh -s=cdp localstorage-set user_settings '{"theme":"dark","language":"en"}'
bash scripts/playwright-cdp.sh -s=cdp localstorage-delete token
bash scripts/playwright-cdp.sh -s=cdp localstorage-clear
```

## sessionStorage

```bash
bash scripts/playwright-cdp.sh -s=cdp sessionstorage-list
bash scripts/playwright-cdp.sh -s=cdp sessionstorage-get form_data
bash scripts/playwright-cdp.sh -s=cdp sessionstorage-set step 3
bash scripts/playwright-cdp.sh -s=cdp sessionstorage-delete step
bash scripts/playwright-cdp.sh -s=cdp sessionstorage-clear
```

## IndexedDB

```bash
# List databases
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  return await page.evaluate(async () => indexedDB.databases());
}"

# Delete a database
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.evaluate(() => indexedDB.deleteDatabase('myDatabase'));
}"
```

## Reuse authentication state

```bash
# Step 1: attach and complete login
bash scripts/playwright-cdp.sh -s=cdp attach --cdp=http://127.0.0.1:9222
bash scripts/playwright-cdp.sh -s=cdp goto https://app.example.com/login
bash scripts/playwright-cdp.sh -s=cdp snapshot
bash scripts/playwright-cdp.sh -s=cdp fill e1 "user@example.com"
bash scripts/playwright-cdp.sh -s=cdp fill e2 "password123"
bash scripts/playwright-cdp.sh -s=cdp click e3

# Save state after a successful login
bash scripts/playwright-cdp.sh -s=cdp state-save auth.json

# Step 2: restore state in a later session to skip login
bash scripts/playwright-cdp.sh -s=cdp state-load auth.json
bash scripts/playwright-cdp.sh -s=cdp goto https://app.example.com/dashboard
```

## Security notes

- Do not commit state files containing auth tokens.
- Add `*.auth-state.json` to `.gitignore`.
- Delete sensitive state files after use.
- CDP attach may expose the real browser's session — confirm necessity before reading or exporting.
