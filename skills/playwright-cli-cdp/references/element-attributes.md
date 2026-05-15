# Element Attribute Inspection

Examples use the Bash wrapper. On Windows PowerShell replace `bash scripts/playwright-cdp.sh` with `powershell -ExecutionPolicy Bypass -File scripts\playwright-cdp.ps1`.

When a snapshot does not show an element's `id`, `class`, `data-*`, or other DOM attributes, use `eval` to inspect them directly.

## Examples

```bash
bash scripts/playwright-cdp.sh -s=cdp snapshot
# snapshot shows a button as e7 but no id or data attributes

# Get element id
bash scripts/playwright-cdp.sh -s=cdp eval "el => el.id" e7

# Get all CSS classes
bash scripts/playwright-cdp.sh -s=cdp eval "el => el.className" e7

# Get a specific attribute
bash scripts/playwright-cdp.sh -s=cdp eval "el => el.getAttribute('data-testid')" e7
bash scripts/playwright-cdp.sh -s=cdp eval "el => el.getAttribute('aria-label')" e7

# Get a computed style property
bash scripts/playwright-cdp.sh -s=cdp eval "el => getComputedStyle(el).display" e7
```

Use `--raw` to capture values for scripting:

```bash
TESTID=$(bash scripts/playwright-cdp.sh -s=cdp --raw eval "el => el.getAttribute('data-testid')" e7)
```
