# Request Mocking

Examples use the Bash wrapper. On Windows PowerShell replace `bash scripts/playwright-cdp.sh` with `powershell -ExecutionPolicy Bypass -File scripts\playwright-cdp.ps1`.

Intercept, mock, modify, or block network requests.

## CLI route commands

```bash
# Mock with a custom status code
bash scripts/playwright-cdp.sh -s=cdp route "**/*.jpg" --status=404

# Mock with a JSON body
bash scripts/playwright-cdp.sh -s=cdp route "**/api/users" --body='[{"id":1,"name":"Alice"}]' --content-type=application/json

# Mock with custom response headers
bash scripts/playwright-cdp.sh -s=cdp route "**/api/data" --body='{"ok":true}' --header="X-Custom: value"

# Strip headers from outgoing requests
bash scripts/playwright-cdp.sh -s=cdp route "**/*" --remove-header=cookie,authorization

# List active routes
bash scripts/playwright-cdp.sh -s=cdp route-list

# Remove a specific route
bash scripts/playwright-cdp.sh -s=cdp unroute "**/*.jpg"

# Remove all routes
bash scripts/playwright-cdp.sh -s=cdp unroute
```

## URL patterns

```
**/api/users           - exact path match
**/api/*/details       - wildcard segment in path
**/*.{png,jpg,jpeg}    - multiple file extensions
**/search?q=*          - query parameter match
```

## Advanced mocking with run-code

Use `run-code` when you need conditional responses, request body inspection, real response modification, or simulated delays. Routes set through `run-code` persist for the lifetime of the page session.

### Conditional response based on request body

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.route('**/api/login', route => {
    const body = route.request().postDataJSON();
    if (body.username === 'admin') {
      route.fulfill({ body: JSON.stringify({ token: 'mock-token' }) });
    } else {
      route.fulfill({ status: 401, body: JSON.stringify({ error: 'Invalid credentials' }) });
    }
  });
}"
```

### Modify a real response

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.route('**/api/user', async route => {
    const response = await route.fetch();
    const json = await response.json();
    json.isPremium = true;
    await route.fulfill({ response, json });
  });
}"
```

### Simulate network failure

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.route('**/api/offline', route => route.abort('internetdisconnected'));
}"
# Other abort reasons: connectionrefused, timedout, connectionreset
```

### Delay a response

```bash
bash scripts/playwright-cdp.sh -s=cdp run-code "async page => {
  await page.route('**/api/slow', async route => {
    await new Promise(r => setTimeout(r, 3000));
    route.fulfill({ body: JSON.stringify({ data: 'loaded' }) });
  });
}"
```
