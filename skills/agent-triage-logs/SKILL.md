---
name: agent-triage-logs
description: |
  Automated log triage using Datadog CLI. Scans for errors, tracks patterns over time,
  and alerts on suspicious activity. Run periodically via cron or on-demand.
  Trigger phrases: "triage logs", "check for errors", "scan datadog", "error report".
---

# Agent Triage Logs

Automated error scanning and reporting using Datadog CLI.

## Quick Start

```bash
# Run a triage scan now
npx @ctdio/datadog-cli errors --from 1h
npx @ctdio/datadog-cli spans errors --from 1h
```

## Workflow

### 1. Scan for Errors

Run these commands to get the current error landscape:

```bash
# Log errors summary
npx @ctdio/datadog-cli errors --from 6h

# APM/span errors
npx @ctdio/datadog-cli spans errors --from 6h

# Compare to previous period (is this new?)
npx @ctdio/datadog-cli logs compare --query "status:error" --period 6h

# Find error patterns
npx @ctdio/datadog-cli logs patterns --query "status:error" --from 6h --limit 500
```

### 2. Assess Severity

Flag as **ALERT** if any of these are true:
- Error count increased >50% vs previous period
- New error pattern not seen in previous reports
- Any 5xx errors on critical services (api, auth, payments)
- Error rate >10 errors/minute sustained

Flag as **WARNING** if:
- Error count increased 20-50%
- Recurring pattern from previous reports still present
- Degraded response times (>2s p95)

Flag as **OK** if:
- Error count stable or decreased
- No new patterns
- All services healthy

### 3. Write Report

Reports go to: `~/.triage-reports/`

**Filename format:** `YYYY-MM-DD-HHmm.md`

**Report template:**

```markdown
# Triage Report - {timestamp}

## Status: {ALERT|WARNING|OK}

## Summary
- Total errors (6h): {count}
- Change vs previous: {+/-}%
- Services affected: {list}

## Top Error Patterns
1. {pattern} - {count} occurrences
2. {pattern} - {count} occurrences
...

## Service Breakdown
| Service | Errors | Status |
|---------|--------|--------|
| {name}  | {count}| {ok/warn/error} |

## New Issues (not in previous report)
- {description}

## Recurring Issues
- {description} (first seen: {date})

## Recommendations
- {action item}

## Raw Data
<details>
<summary>Full error output</summary>

{paste raw CLI output here}

</details>
```

### 4. Alert if Needed

If status is **ALERT**:
- The agent should immediately notify via the messaging system
- Include: status, top 3 issues, recommended actions

If status is **WARNING**:
- Note in report, no immediate notification needed

### 5. Track Over Time

Before writing a new report, read the previous report to:
- Identify recurring vs new issues
- Track if error counts are trending up/down
- Note any patterns that resolved

## Directory Structure

```
~/.triage-reports/
├── 2026-02-01-0600.md
├── 2026-02-01-1200.md
├── 2026-02-01-1800.md
├── ...
└── summary.json  # Optional: machine-readable summary for trending
```

## Environment Requirements

Ensure these are set:
```bash
export DD_API_KEY="..."
export DD_APP_KEY="..."
```

## Example Cron Task Prompt

When triggered by cron, the agent should:

1. Read this skill file
2. Run the Datadog CLI commands
3. Compare to previous report (if exists)
4. Write new report to ~/.triage-reports/
5. If ALERT status, send notification to Charlie
6. Commit the report to dotfiles (optional)

## Services to Monitor

Primary (always check):
- api
- auth
- web

Secondary (check if errors found):
- workers
- scheduler
- webhooks
