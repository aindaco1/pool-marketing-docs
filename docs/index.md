---
title: FAQ
nav_order: 1
description: Frequently asked questions and a recommended reading path for The Pool.
---

# FAQ

## Last Updated

September 6, 2026

This page is the **fastest way to get oriented** before you dive into the full docs.

## Common Questions

### What is The Pool?

The Pool is an **all-or-nothing crowdfunding platform** for film, media, and other artist-driven projects. It is designed to feel *lightweight for supporters* while still giving maintainers real infrastructure for pledges, fulfillment, and ongoing updates.

For the full public framing, read [About The Pool](/docs/overview/about-the-pool/).

### How does all-or-nothing pledging work?

Supporters make pledges during a campaign window, but cards are **only charged if the campaign reaches its goal**. If the goal is not met, the campaign closes without collecting funds.

That supporter-facing explanation lives in [About The Pool](/docs/overview/about-the-pool/), and the implementation details live in [Architecture](/docs/development/architecture/).

### Do supporters need an account?

No. The Pool is intentionally **account-light**. Supporters manage pledges through secure email magic links instead of usernames and passwords.

If you want the technical version of that flow, start with [Architecture](/docs/development/architecture/) and then [Worker API](/docs/reference/worker-api/).

### How do magic links work?

After a pledge is created, the Worker sends the supporter a **scoped token link** that lets them view, modify, or cancel that pledge without a traditional account system. The browser never becomes the source of truth for pledge state.

Read [About The Pool](/docs/overview/about-the-pool/) for the plain-language explanation and [Architecture](/docs/development/architecture/) plus [Security Guide](/docs/operations/security/) for the engineering model.

### Who is The Pool for?

It is built for creators who want **direct campaign support** without turning the experience into a conventional account-heavy commerce platform. It is also designed so forks can adapt the system to other branded crowdfunding projects.

The public context is in [About The Pool](/docs/overview/about-the-pool/), and the fork-facing customization surface is in [Customization Guide](/docs/development/customization-guide/).

### How is it built?

The Pool combines [Jekyll](https://jekyllrb.com/), [Cloudflare Workers](https://workers.cloudflare.com/), [Stripe](https://stripe.com/), [Podman](https://podman.io/), and [GitHub Pages](https://pages.github.com/) into a stack that stays **relatively simple to reason about** while still supporting real pledge flows.

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
