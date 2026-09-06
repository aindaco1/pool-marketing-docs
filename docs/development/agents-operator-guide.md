---
title: "Agents & Operator Guide"
parent: "Development"
nav_order: 10
render_with_liquid: false
---

# AGENTS

## Last Updated

September 6, 2026

This is the operating guide for people and coding agents working on **The Pool**. Use it to make safe changes without drifting the static site, Cloudflare Worker, checkout math, private administration, or localized behavior out of sync.

Read it alongside:

- [docs/README.md](/docs/development/) for the documentation index and guide ownership
- [README.md](/docs/development/platform-readme/) for the product and architecture overview
- [docs/ARCHITECTURE.md](/docs/development/architecture/) for system ownership, storage, and lifecycle
- [docs/CONTENT_MODEL.md](/docs/development/content-model/) for campaign authoring fields
- [docs/WORKER_API.md](/docs/reference/worker-api/) for endpoint contracts
- [docs/DEPLOYMENT.md](/docs/operations/deployment/) for production setup and release wiring
- [docs/CUSTOMIZATION.md](/docs/development/customization-guide/) for the supported fork-facing configuration surface
- [docs/PAYMENT_PROCESSOR.md](/docs/operations/payment-processor/) for Stripe, canonical checkout, webhooks, settlement, and reconciliation
- [docs/TAX_CALCULATOR.md](/docs/operations/tax-calculator/) for tax providers, canonical quotes, mirrored configuration, and verification
- [docs/ADD_ON_PRODUCTS.md](/docs/development/add-on-products/) for platform, campaign, and variant-specific add-on pricing
- [docs/DASHBOARD.md](/docs/operations/admin-dashboard/) for private administration and editing
- [docs/PERFORMANCE.md](/docs/operations/performance/) for budgets, Lighthouse, caching, and runtime observability
- [docs/SECURITY.md](/docs/operations/security/) for security boundaries and release checks
- [docs/BACKUP_RESTORE.md](/docs/operations/backup-restore/) for backup, restore, and disaster recovery
- [docs/TESTING.md](/docs/operations/testing/) for local verification and merge gates
- [docs/ROADMAP.md](/docs/reference/roadmap/) for prospective work only
- [CHANGELOG.md](/docs/reference/changelog/) and [docs/release-evidence/](https://github.com/aindaco1/pool/tree/main/docs/release-evidence) for completed release history and verification records

## Project shape

The Pool is a split system:

- Jekyll, Sass, and browser JavaScript build the static site published through GitHub Pages.
- The Cloudflare Worker in `worker/` owns APIs, canonical checkout validation, pledge persistence, emails, live statistics, settlement, share cards, and privileged administration.
- Stripe collects payments and stores payment methods.
- Campaign configuration lives primarily in `_campaigns/`; platform settings and products live in `_config.yml`.
- The private dashboard is the supported browser surface for settings, add-ons, campaigns, reports, analytics, supporters, marketing links, diagnostics, and users.

If a change affects pricing, availability, campaign progress, pledge state, email content, or live campaign status, assume both the site and Worker are involved even when the symptom appears on only one side.

## Sources of truth

- [`_config.yml`](https://github.com/aindaco1/pool/blob/main/_config.yml): canonical fork-facing platform configuration
- [`_config.local.yml`](https://github.com/aindaco1/pool/blob/main/_config.local.yml): machine-local overrides only
- [`_campaigns/`](https://github.com/aindaco1/pool/tree/main/_campaigns): campaign content, tiers, goals, diary data, and campaign add-ons
- [`_data/i18n/`](https://github.com/aindaco1/pool/tree/main/_data/i18n): shared localized UI, runtime, and email copy
- [`_data/media-optimization-manifest.json`](https://github.com/aindaco1/pool/blob/main/_data/media-optimization-manifest.json): rebuildable repository media metadata; source files remain authoritative
- [`_layouts/`](https://github.com/aindaco1/pool/tree/main/_layouts) and [`_includes/`](https://github.com/aindaco1/pool/tree/main/_includes): public pages, campaign pages, embeds, SEO, and locale helpers
- [`assets/`](https://github.com/aindaco1/pool/tree/main/assets): browser runtime, Sass, themes, and generated localized assets
- [`worker/src/`](https://github.com/aindaco1/pool/tree/main/worker/src): authoritative checkout, webhooks, statistics, emails, settlement, administration, and reports
- [`worker/wrangler.toml`](https://github.com/aindaco1/pool/blob/main/worker/wrangler.toml): Worker environment wiring and mirrored defaults
- [`config/performance-budgets.json`](https://github.com/aindaco1/pool/blob/main/config/performance-budgets.json): executable public and runtime performance thresholds
- [`config/pool-data-inventory.json`](https://github.com/aindaco1/pool/blob/main/config/pool-data-inventory.json): data classification, retention, and recovery inventory
- [`tests/`](https://github.com/aindaco1/pool/tree/main/tests): unit, security, accessibility, and end-to-end contracts
- [`scripts/`](https://github.com/aindaco1/pool/tree/main/scripts): local development, release gates, smoke tests, audits, and synchronization
- [`docs/release-evidence/`](https://github.com/aindaco1/pool/tree/main/docs/release-evidence): release-specific verification records

## Safe workflow

Inspect `git status` before editing. Existing changes belong to the user unless the task explicitly includes them; do not overwrite, discard, or silently include them in a commit.

For normal local development:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Use the narrowest focused test that proves a change, then run the complete pre-merge gate for a substantial or release-facing change:

```bash
npm run test:premerge
```

Useful focused checks include:

- `bundle exec jekyll build --quiet`
- `npx vitest run <targeted test files>`
- `node --check <changed JavaScript file>`
- `npx playwright test tests/e2e/admin-dashboard.spec.ts --project=chromium`
- `npm run test:performance:budgets`
- `npm run test:performance:lighthouse`
- `npm run test:performance:runtime -- --input=<redacted-observability.json>`
- `npm run test:cache-policy`
- `npm run production:posture -- --no-dev-vars`
- `npm run release:smoke -- --evidence-file <path>`

Production posture, cache, and release-smoke results are only complete when their required provider credentials and secrets were available. Record omissions explicitly in release evidence.

## Common change paths

### Campaigns

Use the dashboard **Campaigns** tab for normal edits. The underlying sources are `_campaigns/<slug>.md` and `assets/images/campaigns/<slug>/`.

Verify funding and stretch-goal math, tier inventory, physical-reward shipping, localized routing, embeds, and share previews.

### Branding, settings, and products

Use dashboard **Settings** and **Add-ons** for normal edits. Published settings and platform add-ons ultimately write back to `_config.yml` through the Worker-controlled GitHub path. Admin users and saved marketing referral codes are runtime exceptions stored in Worker KV.

When mirrored settings change, restart the local stack or run:

```bash
npm run sync:worker-config
```

Product-level add-on price is the default. A variant may inherit it or publish its own override between `$0` and the canonical `$1,000,000` ceiling. Keep dashboard normalization, public cart display, Worker validation, and documentation aligned.

### Checkout and pledge management

Start with browser code in `assets/js/`, templates in `_includes/` and `_layouts/`, Worker code in `worker/src/`, and [docs/PAYMENT_PROCESSOR.md](/docs/operations/payment-processor/).

Keep subtotal, variant price overrides, tips, tax, shipping, campaign contribution, persisted pledge data, emails, and reports aligned. The browser proposes state; the Worker resolves products and prices and decides canonical totals.

### Email and supporter communication

Check Worker mail logic, `_data/i18n/`, sender configuration, and [docs/EMAIL.md](/docs/operations/email-system/). Preserve domain alignment, `reply_to`, plain-text output, hosted media URLs, durable outbox/idempotency behavior, campaign/global suppression, and the boundary between transactional and promotional content. Admin login and explicit test sends remain immediate.

### Media

The repository asset tree is authoritative. Rebuild `_data/media-optimization-manifest.json` with `npm run media:manifest`; do not create a KV-backed media catalog. Use the existing GitHub optimizer dispatch for changed/all repair, preserve source files and intentionally skipped larger derivatives, require alt text for meaningful images, and use explicit decorative-image state for empty alt text.

### Embeds, SEO, and share cards

Check `embed/`, `_layouts/campaign-embed.html`, `assets/js/campaign-embed.js`, `assets/partials/_embed.scss`, Worker share-card code, `_includes/seo-meta.html`, and the embed/SEO docs. Keep campaign-page, embed, and preview state conceptually aligned.

### Localization

Shared system strings belong in `_data/i18n/<lang>.yml`; creator-authored campaign content normally remains campaign content. New public routes and flows must account for locale helpers, localized campaign generation, and the footer language switcher.

## Invariants to protect

1. **`_config.yml` is canonical.** Do not create a second product source of truth in local config or browser state.
2. **Worker-mirrored settings stay synchronized.** Pricing, URLs, sender identity, and other mirrored values must match the site.
3. **Checkout totals are server-verified.** New or changed product/variant selections use current catalog pricing; an unchanged saved product/variant may preserve its historical `unitPrice`. Catalog and persisted cent amounts must remain within the Worker amount limit.
4. **Campaign progress has a precise boundary.** Tiers, direct campaign support, custom campaign amounts, and campaign add-ons count. Platform add-ons, platform tip, tax, and shipping do not.
5. **Localized routes are a public contract.** Preserve locale routing and token/query behavior.
6. **Private flows stay private.** Management, pledge result, protected preview, authenticated admin, and performance-observability responses must remain non-indexable and use private/no-store cache controls where applicable. Preview allowlists belong only in short-lived Worker KV.
7. **Ended campaigns do not behave as live.** Countdown, pledge, embed, and preview behavior must use effective campaign state.
8. **Performance thresholds are executable.** A value in configuration is not a gate until a test or audit consumes it. Distinguish measured baseline from the release threshold, use route-specific public budgets, and keep authenticated runtime evidence free of secrets and personal data.
9. **Dependency findings are scoped and resolved deliberately.** Run the production audit and the full audit. Pin or replace vulnerable release tooling when a safe supported version exists; document any accepted dev-only finding.
10. **Ethical review travels with product changes.** Review money, data, messaging, analytics, automation, admin power, visibility, and shareability while the implementation is still easy to change.
11. **Payment recovery must not invent a second charge.** Persist settlement intent before Stripe calls, reuse deterministic idempotency inside the provider window, and stop ambiguous old work for reconciliation. Do not add manual money-moving recovery without distinct maker/checker operators.
12. **Email delivery is separate from pledge truth.** Production notification side effects go through the shared outbox; provider failure must not roll back or mutate canonical pledge state.

## Documentation map

- Start here and guide ownership: [docs/README.md](/docs/development/)
- Architecture and lifecycle: [docs/ARCHITECTURE.md](/docs/development/architecture/)
- Campaign content model: [docs/CONTENT_MODEL.md](/docs/development/content-model/)
- Worker API: [docs/WORKER_API.md](/docs/reference/worker-api/)
- Deployment: [docs/DEPLOYMENT.md](/docs/operations/deployment/)
- Fork configuration: [docs/CUSTOMIZATION.md](/docs/development/customization-guide/)
- Release history: [CHANGELOG.md](/docs/reference/changelog/)
- Prospective work: [docs/ROADMAP.md](/docs/reference/roadmap/)
- Payments and settlement: [docs/PAYMENT_PROCESSOR.md](/docs/operations/payment-processor/)
- Tax calculation: [docs/TAX_CALCULATOR.md](/docs/operations/tax-calculator/)
- Add-on products and variant pricing: [docs/ADD_ON_PRODUCTS.md](/docs/development/add-on-products/)
- Email: [docs/EMAIL.md](/docs/operations/email-system/)
- Testing: [docs/TESTING.md](/docs/operations/testing/)
- Podman: [docs/PODMAN.md](/docs/operations/podman-local-dev/)
- Localization: [docs/I18N.md](/docs/development/internationalization/)
- SEO and previews: [docs/SEO.md](/docs/operations/seo/)
- Campaign embeds: [docs/EMBEDS.md](/docs/development/campaign-embeds/)
- Shipping: [docs/SHIPPING.md](/docs/operations/shipping/)
- Dashboard: [docs/DASHBOARD.md](/docs/operations/admin-dashboard/)
- Performance: [docs/PERFORMANCE.md](/docs/operations/performance/)
- Security: [docs/SECURITY.md](/docs/operations/security/)
- Backup and recovery: [docs/BACKUP_RESTORE.md](/docs/operations/backup-restore/)
- Ethical risk: [docs/ETHICAL_RISK.md](/docs/development/ethical-risk-review/)
- Merge and release checks: [docs/MERGE_SMOKE_CHECKLIST.md](/docs/operations/merge-smoke-checklist/)

## Working style for coding agents

- Read the implementation and nearby tests before proposing structural changes.
- Prefer small, local edits that preserve established patterns and stay DRY.
- Update tests and operator docs whenever behavior or release expectations change.
- Consider public site, Worker, email, localization, accessibility, security, performance, and recovery consequences together.
- Reuse an existing configuration surface or helper before inventing another.
- Never silently drop locale, embed, share-preview, private-cache, or historical-price behavior.
- Preserve unrelated user changes and stage only files in scope.
- Keep current-state docs in present tense and grounded in verified behavior. Put proposals and deferred work only in the roadmap, and put completed release history only in the changelog or release evidence.
- Keep detailed procedures in the guide that owns them; use the documentation index and links instead of copying runbooks into entry-point READMEs. Maintainer docs stay out of the public Jekyll artifact; root Markdown page sources retain their routing and localization contracts.

When uncertain, make the smallest change that keeps the site and Worker aligned, prove it with the narrowest meaningful test, and run the broader gate when warranted.
