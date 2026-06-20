---
title: "Security Guide"
parent: "Operations"
nav_order: 6
render_with_liquid: false
---

# Security Guide

## Last Updated

June 20, 2026

This document covers the security architecture, known risks, applied hardening measures, accepted tradeoffs, and penetration testing procedures for The Pool crowdfunding platform.

## Security Architecture

### Authentication Mechanisms

| Mechanism | Endpoints | Description |
|-----------|-----------|-------------|
| **Magic Link Tokens** | `/pledge*`, `/pledges`, `/votes` | HMAC-SHA256 signed tokens with 90-day expiry |
| **Launch Reminder Unsubscribe Tokens** | `GET /launch-reminders/unsubscribe` | Scoped HMAC token that suppresses one campaign/email reminder signup |
| **Stripe Webhook Signature** | `/webhooks/stripe` | HMAC-SHA256 verification per Stripe spec |
| **Admin Dashboard Sessions** | Browser dashboard `/admin/*` APIs | Email magic-link sign-in, signed session cookie, CSRF header on mutations, role/campaign scoping |
| **Campaign Preview Reviewer Tokens** | `/campaigns/:slug/preview/` via `/admin/campaign-preview/:slug` | Short-lived signed reviewer tokens scoped to campaign slug and reviewer email, backed by a 24-hour KV allowlist |
| **Admin Sign-In Challenge** | `POST /admin/auth/start` | Optional Cloudflare Turnstile verification before admin magic-link issuance |
| **Launch Reminder Challenge** | `POST /launch-reminders` | Optional/expected Cloudflare Turnstile verification before reminder signup writes |
| **Admin Recovery Secret** | Automation and recovery `/admin/*` endpoints | `Authorization: Bearer <secret>` or `x-admin-key` header for script-driven operations |
| **Scoped Admin Secrets** | Settlement and broadcast automation endpoints | Optional `ADMIN_SETTLEMENT_SECRET` and `ADMIN_BROADCAST_SECRET`; when configured, the scoped route rejects the broader `ADMIN_SECRET` |
| **Test Mode Guard** | `/test/*` | `APP_MODE === 'test'` environment check |

### Data Storage (Cloudflare KV)

| Key Pattern | Namespace | Data | Sensitivity |
|-------------|-----------|------|-------------|
| `pledge:{orderId}` | PLEDGES | Email, amount, Stripe IDs, status | **High** - PII + payment data |
| `email:{email}` | PLEDGES | Array of order IDs | **Medium** - links email to pledges |
| `stats:{slug}` | PLEDGES | Aggregate totals | **Low** - public |
| `tier-inventory:{slug}` | PLEDGES | Tier claim counts | **Low** - public |
| `stripe-event:{id}` | PLEDGES | "processed" flag | **Low** - idempotency |
| `campaign-pledges:{slug}` | PLEDGES | Array of order IDs per campaign | **Low** - index |
| `campaign-charged:{slug}` | PLEDGES | Settlement completion timestamp | **Low** - flag |
| `settlement-job:{slug}` | PLEDGES | Settlement batch progress | **Low** - ephemeral |
| `pending-extras:{orderId}` | PLEDGES | Temporary support item / custom amount checkout extras | **Low** - ephemeral |
| `pending-tiers:{orderId}` | PLEDGES | Temporary overflow tier metadata during checkout | **Low** - ephemeral |
| `cron:lastRun` | PLEDGES | Last persisted hourly cron execution timestamp | **Low** - monitoring |
| `admin-login:{hash}` | PLEDGES | One-time admin login nonce and email | **Medium** - ephemeral admin auth |
| `admin-session:{hash}` | PLEDGES | Admin email, role, campaign scope, CSRF token, expiry | **High** - admin auth |
| `admin-users:v1` | PLEDGES | Runtime admin users and campaign scopes | **High** - access control |
| `admin-marketing-referrals:{slug}` | PLEDGES | Saved referral code and QR source metadata | **Low** - admin-authored marketing data |
| `admin-marketing-draft:{slug}:{surface}` | PLEDGES | Explicit shared Marketing/Blast draft with short retention | **Medium** - admin-authored campaign email/link content |
| `campaign-preview-reviewers:{slug}` | PLEDGES | Normalized reviewer email allowlist for protected campaign previews, with 24-hour TTL | **Medium** - campaign-scoped email access list |
| `admin-audit:{date}:{action}:{id}` | PLEDGES | Recent admin mutation audit events | **Medium** - admin identity + operational metadata |
| `launch-reminder:{slug}:{emailHash}` | PLEDGES | Upcoming-campaign reminder email and opt-in metadata | **Medium** - campaign-scoped email |
| `launch-reminder-suppressed:{slug}:{emailHash}` | PLEDGES | Reminder suppression marker | **Medium** - campaign-scoped email hash |
| `launch-reminder-sent:{slug}:{emailHash}` | PLEDGES | Reminder send idempotency marker | **Low** - send state |
| `launch-reminder-dispatch:{slug}` | PLEDGES | Bounded reminder dispatch job cursor/progress | **Low** - operational state |
| `launch-reminder-dispatch-queue:v1` | PLEDGES | Reminder dispatch queue idle/pending marker | **Low** - operational state |
| `abandoned-cart:{orderId}` | PLEDGES | Explicitly opted-in checkout reminder email and campaign snapshot | **Medium** - campaign-scoped email |
| `abandoned-cart-resume:{orderId}` | PLEDGES | Short-lived signed-link checkout resume snapshot after a reminder sends | **Medium** - campaign-scoped email and sanitized cart snapshot |
| `abandoned-cart-sent:{emailHash}:{campaignSetHash}` | PLEDGES | Checkout reminder send idempotency marker | **Low** - send state |
| `abandoned-cart-suppressed:{emailHash}` | PLEDGES | Checkout reminder unsubscribe marker | **Medium** - supporter email hash |
| `abandoned-cart-suppressed-campaign:{slug}:{emailHash}` | PLEDGES | Admin-managed campaign-scoped checkout reminder suppression marker | **Medium** - supporter email hash |
| `abandoned-cart-queue:v1` | PLEDGES | Checkout reminder queue idle/pending marker | **Low** - operational state |
| `abandoned-cart-health:v1` | PLEDGES | Aggregate checkout reminder queue/outcome health counters | **Low** - operational aggregate |
| `supporter-email-retry:{orderId}` | PLEDGES | Queued supporter confirmation email retry payload | **Medium** - supporter email payload |
| `supporter-email-retry-queue:v1` | PLEDGES | Supporter email retry idle/pending and next-attempt marker | **Low** - operational state |
| `add-on-inventory-sold:v1` | PLEDGES | Platform add-on sold-count projection | **Low** - aggregate inventory state |
| `vote:{slug}:{decision}:{email}` | VOTES | Vote choice | **Medium** - links supporter to vote |
| `results:{slug}:{decision}` | VOTES | Vote tallies | **Low** - semi-public |
| `rl:{endpoint}:{ip}` | RATELIMIT | Request count + reset time | **Low** - ephemeral |

Scarce limited-tier reservation and committed-count truth is no longer stored in KV. That race-sensitive state now lives in the per-campaign Durable Object coordinator, while KV keeps only the public `tier-inventory:{slug}` projection.

Settlement serialization is also Durable Object-backed. The `SETTLEMENT_COORDINATOR` binding owns a short-lived lock per campaign slug so scheduled settlement, direct settlement, dispatch, and batch endpoints cannot charge the same campaign concurrently. Multi-campaign carts still work because checkout persistence creates separate campaign-scoped pledge records, and settlement locks are keyed by the campaign being charged.

---

## Security Hardening Overview

The current security posture is designed around a few core principles:

- keep pricing, pledge state, and settlement server-canonical
- scope supporter access as narrowly as possible
- fail closed when secrets or environment checks are missing
- keep browser storage and cacheable responses low-sensitivity by default
- validate authored content and request payloads before they reach sensitive logic
- preserve operational visibility through repeatable security testing and explicit secrets handling

### Access Control And Environment Gating

- magic links are scoped to specific pledge and campaign paths rather than broad user accounts
- private admin access uses email magic links, signed session cookies, CSRF checks, and role/campaign scoping
- admin sign-in can require a Cloudflare Turnstile challenge before login nonce writes or magic-link delivery
- `/test/*` routes are gated behind test mode and are not meant to be reachable in normal deployments
- admin routes require an explicit secret and are intended to fail closed when not configured correctly
- supporter voting is keyed to the supporter email identity associated with the authorized pledge, which prevents simple multi-pledge vote amplification

### Webhook, Admin, And Origin Protections

- Stripe webhook handling is built around signature verification and an explicit configured secret
- admin-secret comparison is timing-safe rather than using a naive direct comparison
- sensitive browser POST flows such as checkout bootstrap, completion, and payment-method updates are origin-checked against the configured site base
- legacy callback surfaces that no longer belong to the live payment flow are intentionally removed rather than left dormant

### Browser And Response Hardening

- order-specific checkout bootstrap and completion responses are served with `Cache-Control: private, no-store`
- long-lived browser persistence is limited to cart structure and pricing inputs, while contact and address drafts stay session-scoped
- short-lived recovery markers are used for checkout continuity instead of leaving sensitive in-flight state in storage indefinitely
- security response headers reduce MIME sniffing, framing risk, and unnecessary referrer leakage

### Input And Content Validation

- checkout-start payloads validate campaign identifiers, email addresses, cart items, and contribution inputs before canonical reconstruction
- voting endpoints validate decision identifiers and option values before they reach state-changing logic
- dashboard settings, campaign fields, content blocks, add-ons, tiers, support items, diary entries, decisions, and user records are normalized server-side before persistence
- dashboard media uploads are scoped by role, campaign access, upload kind, content type, file size, destination directory, and canonical filename
- creator-authored labels and rich content are escaped or sanitized by default, with only a very small allowlisted HTML subset preserved
- structured embeds are allowlisted to exact approved providers and URL shapes instead of broad substring checks
- markdown link destinations are constrained to safe schemes and internal links

### Inventory And Data Integrity

- scarce limited-tier inventory is coordinated through a per-campaign Durable Object rather than trusting client-visible KV state for race-sensitive truth
- public inventory remains a projection for efficient reads, while reservation and commit truth stays in the coordinator
- checkout completion invalidates cached stats and inventory so restored pages do not keep showing stale pre-pledge totals
- settlement and reporting depend on server-owned pledge records rather than browser-submitted totals

### Abuse Controls And Operational Safeguards

- rate limiting is available for expensive routes such as checkout, pledge management, admin operations, and webhooks
- blocked requests are designed to fail closed without turning abuse into excessive extra KV writes
- normal dashboard reads, filters, previews, analytics, report downloads, and local editor drafts are designed to avoid KV writes
- secret values remain in Worker secrets or ignored local files; the dashboard can report configured/missing status but cannot edit or serialize secret values
- the secret-audit and security test suites are part of the documented verification path
- the security model assumes operators will keep deployment secrets rotated, scoped, and out of repository history

## Accepted Boundaries

Some tradeoffs remain intentional in the current model:

- magic links are long-lived because accountless pledge management has to remain usable across campaign timelines
- tokens still arrive through emailed URLs, so the platform relies on scoped access, response headers, and limited browser persistence rather than a full token-exchange flow

If a deployment needs a stricter posture than that default, the most likely next steps would be shorter token lifetimes, easier token reissue flows, and a one-time token exchange that removes raw tokens from visible URLs after entry.

---


## Secrets Checklist

Before deploying to production, verify these secrets are set:

| Secret | Environment Variable | Min Length |
|--------|---------------------|------------|
| Stripe API Key | `STRIPE_SECRET_KEY_LIVE` | N/A |
| Stripe Webhook Secret | `STRIPE_WEBHOOK_SECRET_LIVE` | 32+ chars |
| Checkout Intent Secret | `CHECKOUT_INTENT_SECRET` | 32+ chars |
| Magic Link Secret | `MAGIC_LINK_SECRET` | 32+ chars |
| Launch Reminder Token Secret | `LAUNCH_REMINDER_TOKEN_SECRET` or `MAGIC_LINK_SECRET` fallback | 32+ chars |
| Abandoned Checkout Token Secret | `ABANDONED_CART_TOKEN_SECRET` or `MAGIC_LINK_SECRET` fallback for reminder unsubscribe/resume links | 32+ chars |
| Admin Session Secret | `ADMIN_SESSION_SECRET` | 32+ chars |
| Admin Secret | `ADMIN_SECRET` | 32+ chars |
| Settlement Admin Secret | `ADMIN_SETTLEMENT_SECRET` (optional, scoped) | 32+ chars |
| Broadcast Admin Secret | `ADMIN_BROADCAST_SECRET` (optional, scoped) | 32+ chars |
| Turnstile Secret | `TURNSTILE_SECRET_KEY`, `ADMIN_TURNSTILE_SECRET_KEY`, or `LAUNCH_REMINDER_TURNSTILE_SECRET_KEY` | N/A |
| Resend API Key | `RESEND_API_KEY` | N/A |
| Cloudflare Usage Analytics Token | `CLOUDFLARE_USAGE_API_TOKEN` or `CLOUDFLARE_ANALYTICS_API_TOKEN` | GraphQL Analytics Read; optional Billing Read for plan detection |

When GitHub Actions or an operator script calls protected admin endpoints, add only the needed matching secret to GitHub repository secrets. The default deploy workflow uses `ADMIN_BROADCAST_SECRET` for the post-deploy diary check when it is configured; future settlement automation should use `ADMIN_SETTLEMENT_SECRET` rather than the broader fallback secret.

Generate secure secrets:
```bash
openssl rand -base64 32
```

---

## Penetration Testing

See [tests/security/README.md](/docs/operations/security-test-suite/) for the pen test suite.

Run security tests:
```bash
npm run test:secrets            # Audit local secret exposure in files + history
npm run test:security           # Against local Worker
npm run test:security:staging   # Against a staging worker, if you maintain one
```

`npm run test:premerge` now includes the secret audit automatically, so local merge gating checks both security behavior and accidental credential exposure.

For local runs, keep `CHECKOUT_INTENT_SECRET` configured if you want the live-worker checkout-start suite to exercise the real first-party signing path.

---

## Incident Response

### Token Compromise

If a magic link token is compromised:
1. The token is tied to a specific orderId/email/campaign
2. It can only access/modify that one authorized order
3. To invalidate: delete the pledge from KV (`GET /pledge` will then return `404` for that token)
4. Optionally: regenerate MAGIC_LINK_SECRET (invalidates ALL tokens)

### Admin Session Or Secret Compromise

1. Immediately rotate `ADMIN_SESSION_SECRET` and `ADMIN_SECRET` via `wrangler secret put`
2. Clear active `admin-session:*` keys from the Worker KV namespace
3. Review `admin-audit:*` events and GitHub commits for unauthorized admin actions
4. Re-check campaign stats, pledge data, settings, and admin user scopes

### Stripe Webhook Secret Compromise

1. Rotate the webhook secret in Stripe Dashboard → Webhooks
2. Update `STRIPE_WEBHOOK_SECRET_*` in Worker
3. Check for any suspicious pledges created during exposure window

### Missed Stripe Webhook (Development)

If the on-site payment step completes but the pledge doesn't appear yet (common in local dev when webhook forwarding is delayed or broken):

1. Check Stripe CLI output for webhook delivery status
2. The client will first try `/checkout-intent/complete` automatically for local recovery, but if the pledge still does not appear, use the admin recovery endpoint to manually create it:
   ```bash
   curl -X POST http://localhost:8787/admin/recover-checkout \
     -H 'Authorization: Bearer YOUR_ADMIN_SECRET' \
     -H 'Content-Type: application/json' \
     -d '{"sessionId": "cs_test_..."}'
   ```
3. The endpoint fetches the checkout session from Stripe and creates the pledge if it doesn't exist

**Prevention:**
- Use `scripts/dev.sh` which runs the Worker with local KV simulation
- `scripts/dev.sh` starts a single Stripe listener, forwards events to `127.0.0.1:8787/webhooks/stripe`, writes that same listener's `whsec_...` secret into `worker/.dev.vars`, and clears stale local processes on the standard dev ports before startup
- If you start Stripe manually, use the same listener instance for forwarding and for the secret you copy into local config
- `./scripts/dev.sh --podman` is the easiest way to keep the local site/Worker boundary production-like without relying on host Ruby/Wrangler setup
- For testing with seeded data, run `./scripts/seed-all-campaigns.sh` after starting the worker

---

## Security Contacts

- **Stripe Security:** [stripe.com/docs/security](https://stripe.com/docs/security)
- **Cloudflare Status:** [cloudflarestatus.com](https://www.cloudflarestatus.com)

---
