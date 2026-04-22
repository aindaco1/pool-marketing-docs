---
title: "Roadmap"
parent: "Reference"
nav_order: 2
render_with_liquid: false
---

# Roadmap

This roadmap is organized as a release history of the real project states we actually used, rather than a flat completed-features list.

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

### v0.9.4 — Current Local App State

This is the current local release milestone reflected in the app and docs. The major theme here was tax-aware checkout maturity plus the last round of fork-polish work needed to make the platform feel more production-shaped.

New in this version:

- provider-driven tax calculation through `flat`, `offline_rules`, `nm_grt`, and `zip_tax` modes instead of only one flat-rate assumption
- provisional tax UX in cart and checkout so the browser can show `--` until the Worker has enough billing or shipping destination detail to return a real answer
- final-tax destination plumbing across cart, custom checkout, Manage Pledge, stored pledge data, and supporter emails so tax math stays consistent everywhere
- a free-first New Mexico path through a vendored starter dataset plus optional EDAC refinement, alongside better local smoke coverage for provider-driven tax setups
- shared fork-branding polish so the same config surface now themes on-site Stripe Elements, supporter emails, and more of the localized metadata layer
- localized follow-up work such as cart-button summaries, checkout tax-location helper copy, and locale-aware public metadata / JSON-LD so the tax-aware flows still read cleanly in English and Spanish

## Next

Work still planned after `0.9.4` includes:

- an admin dashboard and stronger operator tooling around campaign, platform, and supporter data
- a stronger content-editor story than the current Pages CMS setup
- further tax-calculator work for broader US and international coverage, better local-jurisdiction depth, and clearer tax-data refresh workflows
- additional denial-of-service defense and platform-observability follow-up
- more flexible pricing support for add-on variants

## Known Issues

**Credit Card Autofill**: credit-card number, expiry, and CVC fields live inside Stripe-controlled secure UI, so browser autofill support there is constrained by Stripe rather than the surrounding app.
