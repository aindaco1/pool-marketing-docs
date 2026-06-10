---
title: "Roadmap"
parent: "Reference"
nav_order: 2
render_with_liquid: false
---

# Roadmap

## Last Updated

June 9, 2026

This roadmap is organized as a release history of the real project states we actually used, rather than a flat completed-features list.

## Current Milestone

**v1.0.3**

The v1.0 feature set and release-hardening pass are complete. v1.0.3 adds configurable platform timezone handling, opt-in launch reminders for upcoming campaigns, mobile campaign-page performance refinements, scoped admin automation secrets, campaign-scoped settlement locking, safer dashboard media lifecycle handling, and lower steady-state KV write/list usage.

## Release History

### v0.5 — WME Launch

This was the first version used to launch WME and prove the core platform model in the wild.

New in this version:

- Jekyll + GitHub Pages public campaign site with a working campaign presentation system
- Cloudflare Worker backend for pledge storage, live stats, emails, and campaign lifecycle automation
- all-or-nothing campaign logic with deferred charging instead of immediate capture
- no-account supporter management through magic-link pledge access
- campaign funding with tiers, support items, custom amounts, and basic post-pledge reporting
- production-diary and supporter-update foundations for creator communication
- Pages CMS integration so campaign content could be edited without a pure Git workflow

### v0.6 — Pre-Tecolote State

This was the state of the project right before Tecolote launched. The emphasis here was making the system more reliable for a second real campaign with heavier content and more edge cases.

New in this version:

- multi-campaign readiness instead of a one-campaign proof of concept
- stronger deadline handling, timezone fixes, and campaign-state transitions
- deployment rebuild and cache-purge improvements around campaign status changes
- milestone-email reliability fixes and settlement bug fixes from the WME experience
- improved pledge-management behavior once campaigns moved past their live window
- better support for richer campaign assets, updated public copy, and launch-polish work needed for Tecolote

### v0.7 — Platform Tip Slider

This version introduced the optional platform-tip system and made it a first-class part of the supporter experience.

New in this version:

- optional platform tips from `0%` to `15%`, with `5%` as the default
- tip slider and tip-aware totals in cart, checkout, and Manage Pledge
- instant summary updates so supporters could see subtotal, tip, and total changes immediately
- tip-aware supporter emails and pledge-flow documentation
- improved manage-page layout and responsiveness around tip editing and tier swaps
- stronger local checkout stability and broader automated coverage for tip-aware pledge flows

### v0.8 — Security Hardening

This version was the hardening pass that moved the project from “working” to “defensible.”

New in this version:

- stricter checkout and token verification around first-party pledge flows
- webhook, admin, and business-logic hardening across the Worker
- stronger merge-readiness checks and local smoke workflows for sensitive pledge paths
- improved local testing and developer tooling so hardening work could be validated repeatably
- deployment automation for the Worker on `main`
- a clearer move away from legacy hosted-cart assumptions and toward the newer first-party checkout model

### v0.9 — Local `0.9` Milestone

This was the large local milestone marked by the repo’s `Version 0.9 complete` commit. It represented the first version that felt like a broadly reusable platform rather than a campaign-specific implementation.

New in this version:

- native first-party Stripe payment flow inside the site, plus the same secure pattern for `Update Card`
- Podman-backed local development and testing
- limited-inventory oversell protection with a per-campaign coordinator
- accessibility hardening across dialogs, tabs, sliders, live regions, and key public/supporter flows
- shared design-system redesign, mobile-responsiveness pass, and broader style-system cleanup
- variable-first customization for forks through structured config and Worker mirroring
- English/Spanish i18n completion for public pages, key supporter flows, and shared runtime copy
- SEO fundamentals including canonical metadata, structured data, sitemap/robots handling, and share-card improvements
- shipping-calculator work with USPS quoting, fallback behavior, and delivery-option handling
- platform add-ons, campaign add-ons, projection drift checks, and broader reporting/operations maturity

### v0.9.1 — Embedded Campaign Sharing

This point release was the first major follow-up after the larger `0.9` milestone. The emphasis here was making campaign sharing, embeds, and post-checkout polish feel like part of the product rather than sidecar experiments.

New in this version:

- improved checkout confirmation behavior and supporter email delivery
- hosted live campaign embed widget and richer embed-builder flow
- richer campaign share-card previews aligned with the embed design language
- embed close-link and return-path polish for campaign widgets
- docs cleanup and release-polish work following the larger `0.9` milestone
- countdown behavior cleanup so expired campaign countdowns stop showing after deadlines

### v0.9.2 — Commerce And Fulfillment Maturity

This version turned the platform from “campaign tiers plus basic shipping” into a more complete commerce and fulfillment system.

New in this version:

- platform-wide add-on products with inventory awareness, low-stock handling, variant support, and full cart / Manage Pledge integration
- campaign-specific add-ons that reuse the same UI patterns while still counting toward the owning campaign’s subtotal and funding logic
- shipping-calculator work that replaced the old flat physical-fee model with Worker-canonical USPS-backed quoting, fallback behavior, free-shipping overrides, and limited delivery-option upgrades
- reporting changes that kept campaign pledge revenue, platform add-on revenue, and fulfiller ownership more operationally distinct
- follow-up shipping work around real USPS credentialed smoke coverage, estimate-mode UX, shared shipping-country data, and safer handling for flat-mail/manual-rate cases

### v0.9.3 — Operator Hardening And Reporting

This release focused on making the platform easier to operate safely once the commerce surface got more complex.

New in this version:

- read-only projection-drift diagnostics plus local operator tooling so stats, inventory, and campaign indexes could be checked before repair work mutated anything
- denial-of-service hardening with required `RATELIMIT` KV, tighter write-path rate limits, earlier oversized-payload rejection, and safer retry budgeting around `checkout-intent/abandon`
- a conservative `cpu_ms` ceiling plus lightweight observability summaries and local observability checks for tuning Worker cost and behavior
- campaign-runner reporting with `runner_report_emails`, bounded `reports.campaign_runner` config, daily live-campaign ledger emails, and split post-deadline fulfillment flows for campaign versus platform fulfillers
- a shared report core so scheduled runner emails and local CLI exports stop drifting from each other

### v0.9.4 — Tax-Aware Checkout

This release made tax-aware checkout a first-class part of the platform and rounded out the fork-polish work needed to make the project feel more production-shaped.

New in this version:

- provider-driven tax calculation through `flat`, `offline_rules`, `nm_grt`, and `zip_tax` modes instead of only one flat-rate assumption
- provisional tax UX in cart and checkout so the browser can show `--` until the Worker has enough billing or shipping destination detail to return a real answer
- final-tax destination plumbing across cart, custom checkout, Manage Pledge, stored pledge data, and supporter emails so tax math stays consistent everywhere
- a free-first New Mexico path through a vendored starter dataset plus optional EDAC refinement, alongside better local smoke coverage for provider-driven tax setups
- shared fork-branding polish so the same config surface now themes on-site Stripe Elements, supporter emails, and more of the localized metadata layer
- localized follow-up work such as cart-button summaries, checkout tax-location helper copy, and locale-aware public metadata / JSON-LD so the tax-aware flows still read cleanly in English and Spanish

### v0.9.5 — Local Runtime Parity And Creator Launch Handoff

This release kept local Worker development aligned with production deployment behavior while tightening the public handoff material creators need before launch.

New in this version:

- Podman Worker development now runs on Node 24 to match GitHub Actions deployments
- host and Podman helper scripts now prefer Node 24 and no longer force the obsolete Node 20 Wrangler path
- Wrangler 4 local development runs against Worker compatibility date `2026-05-03`, avoiding the older local-runtime polyfill crash under Node 24
- Podman Worker dependency setup now uses `npm ci` so local container starts do not mutate `worker/package-lock.json`
- the public Campaign Creator Checklist now covers campaign add-ons, embed-code promotion, shipping fallback/free-shipping decisions, tax expectations, report recipients, and fulfillment handoff
- a Spanish creator checklist route now exists at `/es/creator-campaign-checklist/`

### v1.0.0 — Public Launch Platform

This release moved The Pool from reusable campaign infrastructure to a production-shaped platform with a private browser operations surface.

New in this version:

- private admin dashboard at `/admin/` and `/es/admin/` for role-scoped platform settings, campaign editing, add-ons, reports, analytics, supporters, marketing tools, and users
- email magic-link admin authentication with signed sessions, CSRF/origin protections, optional Turnstile challenge support, and safe browser APIs that do not expose `ADMIN_SECRET`
- dashboard editing for campaign settings, content blocks, tiers, support items, campaign add-ons, stretch goals, ongoing items, diary entries, decisions, platform add-ons, and platform settings
- dashboard Users management backed by Worker KV at `admin-users:v1`, including notification emails for newly created users when Resend is configured
- dashboard Marketing tools for referral and UTM URL building, saved referral codes, reusable embed-builder controls, and copyable launch snippets
- role-scoped Analytics, Reports, and Supporters views with sortable/filterable tables, exact-cent dollar display, CSV downloads, and read-only report previews
- dashboard accessibility, i18n, SEO/noindex, security, mobile/tablet responsiveness, and DRY UI passes
- final release verification across admin browser flows, pre-merge regression checks, and local Podman smoke for the dashboard's main tabs

### v1.0.1 — Dashboard Media And Analytics Patch

This point release tightened the new dashboard workflow after v1.0.0 and added the analytics data needed for more accurate revenue reporting.

New in this version:

- newly charged pledges capture actual Stripe balance transaction fee, net, gross, charge, and balance transaction IDs when available
- dashboard Analytics prefers stored actual Stripe fees when available and labels mixed or estimated values clearly
- super admins can backfill older charged pledge records with Stripe balance transaction data without KV list scans
- campaign and diary content editors can stage image, video, and audio uploads with immediate previews and publish them into the correct campaign asset directories
- dashboard uploads stay source-preserving in the Worker, while repository tooling handles lossless image compression and WebM derivative generation
- `npm run media:optimize`, `npm run media:optimize:check`, and the "Optimize dashboard media" GitHub Actions workflow support the post-upload media pipeline
- Supporters and Analytics return empty read-only views for campaigns without pledge indexes instead of blocking new or empty campaign dashboards

### v1.0.2 — Performance, Sharing, And Admin Polish

This point release made public pages lighter and more predictable while adding safer sharing controls and a small admin performance surface for fork operators.

New in this version:

- campaign progress bars and milestone markers render static width and position classes so first load no longer waits for JavaScript to avoid collapsed marker layouts
- public pages load a lightweight cart-runtime loader first and defer the full cart stack until persisted cart state, recovery state, or clear supporter intent requires it
- same-origin public document prefetching follows a small local intent model with route allowlists, sensitive-query exclusions, network guards, low per-page limits, and a default-enabled config surface
- Settings -> Advanced performance exposes intent-prefetch enablement, delay, and page-view limit for super admins, with Worker config mirroring through `INTENT_PREFETCH_*`
- production Pages builds minify generated `_site` CSS and JavaScript after Jekyll output, while Cloudflare remains responsible for transfer compression
- campaign pages render reusable icon-only share links for Bluesky, X, Threads, Facebook, SMS, and email with localized URLs and state-aware CTA text where supported
- responsive share controls appear below the short blurb on mobile/tablet and above the embed button only on desktop
- admin email sign-in keeps the existing Turnstile challenge after a login attempt and uses the shared dashboard status-message styling for more prominent auth feedback
- the public Campaign Creator Checklist and Spanish checklist describe creator-facing changes from v0.9.5 through v1.0.2, including share-link planning and dashboard media uploads

### v1.0.3 — Platform Timezone, Launch Reminders, And Media Workflow Hardening

This point release made campaign lifecycle timing configurable for forks, added launch-reminder collection for upcoming campaigns, and tightened media/performance operations for public campaign pages.

New in this version:

- super admins can set the default platform timezone from supported IANA timezone options, with Jekyll campaign state, browser countdowns, Worker deadline checks, campaign-runner reports, settlement checks, and admin date/time surfaces sharing the same `platform.timezone` / `PLATFORM_TIMEZONE` model
- upcoming campaign pages can collect one-time launch reminder signups through a slim localized form with Turnstile, rate limiting, campaign/email dedupe, signed unsubscribe links, and bounded dispatch jobs
- launch reminder delivery reuses the existing Resend email module, sender configuration, locale catalog, and pacing instead of adding a second email integration
- the minute-level Worker scheduler now persists `cron:lastRun` hourly instead of every minute, keeping cron health visible without consuming the free-tier KV write budget as baseline churn
- `_config.local.yml` can blank the reminder Turnstile site key so local development hides the widget consistently with local admin sign-in
- the Podman media optimizer now includes `optipng` and `gifsicle` for local PNG/GIF source compression through the same repository media workflow
- responsive image generation now includes a `640w` WebP rung between the existing `480w` and `960w` variants for mobile campaign pages
- YouTube campaign hero videos render local poster/play facades and defer the remote iframe until supporter play intent
- the public creator checklists now describe the creator-facing v1.0.3 changes, including launch reminders, platform timezone expectations, deferred YouTube hero embeds, and responsive WebP variants
- optional `ADMIN_SETTLEMENT_SECRET` and `ADMIN_BROADCAST_SECRET` can narrow settlement and broadcast automation access; scoped routes reject the broader `ADMIN_SECRET` when the narrower secret is configured
- scheduled, direct, dispatch, and batch settlement paths now share a campaign-scoped `SETTLEMENT_COORDINATOR` Durable Object lock and deterministic Stripe idempotency keys so same-campaign charging cannot overlap
- multi-campaign checkouts remain supported by fanning checkout bundles into separate campaign-scoped pledge records; settlement locks and batches stay scoped to the campaign being charged
- GitHub Actions and operator docs now distinguish Worker runtime secrets from repository secrets, including when matching scoped admin secrets must exist in both places
- Cloudflare deploy and report-export docs now require `CLOUDFLARE_ACCOUNT_ID`, recommend user-scoped deploy tokens, and document narrower cache-purge and read-only KV token options
- `worker/.dev.vars` guidance now explicitly calls for local-only values rather than production-secret backups
- dashboard image/video uploads request the repository media optimizer with `scope=changed`, while publish-time cleanup removes same-campaign dashboard-owned media that disappeared from authored content and is not referenced elsewhere
- launch reminder dispatch, supporter email retry, and platform add-on inventory paths now use queue-state or sold-count projections to avoid unnecessary KV list scans during idle or normal read paths

## Future Features

Work still planned after `1.0.3` includes:

- further tax-calculator work for broader US and international coverage, better local-jurisdiction depth, and clearer tax-data refresh workflows
- net revenue analytics after allocated processor fees, using actual Stripe fee data where available
- richer campaign marketing tools such as announcement composition and consent-aware abandoned-cart follow-up
- different prices per add-on variation
- email-protected campaign preview pages for super admins, campaign users, and invited reviewers

## Known Issues

**Credit Card Autofill**: credit-card number, expiry, and CVC fields live inside Stripe-controlled secure UI, so browser autofill support there is constrained by Stripe rather than the surrounding app.
