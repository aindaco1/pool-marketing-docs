---
title: "Pledge Worker"
parent: "Operations"
nav_order: 2
render_with_liquid: false
---

# The Pool Pledge Worker

## Last Updated

September 6, 2026

The Worker owns canonical checkout, Stripe integration, pledge persistence,
order-scoped supporter access, email delivery, live data, administration, and
scheduled campaign settlement.

## Development

Run the complete local stack from the repository root:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

For a Worker-only host session, run from this directory:

```bash
npm ci
npm run dev
```

The Worker npm scripts synchronize the config mirror first. Canonical settings
live in the root `_config.yml`; local differences live in `_config.local.yml`.
Local credentials and bootstrap access use ignored `.dev.vars` in this
directory. Follow [Contributing](/docs/development/contributing/) and
[Podman](/docs/operations/podman-local-dev/) for setup and supported runtime requirements.

## Ownership and Reference

The Worker consumes immutable Platform packages for shared mechanics. Pool
retains every route, request schema, campaign/pledge model, storage policy,
credential, provider side effect, deployment, and rollback decision. The
Jekyll Template is source-upgrade tooling and is not imported by this Worker.

- [Architecture](/docs/development/architecture/): ownership, persistence, supporter access, and scheduling.
- [Worker API](/docs/reference/worker-api/): endpoint contracts and request/response examples.
- [Customization](/docs/development/customization-guide/): site-to-Worker settings and mirrors.
- [Payment Processor](/docs/operations/payment-processor/): checkout, webhooks, settlement, and reconciliation.
- [Email](/docs/operations/email-system/): sender setup, outbox, reminders, and suppression.
- [Tax](/docs/operations/tax-calculator/) and [Shipping](/docs/operations/shipping/): provider-specific configuration and quote behavior.
- [Dashboard](/docs/operations/admin-dashboard/): admin access, editing, reports, diagnostics, and runtime overrides.
- [Security](/docs/operations/security/), [Ethical Risk](/docs/development/ethical-risk-review/), and [Backup and Restore](/docs/operations/backup-restore/): trust and recovery boundaries.
- [Testing](/docs/operations/testing/): focused checks, fixtures, and the complete gate.

## Deployment

Use the manually dispatched **Deploy Production** workflow for a coordinated
site and Worker release. Routine pushes to `main` refresh Pages through
**Refresh Production Pages** and do not deploy the Worker.
[Deployment](/docs/operations/deployment/) owns credentials, release steps, and
post-deploy diary checks. The manual Worker-only fallback, run from this
directory, is `npm run deploy`.
