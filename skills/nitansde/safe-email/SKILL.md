---
name: safe-email
description: Privacy-first workflow for processing explicitly forwarded emails via IMAP and creating calendar/reminder entries. Use only when the user explicitly asks to process the latest forwarded email in a dedicated mailbox. Requires IMAP credentials and a configured calendar/reminder integration; destructive deletion is opt-in and must be explicitly confirmed.
metadata:
  credentialsRequired:
    - imap_username
    - imap_app_password_or_oauth
    - calendar_integration_credentials
    - reminder_integration_credentials
  envRequired:
    - SAFE_EMAIL_IMAP_USERNAME
    - SAFE_EMAIL_IMAP_APP_PASSWORD
  secretSourcesAccepted:
    - env
    - os_keychain
    - secure_config_ref
    - oauth_token_store
  openclaw:
    requires:
      bins: ["himalaya"]
      credentials:
        - imap_username
        - imap_app_password_or_oauth
        - calendar_integration_credentials
        - reminder_integration_credentials
      env:
        - SAFE_EMAIL_IMAP_USERNAME
        - SAFE_EMAIL_IMAP_APP_PASSWORD
      secretSources:
        - env
        - os_keychain
        - secure_config_ref
        - oauth_token_store
      recommendedSecretSource: os_keychain_or_secure_config_ref
    capabilities:
      - imap_read_latest_only
      - calendar_write
      - reminder_write
      - email_delete_optional
    compliance:
      explicitTriggerRequired: true
      autoPollingForbidden: true
      destructiveActionsNeedConsent: true
      forwardToDedicatedInboxRequired: true
---

# Safe Email (Privacy-First)

Use this skill to process forwarded emails safely and convert actionable items into:
- calendar events, and/or
- reminders/tasks

This skill is intentionally **conservative** and **opt-in only**.

## Required access and credentials (must be declared to users)

This workflow needs:
1. **IMAP mailbox access** to a dedicated inbox (username + app password/OAuth)
2. **Calendar write access** (any user-selected calendar system)
3. **Reminder/task write access** (any user-selected reminder system)
4. Optional **email deletion permission** (only if user enables post-processing deletion)

If any of the above is missing, run in read/parse-only mode and ask user what to do next.

## Required credentials and accepted secret sources

Required credentials before first run:
- IMAP username (dedicated inbox address)
- IMAP app password or OAuth token
- Calendar integration credential/config (provider-specific)
- Reminder integration credential/config (provider-specific)

Accepted secret sources:
- Environment variables (example: `SAFE_EMAIL_IMAP_USERNAME`, `SAFE_EMAIL_IMAP_APP_PASSWORD`)
- OS keychain / credential store
- Secure config references (secret refs)
- OAuth token store

Policy:
- Credentials are required; **source is flexible**.
- Prefer OS keychain or secure config references over plaintext.
- Never store plaintext secrets inside the skill package.

## What users must know first

1. **Use a dedicated email inbox** (recommended: a brand-new Gmail account) for AI processing.
   - Do not connect a personal primary inbox.
   - Keep this mailbox purpose-limited (only forwarded emails for automation).

2. **Forward emails to that dedicated inbox** before asking the assistant to process them.
   - If users do not forward the email, there may be nothing to parse.
   - State this clearly in user-facing instructions.

3. **IMAP access requires a Gmail App Password** (for Gmail with 2FA enabled).

## Security rules (non-negotiable)

1. **Never auto-check email** without explicit user instruction.
   - No background polling.
   - No scheduled inbox scans unless user explicitly sets one up.

2. **Process minimally**.
   - Read only what is needed.
   - Prefer the newest relevant message for the requested action.

3. **Destructive deletion is opt-in**.
   - Do not delete by default.
   - Delete only when user explicitly says to delete after processing (globally or per run).

4. **Ask before ambiguous actions**.
   - If the email content is unclear (time, timezone, destination system, duplicates), ask first.

## Setup guide (Gmail + IMAP)

### 1) Create a dedicated Gmail account

Create a separate Gmail mailbox specifically for assistant workflows.

### 2) Enable 2-Step Verification on that account

Gmail App Password requires 2FA.

### 3) Create an App Password

In Google Account security settings:
- Go to **App passwords**
- Create a new app password for Mail/IMAP usage
- Store it in a secure secret manager or OS keychain

### 4) Configure IMAP/SMTP client (example: Himalaya)

Use standard Gmail servers:
- IMAP: `imap.gmail.com:993` (TLS)
- SMTP: `smtp.gmail.com:587` (STARTTLS)

Prefer command/keychain-based secret retrieval instead of plaintext passwords.

Example (conceptual):
```toml
backend.type = "imap"
backend.host = "imap.gmail.com"
backend.port = 993
backend.encryption.type = "tls"
backend.login = "your-dedicated-inbox@gmail.com"
backend.auth.type = "password"
backend.auth.cmd = "<secure-command-to-read-app-password>"

message.send.backend.type = "smtp"
message.send.backend.host = "smtp.gmail.com"
message.send.backend.port = 587
message.send.backend.encryption.type = "start-tls"
message.send.backend.login = "your-dedicated-inbox@gmail.com"
message.send.backend.auth.type = "password"
message.send.backend.auth.cmd = "<secure-command-to-read-app-password>"
```

## Execution workflow

### Step 0 — Require explicit trigger

Only proceed when user says something like:
- “I just forwarded an email, process it.”
- “Read the latest forwarded email and create calendar/reminder entries.”

If not explicitly asked: stop.

### Step 1 — Read newest relevant email only

- List recent messages in inbox.
- Open only the newest candidate relevant to the user’s request.
- Avoid bulk reading old or unrelated emails.

### Step 2 — Extract structured details

Extract as available:
- title/subject
- date/time window
- timezone (if absent, ask or use user's configured timezone and state assumption)
- location
- links
- notes/details (e.g., confirmation number, participants)
- action type (event vs reminder vs both)

If date/time is missing or ambiguous, ask user before creating entries.

### Step 2.5 — Safety checks before writing

- Perform duplicate check against recent calendar/reminder entries (title + date/time proximity).
- Present a concise write preview when confidence is low.
- If confidence is high and user requested "auto-create", proceed and report exactly what was written.

### Step 3 — Create output in user’s preferred systems

This skill is calendar/reminder-system agnostic.
Use whatever tools the user already uses (Apple Calendar, Google Calendar, Notion tasks, Reminders, etc.).

Minimum expected output objects:
- **Calendar event**: title, start, end/duration, timezone, location, notes
- **Reminder/task**: title, due date/time (if known), notes, optional priority/list

### Step 4 — Optional deletion of processed email content

Only if user enabled deletion policy (global policy or explicit per-run consent):
1. Move processed email to Trash
2. Permanently delete/expunge when supported
3. Confirm deletion status to user

If deletion is not enabled, leave email untouched and confirm that no deletion was performed.

### Step 5 — Return concise confirmation

Include:
- what was created (event/reminder)
- key parsed fields (time/location)
- whether deletion was performed (yes/no)
- any unresolved ambiguity

## Failure handling

- If parsing fails: provide extracted partial fields and request confirmation.
- If calendar/reminder creation fails: do not delete email.
- If deletion fails: clearly report “processed but not fully deleted yet,” then retry only with user consent.

## Default privacy posture

- Explicit user trigger only
- Minimum necessary access
- No automatic surveillance behavior
- Deletion only with explicit consent
- Clear user-visible audit summary each run
