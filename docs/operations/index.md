---
title: Operations
nav_order: 4
has_children: true
---

# Operations

## Last Updated

August 25, 2026

This section covers the admin dashboard, pledge Worker, local runtime options, quality gates, and the operational rules that protect checkout and fulfillment behavior.

## Local Runtime And Services

- [Admin Dashboard](/docs/operations/admin-dashboard/) for browser-based campaign editing, reports, analytics, marketing tools, media uploads, and user management.
- [Pledge Worker](/docs/operations/worker/) for secrets, KV namespaces, webhooks, environment variables, and API endpoints.
- [Payment Processor](/docs/operations/payment-processor/) for Stripe setup, canonical checkout, webhooks, settlement, and reconciliation.
- [Email System](/docs/operations/email-system/) for sender setup, transactional and campaign email behavior, localization, delivery, and retries.
- [Podman Local Dev](/docs/operations/podman-local-dev/) for the containerized local stack, support matrix, and troubleshooting flow.

## Quality, Security, And Release Checks

- [Testing Guide](/docs/operations/testing/) for automated gates, manual regression runs, and test authoring patterns.
- [Performance](/docs/operations/performance/) for public-page loading, generated asset minification, intent prefetching, and validation expectations.
- [Merge Smoke Checklist](/docs/operations/merge-smoke-checklist/) for operator-ready checkout, modify, and cancel verification before merge.
- [Security Guide](/docs/operations/security/) for current security boundaries, applied hardening, testing, and incident response.
- [Security Test Suite](/docs/operations/security-test-suite/) for the penetration-style checks that validate the security contract.

## Commerce And Platform Guardrails

- [Backup, Restore, and Recovery](/docs/operations/backup-restore/) for snapshot readiness, retention, restore order, Stripe reconciliation, and recovery evidence.
- [Shipping](/docs/operations/shipping/) for the Worker-first shipping model, USPS integration boundary, and fallback policy.
- [Tax Calculator](/docs/operations/tax-calculator/) for provider modes, mirrored configuration, Worker-canonical quotes, troubleshooting, and verification.
- [Accessibility](/docs/operations/accessibility/) for current priorities, critical surfaces, coverage, and manual checks.
- [SEO](/docs/operations/seo/) for indexing rules, metadata, structured data, and validation expectations.
