---
title: "Source Map"
parent: "Reference"
nav_order: 4
render_with_liquid: false
---

# Source Map

## Last Updated

August 25, 2026

The Pool repository is the canonical source for imported product and
developer documentation. This page is generated from the same manifest the
sync script uses for validation, link rewriting, navigation metadata, and
output paths.

| Pool source | Marketing documentation | Section |
| --- | --- | --- |
| [`about.md`](https://github.com/aindaco1/pool/blob/main/about.md) | [About The Pool](/docs/overview/about-the-pool/) | Overview |
| [`terms.md`](https://github.com/aindaco1/pool/blob/main/terms.md) | [Terms & Creative Guidelines](/docs/overview/terms-and-guidelines/) | Overview |
| [`docs/CONTRIBUTING.md`](https://github.com/aindaco1/pool/blob/main/docs/CONTRIBUTING.md) | [Contributing](/docs/development/contributing/) | Development |
| [`docs/PROJECT_OVERVIEW.md`](https://github.com/aindaco1/pool/blob/main/docs/PROJECT_OVERVIEW.md) | [Project Overview](/docs/development/project-overview/) | Development |
| [`docs/WORKFLOWS.md`](https://github.com/aindaco1/pool/blob/main/docs/WORKFLOWS.md) | [Workflows](/docs/development/workflows/) | Development |
| [`docs/DEV_NOTES.md`](https://github.com/aindaco1/pool/blob/main/docs/DEV_NOTES.md) | [Developer Notes](/docs/development/developer-notes/) | Development |
| [`docs/CUSTOMIZATION.md`](https://github.com/aindaco1/pool/blob/main/docs/CUSTOMIZATION.md) | [Customization Guide](/docs/development/customization-guide/) | Development |
| [`docs/I18N.md`](https://github.com/aindaco1/pool/blob/main/docs/I18N.md) | [Internationalization](/docs/development/internationalization/) | Development |
| [`docs/EMBEDS.md`](https://github.com/aindaco1/pool/blob/main/docs/EMBEDS.md) | [Campaign Embeds](/docs/development/campaign-embeds/) | Development |
| [`docs/ADD_ON_PRODUCTS.md`](https://github.com/aindaco1/pool/blob/main/docs/ADD_ON_PRODUCTS.md) | [Add-On Products](/docs/development/add-on-products/) | Development |
| [`docs/PRODUCT_VIDEO_WORKFLOW.md`](https://github.com/aindaco1/pool/blob/main/docs/PRODUCT_VIDEO_WORKFLOW.md) | [Product Video Workflow](/docs/development/product-video-workflow/) | Development |
| [`AGENTS.md`](https://github.com/aindaco1/pool/blob/main/AGENTS.md) | [Agents & Operator Guide](/docs/development/agents-operator-guide/) | Development |
| [`README.md`](https://github.com/aindaco1/pool/blob/main/README.md) | [Platform README](/docs/development/platform-readme/) | Development |
| [`docs/ETHICAL_RISK.md`](https://github.com/aindaco1/pool/blob/main/docs/ETHICAL_RISK.md) | [Ethical Risk Review](/docs/development/ethical-risk-review/) | Development |
| [`docs/DASHBOARD.md`](https://github.com/aindaco1/pool/blob/main/docs/DASHBOARD.md) | [Admin Dashboard](/docs/operations/admin-dashboard/) | Operations |
| [`worker/README.md`](https://github.com/aindaco1/pool/blob/main/worker/README.md) | [Pledge Worker](/docs/operations/worker/) | Operations |
| [`docs/PAYMENT_PROCESSOR.md`](https://github.com/aindaco1/pool/blob/main/docs/PAYMENT_PROCESSOR.md) | [Payment Processor](/docs/operations/payment-processor/) | Operations |
| [`docs/EMAIL.md`](https://github.com/aindaco1/pool/blob/main/docs/EMAIL.md) | [Email System](/docs/operations/email-system/) | Operations |
| [`docs/PODMAN.md`](https://github.com/aindaco1/pool/blob/main/docs/PODMAN.md) | [Podman Local Dev](/docs/operations/podman-local-dev/) | Operations |
| [`docs/TESTING.md`](https://github.com/aindaco1/pool/blob/main/docs/TESTING.md) | [Testing Guide](/docs/operations/testing/) | Operations |
| [`docs/MERGE_SMOKE_CHECKLIST.md`](https://github.com/aindaco1/pool/blob/main/docs/MERGE_SMOKE_CHECKLIST.md) | [Merge Smoke Checklist](/docs/operations/merge-smoke-checklist/) | Operations |
| [`docs/SECURITY.md`](https://github.com/aindaco1/pool/blob/main/docs/SECURITY.md) | [Security Guide](/docs/operations/security/) | Operations |
| [`tests/security/README.md`](https://github.com/aindaco1/pool/blob/main/tests/security/README.md) | [Security Test Suite](/docs/operations/security-test-suite/) | Operations |
| [`docs/BACKUP_RESTORE.md`](https://github.com/aindaco1/pool/blob/main/docs/BACKUP_RESTORE.md) | [Backup, Restore, and Recovery](/docs/operations/backup-restore/) | Operations |
| [`docs/SHIPPING.md`](https://github.com/aindaco1/pool/blob/main/docs/SHIPPING.md) | [Shipping](/docs/operations/shipping/) | Operations |
| [`docs/TAX_CALCULATOR.md`](https://github.com/aindaco1/pool/blob/main/docs/TAX_CALCULATOR.md) | [Tax Calculator](/docs/operations/tax-calculator/) | Operations |
| [`docs/ACCESSIBILITY.md`](https://github.com/aindaco1/pool/blob/main/docs/ACCESSIBILITY.md) | [Accessibility](/docs/operations/accessibility/) | Operations |
| [`docs/SEO.md`](https://github.com/aindaco1/pool/blob/main/docs/SEO.md) | [SEO](/docs/operations/seo/) | Operations |
| [`docs/PERFORMANCE.md`](https://github.com/aindaco1/pool/blob/main/docs/PERFORMANCE.md) | [Performance](/docs/operations/performance/) | Operations |
| [`CHANGELOG.md`](https://github.com/aindaco1/pool/blob/main/CHANGELOG.md) | [Changelog](/docs/reference/changelog/) | Reference |
| [`docs/ROADMAP.md`](https://github.com/aindaco1/pool/blob/main/docs/ROADMAP.md) | [Roadmap](/docs/reference/roadmap/) | Reference |
| [`docs/PULL_REQUEST_TEMPLATE.md`](https://github.com/aindaco1/pool/blob/main/docs/PULL_REQUEST_TEMPLATE.md) | [Pull Request Template](/docs/reference/pull-request-template/) | Reference |

## Regenerate Documentation

```bash
POOL_SOURCE=/path/to/pool ruby scripts/sync_pool_docs.rb
python3 scripts/build_spanish_docs.py
```

The Campaign Creator Checklist remains a Pool-owned public route and is not
duplicated into this developer documentation tree.
