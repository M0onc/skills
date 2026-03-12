---
name: email
description: On-demand email checking with AI summarization. Supports Gmail, Outlook/M365, Google Workspace, and custom IMAP.
homepage: https://clawhub.ai/skills/email
metadata: {"clawdbot":{"emoji":"📧","requires":{"bins":["node"]}}}
---

# email

Check emails on demand, get AI summaries, and generate digests. Supports multiple accounts with IMAP and OAuth2.

## Quick Start

```bash
# 1. Configure AI (for email summaries)
node .../cli.js config ai_api_key <YOUR_DEEPSEEK_OR_OPENAI_KEY>

# 2. Add an email account
node .../cli.js setup user@gmail.com --password <APP_PASSWORD>

# 3. Check emails
node .../cli.js check --summarize
```

## CLI Path

```
node /Users/jundong/.openclaw/workspace/skills/email/cli.js <command> [options]
```

## Commands

### config — Configure API keys

```bash
# Show all config
node .../cli.js config

# Set AI API key (DeepSeek, OpenAI, or any compatible API)
node .../cli.js config ai_api_key sk-xxx

# Set API base URL (default: https://api.deepseek.com)
node .../cli.js config ai_api_base https://api.openai.com/v1

# Set AI model (default: deepseek-chat)
node .../cli.js config ai_model gpt-4o-mini

# Set Microsoft OAuth2 Client ID (for Outlook/M365)
node .../cli.js config ms_client_id <CLIENT_ID>
node .../cli.js config ms_tenant_id <TENANT_ID>
```

Config can also be set via environment variables with `EMAIL_SKILL_` prefix:
- `EMAIL_SKILL_AI_API_KEY`
- `EMAIL_SKILL_AI_API_BASE`
- `EMAIL_SKILL_MS_CLIENT_ID`

### check — Check new emails

```bash
# Check all accounts, last 60 minutes
node .../cli.js check

# With AI summaries
node .../cli.js check --summarize

# Specific account, last 4 hours, max 5
node .../cli.js check --account user@example.com --since 240 --max 5
```

Options:
- `--max N` — max emails to return (default: 10)
- `--since M` — look back M minutes (default: 60)
- `--summarize` — include AI summary for each email
- `--account EMAIL` — filter to specific account

### read — Read a specific email

```bash
node .../cli.js read <uid> [--account EMAIL]
```

Returns full email body + AI summary.

### digest — Generate email digest

```bash
# Last 24 hours
node .../cli.js digest

# Last 8 hours
node .../cli.js digest --since 480

# Specific account
node .../cli.js digest --account user@example.com
```

Returns an AI-generated summary grouped by importance (urgent / notable / ignorable).

### accounts — List configured accounts

```bash
node .../cli.js accounts
```

### setup — Add email account

```bash
# Gmail / Google Workspace (needs App Password)
node .../cli.js setup user@gmail.com --password <APP_PASSWORD>

# Outlook / M365 with OAuth2 (interactive)
node .../cli.js setup user@outlook.com --auth oauth

# Outlook / M365 with App Password
node .../cli.js setup user@company.com --auth password --password <APP_PASSWORD>
```

### remove — Remove email account

```bash
node .../cli.js remove user@gmail.com
```

## Output

All commands output JSON for easy parsing.

## Setup Guides

**Gmail App Password:**
Google Account → Security → 2-Step Verification → App passwords

**Outlook OAuth2:**
Requires an Azure AD app with `Mail.Read` permission and device code flow enabled. Set `ms_client_id` and `ms_tenant_id` via config.

**Outlook App Password:**
mysignins.microsoft.com → Security info → Add sign-in method → App password

## Data Storage

- Credentials: `skills/email/data/email.db` (SQLite)
- Config: `skills/email/data/config.json`
