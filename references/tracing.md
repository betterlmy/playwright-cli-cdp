# Tracing

Examples use the Bash wrapper. On Windows PowerShell replace `bash scripts/playwright-cdp.sh` with `powershell -ExecutionPolicy Bypass -File scripts\playwright-cdp.ps1`.

Capture detailed execution traces for debugging and analysis. Traces include DOM snapshots, screenshots, network activity, and console logs.

## Basic usage

```bash
bash scripts/playwright-cdp.sh -s=cdp tracing-start
bash scripts/playwright-cdp.sh -s=cdp goto https://example.com
bash scripts/playwright-cdp.sh -s=cdp click e1
bash scripts/playwright-cdp.sh -s=cdp fill e2 "test"
bash scripts/playwright-cdp.sh -s=cdp tracing-stop
```

## Trace output

After stopping, Playwright writes to a `traces/` directory:

| File | Contents |
|---|---|
| `trace-{timestamp}.trace` | Actions, DOM snapshots before/after each step, screenshots, console messages, timing |
| `trace-{timestamp}.network` | All HTTP requests and responses, headers, bodies, timing, resource sizes |
| `resources/` | Cached assets needed for replay |

## Use cases

### Debug a failing action

```bash
bash scripts/playwright-cdp.sh -s=cdp tracing-start
bash scripts/playwright-cdp.sh -s=cdp goto https://app.example.com
bash scripts/playwright-cdp.sh -s=cdp click e5
bash scripts/playwright-cdp.sh -s=cdp tracing-stop
```

### Performance analysis

```bash
bash scripts/playwright-cdp.sh -s=cdp tracing-start
bash scripts/playwright-cdp.sh -s=cdp goto https://slow-site.com
bash scripts/playwright-cdp.sh -s=cdp tracing-stop
```

Use the network waterfall in the trace to identify slow resources.

### Capture evidence for a multi-step flow

```bash
bash scripts/playwright-cdp.sh -s=cdp tracing-start
bash scripts/playwright-cdp.sh -s=cdp goto https://app.example.com/checkout
bash scripts/playwright-cdp.sh -s=cdp fill e1 "4111111111111111"
bash scripts/playwright-cdp.sh -s=cdp fill e2 "12/25"
bash scripts/playwright-cdp.sh -s=cdp fill e3 "123"
bash scripts/playwright-cdp.sh -s=cdp click e4
bash scripts/playwright-cdp.sh -s=cdp tracing-stop
```

## Tracing vs video vs screenshot

| Feature | Trace | Video | Screenshot |
|---|---|---|---|
| DOM inspection | Yes | No | No |
| Network details | Yes | No | No |
| Step-by-step replay | Yes | Continuous | Single frame |
| File size | Medium | Large | Small |
| Best for | Debugging | Demos | Quick capture |

## Clean up old traces

```bash
find .playwright-cli/traces -mtime +7 -delete
```

Tracing adds overhead and trace files can grow large — clean up regularly or only enable tracing around the area of interest.
