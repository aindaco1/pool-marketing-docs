---
title: Operations
nav_order: 4
has_children: true
---

# Operations

This section covers the pledge Worker, local runtime options, quality gates, and the operational rules that protect checkout and fulfillment behavior.

## Local Runtime And Services

- [Pledge Worker](/docs/operations/worker/) for secrets, KV namespaces, webhooks, environment variables, and API endpoints.
- [Podman Local Dev](/docs/operations/podman-local-dev/) for the containerized local stack, support matrix, and troubleshooting flow.

## Quality, Security, And Release Checks

- [Testing Guide](/docs/operations/testing/) for automated gates, manual regression runs, and test authoring patterns.
- [Merge Smoke Checklist](/docs/operations/merge-smoke-checklist/) for operator-ready checkout, modify, and cancel verification before merge.
- [Security Guide](/docs/operations/security/) for the security architecture, hardening notes, and vulnerability history.
- [Security Test Suite](/docs/operations/security-test-suite/) for the penetration-style checks that validate the security contract.

## Commerce And Platform Guardrails

- [Shipping](/docs/operations/shipping/) for the Worker-first shipping model, USPS integration boundary, and fallback policy.
- [Tax Calculator](/docs/operations/tax-calculator/) for provider modes, mirrored config, provisional browser behavior, and checkout-tax verification.
- [Accessibility](/docs/operations/accessibility/) for current priorities, critical surfaces, coverage, and manual checks.
- [SEO](/docs/operations/seo/) for indexing rules, metadata, structured data, and validation expectations.
