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

### v0.9.1 — Current Local App State

This is the current local state of the app. It is the version reflected in the local config and represents work completed after the `0.9` milestone rather than a separately deployed public release.

New in this version:

- improved checkout confirmation behavior and supporter email delivery
- hosted live campaign embed widget and richer embed-builder flow
- richer campaign share-card previews aligned with the embed design language
- embed close-link and return-path polish for campaign widgets
- docs cleanup and release-polish work following the larger `0.9` milestone
- countdown behavior cleanup so expired campaign countdowns stop showing after deadlines

## Next

Work still planned after `0.9.1` includes:

- read-only or lightly interactive admin tooling for operators
- a stronger content-editor story than the current Pages CMS setup
- replacing flat-rate sales-tax logic with a more robust tax-calculation model
- additional denial-of-service defense work
- more flexible pricing support for add-on variants

## Known Issues

**Credit Card Autofill**: credit-card number, expiry, and CVC fields live inside Stripe-controlled secure UI, so browser autofill support there is constrained by Stripe rather than the surrounding app.
