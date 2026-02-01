---
name: agent-triage-logs
description: |
  Automated log triage using Datadog and Sentry CLIs. Scans for errors, identifies NEW issues
  worth investigating, and alerts on suspicious activity. Run periodically via cron or on-demand.
  Trigger phrases: "triage logs", "check for errors", "scan datadog", "error report", "new issues".
---

# Agent Triage Logs

Automated error scanning and reporting using Datadog CLI and Sentry CLI.

## Quick Start

```bash
# Datadog: error summary
npx @ctdio/datadog-cli errors --from 6h

# Sentry: list unresolved issues (most recent first)
sentry-cli issues list -o opine -p platform --status unresolved
```

## Workflow

### 1. Scan Datadog for Log Errors

```bash
# Log errors summary
npx @ctdio/datadog-cli errors --from 6h

# Compare to previous period (is this new?)
npx @ctdio/datadog-cli logs compare --query "status:error" --period 6h

# Find error patterns
npx @ctdio/datadog-cli logs patterns --query "status:error" --from 6h --limit 500
```

### 2. Scan Sentry for New Issues

```bash
# List unresolved issues
sentry-cli issues list -o opine -p platform --status unresolved
```

**Focus on issues that are:**
- **Recently first seen** (within last 24-48h) — these are NEW bugs
- **High frequency** in a short time — something broke
- **Affecting critical paths** (api, auth, payments, core features)

**Ignore/deprioritize:**
- Old recurring issues (first seen weeks/months ago)
- Expected integration errors (token refresh, rate limits, disconnected users)
- Third-party API issues outside our control

### 3. Identify Issues Worth Investigating

Flag as **🚨 INVESTIGATE** if:
- New issue (first seen < 48h ago) with high event count
- Error in critical service (api, auth, core features)
- User-facing 5xx errors
- Database errors (Prisma) that aren't transient
- New error pattern not seen before

Flag as **⚠️ MONITOR** if:
- Known issue with increasing frequency
- Rate limit errors trending up
- Integration issues affecting multiple customers

Flag as **✅ KNOWN/OK** if:
- Expected integration noise (token refresh for churned customers)
- Rate limits from external APIs (Zoom, Salesforce)
- Old recurring issues that are being tracked

### 4. Write Report

Reports go to: `~/.triage-reports/`

**Filename format:** `YYYY-MM-DD-HHmm.md`

**Report template:**

```markdown
# Triage Report - {timestamp}

## Overall Status: {🚨 ALERT | ⚠️ WARNING | ✅ OK}

## 🆕 New Issues Worth Investigating
Issues first seen in last 48h that need attention:

| Issue | Title | First Seen | Events | Priority |
|-------|-------|------------|--------|----------|
| PLATFORM-XXX | {title} | {date} | {count} | 🚨/⚠️ |

### Details
For each new issue worth investigating:
- **What:** {error description}
- **Where:** {service/endpoint}
- **Impact:** {user-facing? data loss? degraded experience?}
- **Suggested action:** {investigate, fix, monitor}

## 📊 Datadog Summary
- Total errors (6h): {count}
- Change vs previous: {+/-}%
- Top services affected: {list}

## 🔇 Known Issues (no action needed)
- {count} recurring integration errors (token refresh, rate limits)
- {count} expected third-party API errors

## Recommendations
1. {action item for new issues}
2. {any patterns to watch}
```

### 5. Alert if Needed

**Immediately notify Charlie if:**
- New critical bug in core service
- Spike in user-facing errors
- Database issues that could affect data integrity

**Don't alert for:**
- Expected integration noise
- Old recurring issues
- Rate limits from external APIs

## Services to Monitor

**Critical (always flag new issues):**
- opine-platform-app (main API)
- opine-platform-inngest (background jobs)

**Known Noise Sources (usually ignorable):**
- Salesforce token refresh (churned customers)
- Zoom rate limits
- Missing credentials for disconnected integrations

## Environment Requirements

```bash
# Datadog
export DD_API_KEY="..."
export DD_APP_KEY="..."

# Sentry (configured via sentry-cli login or SENTRY_AUTH_TOKEN)
```

## Example Triage Questions

When reviewing issues, ask:
1. **Is this new?** Check "first seen" date
2. **Is it user-facing?** Does it cause 5xx or broken features?
3. **Is it actionable?** Can we fix it, or is it external?
4. **Is it trending?** Getting worse or stable?

Focus your report on **actionable new issues**, not noise.
