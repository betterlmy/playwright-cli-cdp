# Test Code Generation

Examples use the Bash wrapper. On Windows PowerShell replace `bash scripts/playwright-cdp.sh` with `powershell -ExecutionPolicy Bypass -File scripts\playwright-cdp.ps1`.

Page interaction commands such as `goto`, `click`, and `fill` generate equivalent Playwright TypeScript code in the command output. Collect these snippets to build test files without writing locators by hand.

## Example flow

```bash
bash scripts/playwright-cdp.sh -s=cdp goto https://example.com/login
bash scripts/playwright-cdp.sh -s=cdp snapshot
# Output: e1 [textbox "Email"], e2 [textbox "Password"], e3 [button "Sign In"]

bash scripts/playwright-cdp.sh -s=cdp fill e1 "user@example.com"
# Ran Playwright code:
# await page.getByRole('textbox', { name: 'Email' }).fill('user@example.com');

bash scripts/playwright-cdp.sh -s=cdp fill e2 "password123"
bash scripts/playwright-cdp.sh -s=cdp click e3
```

## Assembling a test file

Copy the generated snippets and add assertions:

```typescript
import { test, expect } from '@playwright/test';

test('login flow', async ({ page }) => {
  await page.goto('https://example.com/login');
  await page.getByRole('textbox', { name: 'Email' }).fill('user@example.com');
  await page.getByRole('textbox', { name: 'Password' }).fill('password123');
  await page.getByRole('button', { name: 'Sign In' }).click();

  await expect(page).toHaveURL(/.*dashboard/);
});
```

## Best practices

### Prefer semantic locators

Generated code uses role-based locators — prefer them over fragile CSS selectors:

```typescript
// Preferred: semantic and resilient
await page.getByRole('button', { name: 'Submit' }).click();

// Avoid: brittle CSS
await page.locator('#submit-btn').click();
```

### Add assertions manually

Generated code records actions only; assertions must be added by hand. Use `generate-locator`, `eval`, and `snapshot` to capture the values you need:

```bash
# Get a stable locator string for use in assertions
bash scripts/playwright-cdp.sh -s=cdp --raw generate-locator e5
# getByRole('button', { name: 'Submit' })

# Capture expected text content
bash scripts/playwright-cdp.sh -s=cdp --raw eval "el => el.textContent" e5

# Capture expected input value
bash scripts/playwright-cdp.sh -s=cdp --raw eval "el => el.value" e5

# Capture an aria snapshot for structural assertions
bash scripts/playwright-cdp.sh -s=cdp --raw snapshot
bash scripts/playwright-cdp.sh -s=cdp --raw snapshot e5
```

Common assertion patterns:

```typescript
await expect(page.getByRole('alert', { name: 'Success' })).toBeVisible();
await expect(page.getByTestId('main-header')).toHaveText('Welcome, user');
await expect(page.getByRole('textbox', { name: 'Email' })).toHaveValue('user@example.com');
await expect(page.getByRole('checkbox', { name: 'Enable notifications' })).toBeChecked();

await expect(page).toMatchAriaSnapshot(`
  - heading "Welcome, user"
  - link /\\d+ new messages?/
  - button "Sign out"
`);

await expect(page.getByRole('navigation')).toMatchAriaSnapshot(`
  - link "Home"
  - link /\\d+ new messages?/
  - link "Profile"
`);
```

If a locator already depends on the element's own text, prefer `toBeVisible()` over `toHaveText()` to avoid redundant matching.

Aria snapshots used for `toMatchAriaSnapshot` do not need to be exhaustive — keep only the parts that matter for the assertion and use regular expressions for dynamic values.
