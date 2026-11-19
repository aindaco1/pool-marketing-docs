---
title: FAQ
nav_order: 1
description: Frequently asked questions and a recommended reading path for The Pool.
---

# FAQ

## Last Updated

November 19, 2026

This page is the **fastest way to get oriented** before you dive into the full docs.

## Common Questions

### What is The Pool?

The Pool is an **all-or-nothing crowdfunding platform** for film, media, and other artist-driven projects. It is designed to feel *lightweight for supporters* while still giving maintainers real infrastructure for pledges, fulfillment, and ongoing updates.

For the full public framing, read [About The Pool](/docs/overview/about-the-pool/).

### How does all-or-nothing pledging work?

Supporters save a payment method through Stripe during a campaign window. Cards are **charged only after a funded campaign reaches its deadline**. If the goal is not met, the campaign closes without collecting funds. A checkout containing several campaigns creates separate campaign pledges, which settle separately.

That supporter-facing explanation lives in [About The Pool](/docs/overview/about-the-pool/), and the implementation details live in [Architecture](/docs/development/architecture/).

### Do supporters need an account?

No. Supporters manage pledges through secure email links instead of usernames and passwords.

If you want the technical version of that flow, start with [Architecture](/docs/development/architecture/) and then [Worker API](/docs/reference/worker-api/).

### How do magic links work?

After a pledge is created, the Worker sends the supporter a **scoped token link** for that pledge. Supporters can modify or cancel while the campaign is open, including after it reaches its goal. Those changes close at the deadline. A delayed confirmation email does not undo a saved pledge; contact the campaign's support address before submitting another pledge if the result is unclear.

Read [About The Pool](/docs/overview/about-the-pool/) for the plain-language explanation and [Architecture](/docs/development/architecture/) plus [Security Guide](/docs/operations/security/) for the engineering model.

### What happens when I edit checkout details?

Contact and address fields stay available while payment fields load. Complete details prepare payment automatically after a short pause. Editing the email or destination refreshes payment setup, tax, and shipping without replacing the form. Preparing payment does not confirm a pledge or charge a card; the supporter must still complete confirmation.

See [Payment Processor](/docs/operations/payment-processor/#editable-inline-checkout-and-shared-helpers) for readiness, reservation release, and retry behavior.

### Are tax and shipping amounts always exact?

The Worker calculates the checkout totals. Tax depends on the configured provider and available destination data. Bundled U.S. ZIP rates have partial coverage and remain estimates; a state-only fallback can omit local taxes even with a complete address. Known ZIP/state conflicts must be corrected, while suggested city names are optional. Shipping uses the configured carrier quote or fallback rules.

See [Tax Calculator](/docs/operations/tax-calculator/), [Shipping](/docs/operations/shipping/), and [Terms & Creative Guidelines](/docs/overview/terms-and-guidelines/). Refreshing reference data does not reprice already confirmed pledges.

### Does saving a campaign publish it?

No. **Save** stores a shared working copy; **Preview** lets authorized reviewers inspect it; **Publish** releases it to the public site. The dashboard follows deployment of the saved revision before reporting Live. Browser-local drafts are separate recovery copies. Conflicting edits remain available for comparison instead of overwriting a newer working copy.

Read [Saving and Publishing](/docs/operations/admin-dashboard/#saving-and-publishing) and [Draft Recovery](/docs/operations/admin-dashboard/#recover-a-missing-browser-draft).

### Do campaign reports include Stripe fees?

Yes. Daily pledge emails, report previews, and pledge CSVs show the campaign's share of Stripe fees and its amount after those fees. Recorded fees take precedence; planning estimates are clearly labeled. Gross goal progress is unchanged, and the amount after fees is not a guaranteed payout. Current fee figures appear once per pledge in CSV ledger exports, even when that pledge has several history rows.

See [Daily Pledge Summary](/docs/operations/admin-dashboard/#daily-pledge-summary) for the estimate, allocation, and export rules.

### How are pledges and email protected during recovery?

Pledge records and email delivery have separate lifecycles. Pool queues its own messages without rolling back saved pledges when delivery fails. Automatic retries stop 23 hours after the first possible provider send; uncertain outcomes are kept for reconciliation. Campaign diary emails link to individual entries, and campaign updates include an unsubscribe option.

Operators can configure encrypted production snapshots every four hours, verify the remote archive, and follow a documented restore and Stripe-reconciliation process. Off-device copies are checked against the selected archive's checksum. Retention pruning and preview cleanup validate the complete reviewed set before deleting records or snapshots. A successful backup check does not establish that a restore has been tested. See [Email System](/docs/operations/email-system/) and [Backup, Restore, and Recovery](/docs/operations/backup-restore/).

### Who is The Pool for?

It is built for creators who want **direct campaign support** without turning the experience into a conventional account-heavy commerce platform. It is also designed so forks can adapt the system to other branded crowdfunding projects.

The public context is in [About The Pool](/docs/overview/about-the-pool/), and the fork-facing customization surface is in [Customization Guide](/docs/development/customization-guide/).

### How is it built?

Jekyll builds the public site for GitHub Pages. A Cloudflare Worker owns checkout totals, pledge storage, administration, and settlement; Stripe saves payment methods and processes charges, and Resend delivers email. Podman supports local development. Pinned Dust Wave Platform packages supply shared checkout, block editing, postal/tax, media, and other helpers while Pool owns campaign and pledge rules.

Start with [About The Pool](/docs/overview/about-the-pool/) and [Architecture](/docs/development/architecture/) for the system map.

### Is it open source?

Yes. The Pool is **open source** and documented for contributors, maintainers, and forks.

## Recommended Reading Path

1. [About The Pool](/docs/overview/about-the-pool/) for product scope, supporter model, stack, and deployment shape.
2. [Architecture](/docs/development/architecture/) for the system map and architecture boundaries.
3. [Worker API](/docs/reference/worker-api/) for endpoint contracts and request/response examples.
4. [Payment Processor](/docs/operations/payment-processor/) for canonical checkout, Stripe webhooks, settlement, and reconciliation.
5. [Deployment](/docs/operations/deployment/) for setup, credentials, and the site/Worker release workflow.
6. [Admin Dashboard](/docs/operations/admin-dashboard/) when you are editing campaigns, settings, add-ons, reports, analytics, marketing links, media, or users.
7. [Testing Guide](/docs/operations/testing/) before shipping any behavioral change.

## Browse By Section

Start with the section that matches the kind of work you are doing:

- [Overview](/docs/overview/) for public-facing context, platform framing, and policy pages.
- [Development](/docs/development/) for contributor setup, architecture, customization, embeds, localization, ethical review, and extension work.
- [Operations](/docs/operations/) for Worker and payment setup, email, backup/recovery, local environments, shipping, security, accessibility, SEO, and merge readiness.
- [Reference](/docs/reference/) for release notes, prospective work, shared process templates, and the Pool-to-marketing source map.
