---
title: "Agents & Operator Guide"
parent: "Development"
nav_order: 9
render_with_liquid: false
---

# AGENTS

This document is for people and LLMs working on forks of **The Pool**. It is a practical operator guide for making safe changes in this repo without drifting the site, the Worker, checkout math, or localized/public behavior out of sync.

Use this alongside:

- [README.md](/docs/overview/platform/) for the current product and architecture overview
- [docs/CUSTOMIZATION.md](/docs/development/customization-guide/) for the supported fork-facing config surface
- [docs/TESTING.md](/docs/operations/testing/) for local verification and merge-gate expectations
- [docs/I18N.md](/docs/development/internationalization/) for locale routing and translation rules
- [docs/SEO.md](/docs/operations/seo/) for metadata, share cards, and indexing behavior
- [docs/EMBEDS.md](/docs/development/campaign-embeds/) for the hosted campaign embed system

## Project Shape

The Pool is a split system:

- the static site is Jekyll + Sass + browser JavaScript, published from GitHub Pages
- the API/payment/runtime side is a Cloudflare Worker in `worker/`
- Stripe handles payment collection and saved payment methods
- content and campaign configuration mostly live in markdown/front matter under `_campaigns/`

The important boundary is:

- the site renders UI, campaign content, cart flows, localized pages, embeds, and SEO metadata
- the Worker is the canonical source for checkout validation, pledge persistence, live stats, emails, settlement, and share-card SVG generation

If a change affects pricing, campaign totals, availability, pledge state, email content, or live campaign status, assume the Worker is involved even if the first symptom is on the site.

## Source Of Truth

When you need to understand or change behavior, start here:

- [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml): canonical fork-facing configuration
- [`_config.local.yml`](https://github.com/your-org/your-project/blob/main/_config.local.yml): local overrides only
- [`_campaigns/`](https://github.com/your-org/your-project/tree/main/_campaigns): campaign content, tiers, goals, diary data, community hooks, campaign-scoped merch
- [`_data/i18n/`](https://github.com/your-org/your-project/tree/main/_data/i18n): shared UI/runtime/email copy by language
- [`_layouts/`](https://github.com/your-org/your-project/tree/main/_layouts) and [`_includes/`](https://github.com/your-org/your-project/tree/main/_includes): public pages, campaign pages, embeds, SEO, localized routing helpers
- [`assets/`](https://github.com/your-org/your-project/tree/main/assets): JS runtime, shared Sass partials, theme variables, generated i18n payload
- [`worker/src/`](https://github.com/your-org/your-project/tree/main/worker/src): checkout, webhooks, live stats, email sending, share previews, settlement, admin/report logic
- [`worker/wrangler.toml`](https://github.com/your-org/your-project/blob/main/worker/wrangler.toml): Worker env wiring mirrored from site config plus local/dev defaults
- [`tests/`](https://github.com/your-org/your-project/tree/main/tests): unit, security, and E2E expectations
- [`scripts/`](https://github.com/your-org/your-project/tree/main/scripts): local dev, merge gate, smoke tests, reports, and sync helpers

## Safe Workflow

For normal development, prefer:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

That path keeps the site and Worker running together with the repo's expected defaults.

For final verification, use the narrowest command that proves the change, then run the broader gate before merge when the change is substantial:

```bash
./scripts/pre-merge-regression.sh
```

Useful focused checks:

- `bundle exec jekyll build --quiet`
- `npx vitest run <targeted test files>`
- `node --check <js file>`
- `./scripts/test-worker.sh --podman`
- `./scripts/test-e2e.sh --podman`

## Common Tasks

### Add or edit a campaign

Start with:

- [`_campaigns/<slug>.md`](https://github.com/your-org/your-project/tree/main/_campaigns)
- campaign assets under [`assets/images/campaigns/<slug>/`](https://github.com/your-org/your-project/tree/main/assets/images/campaigns)
- supporting docs in [docs/CMS.md](/docs/reference/cms-integration/)

Check:

- funding goal and stretch-goal math
- tier inventory and limited quantities
- shipping settings for physical rewards
- localized/public routing if the campaign page should work cleanly under `/es/`
- embed/share-preview behavior if hero image, blurb, title, or live status changed

### Change branding or product settings

Start with:

- [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)
- [docs/CUSTOMIZATION.md](/docs/development/customization-guide/)

Do not put canonical fork settings in `_config.local.yml`. Keep that file for machine-local overrides like localhost URLs and local-only flags.

If you change values that are mirrored into the Worker, restart the local stack or run:

```bash
npm run sync:worker-config
```

### Change checkout, totals, or pledge-management behavior

Start with:

- site runtime in [`assets/js/`](https://github.com/your-org/your-project/tree/main/assets/js)
- campaign/cart/manage templates in [`_includes/`](https://github.com/your-org/your-project/tree/main/_includes) and [`_layouts/`](https://github.com/your-org/your-project/tree/main/_layouts)
- Worker checkout logic in [`worker/src/`](https://github.com/your-org/your-project/tree/main/worker/src)

Always assume there is a site-side piece and a Worker-side piece.

Things that must stay aligned:

- subtotal math
- tip math
- sales tax
- shipping
- add-ons
- campaign-goal contribution rules
- pledge/email/report totals

If only one side changes, you probably have a bug.

### Change emails or supporter communication

Start with:

- Worker mail logic in [`worker/src/`](https://github.com/your-org/your-project/tree/main/worker/src)
- translation copy in [`_data/i18n/`](https://github.com/your-org/your-project/tree/main/_data/i18n)
- contact/sender identity in [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml)

If you touch deliverability-sensitive behavior, also sanity-check:

- `from` domain alignment
- `reply_to`
- plain-text body generation
- transactional vs promotional content mixing

### Change embeds or rich previews

Start with:

- embed routes and layout in [`embed/`](https://github.com/your-org/your-project/tree/main/embed) and [`_layouts/campaign-embed.html`](https://github.com/your-org/your-project/blob/main/_layouts/campaign-embed.html)
- embed client/runtime in [`assets/js/campaign-embed.js`](https://github.com/your-org/your-project/blob/main/assets/js/campaign-embed.js)
- embed styles in [`assets/partials/_embed.scss`](https://github.com/your-org/your-project/blob/main/assets/partials/_embed.scss)
- Worker share cards in [`worker/src/`](https://github.com/your-org/your-project/tree/main/worker/src)
- SEO metadata in [`_includes/seo-meta.html`](https://github.com/your-org/your-project/blob/main/_includes/seo-meta.html)
- guidance in [docs/EMBEDS.md](/docs/development/campaign-embeds/) and [docs/SEO.md](/docs/operations/seo/)

Keep embed state, share-preview state, and campaign-page metadata conceptually aligned even when the rendered surfaces differ.

### Add or extend a language

Start with:

- [`_config.yml`](https://github.com/your-org/your-project/blob/main/_config.yml) `i18n` block
- [`_data/i18n/<lang>.yml`](https://github.com/your-org/your-project/tree/main/_data/i18n)
- localized long-form pages like [`es/about.md`](/docs/overview/about-the-pool/) and [`es/terms.md`](/docs/overview/terms-and-guidelines/)
- locale helpers in [`_includes/localized-url.html`](https://github.com/your-org/your-project/blob/main/_includes/localized-url.html)
- generated localized campaign pages in [`_plugins/localized_campaign_pages.rb`](https://github.com/your-org/your-project/blob/main/_plugins/localized_campaign_pages.rb)

Shared system strings belong in `_data/i18n/{lang}.yml`.
Campaign content authored by creators should usually remain campaign content, not be moved into translation YAML.

## Invariants To Protect

These are the easiest places for forks or LLMs to accidentally cause drift.

### 1. `_config.yml` is canonical

Do not treat `_config.local.yml` as a second source of truth.

### 2. Worker-mirrored settings must stay in sync

If you change pricing, site URLs, sender identity, or other mirrored settings, make sure the Worker sees the same values.

### 3. Checkout totals are server-verified

The browser can suggest a cart state. The Worker decides the canonical totals and persisted pledge shape.

### 4. Campaign progress excludes some checkout dollars

Shipping, tax, and platform tip do not all count toward campaign funding totals. Be careful when changing display language or reports so you do not imply otherwise.

### 5. Localized routes are part of the public contract

If you add a new public page, embed route, or campaign-specific flow, check whether the locale helpers and footer language switcher need to know about it.

### 6. Tokenized/private flows should not become indexable

`/manage/`, pledge result pages, and token-bearing/private routes must stay out of search indexing and should preserve token/query behavior when switching languages.

### 7. Ended campaigns should not behave like live ones

Countdowns, pledge controls, and embed/share-preview state should respect the effective campaign state, especially after deadlines.

## Best Docs For Specific Work

- Fork config and branding: [docs/CUSTOMIZATION.md](/docs/development/customization-guide/)
- Local dev and merge verification: [docs/TESTING.md](/docs/operations/testing/)
- Podman setup and limits: [docs/PODMAN.md](/docs/operations/podman-local-dev/)
- Localization model: [docs/I18N.md](/docs/development/internationalization/)
- SEO and share metadata: [docs/SEO.md](/docs/operations/seo/)
- Campaign embeds: [docs/EMBEDS.md](/docs/development/campaign-embeds/)
- Shipping and USPS behavior: [docs/SHIPPING.md](/docs/operations/shipping/)
- Add-on product model: [docs/ADD_ON_PRODUCTS.md](/docs/development/add-on-products/)
- CMS/editor flow: [docs/CMS.md](/docs/reference/cms-integration/)
- Security posture and guardrails: [docs/SECURITY.md](/docs/operations/security/)
- Release/merge checklist mindset: [docs/MERGE_SMOKE_CHECKLIST.md](/docs/operations/merge-smoke-checklist/)

## Good LLM Behavior In This Repo

If you are an LLM helping with this codebase:

- read the existing implementation before proposing structural changes
- prefer small, local edits that preserve established patterns
- update tests when behavior changes
- keep public-site, Worker, email, and i18n consequences in mind together
- avoid inventing new config surfaces when an existing one already fits
- prefer repo-relative documentation links, not machine-specific paths
- do not silently drop locale support, embed behavior, or share-preview behavior while changing campaign pages

When in doubt, make the smallest change that keeps the site and Worker aligned, then verify it with the narrowest meaningful test plus the broader gate when warranted.
