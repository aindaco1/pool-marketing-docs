---
title: Development
nav_order: 3
has_children: true
---

# Development

## Last Updated

September 6, 2026

Contribution flow, architecture notes, implementation gotchas, and fork-facing extension points live here.

## Recommended Path

1. [Platform README](/docs/development/platform-readme/) for a short introduction and quick start.
2. [Contributing](/docs/development/contributing/) for dependencies, local setup, contribution workflow, and implementation conventions.
3. [Architecture](/docs/development/architecture/) for ownership, storage, campaign and pledge lifecycle, and the code map.
4. [Campaign Content Model](/docs/development/content-model/) for campaign fields, tiers, media, diary entries, and decisions.
5. [Worker API](/docs/reference/worker-api/) for endpoint contracts and request/response examples.
6. [Deployment](/docs/operations/deployment/) for first-time setup, credentials, and separate Pages and Worker release flows.
7. [Agents & Operator Guide](/docs/development/agents-operator-guide/) for repository rules and the source-of-truth boundaries.

## Guide Ownership

Keep detailed procedures in the guide that owns them. Architecture owns system
relationships; Campaign Content Model owns authoring fields; Worker API owns
endpoint contracts. Customization owns settings and mirrors. Provider setup
belongs in Payment Processor, Tax Calculator, Shipping, and Email. Deployment
owns release wiring, Testing owns test execution, and Merge Smoke owns operator
sign-off. The Platform and Worker READMEs are entry points to these guides.

## Configuration And Extension

- [Customization Guide](/docs/development/customization-guide/) for the supported `_config.yml` surface, design tokens, pricing, shipping, and fork branding knobs.
- [Internationalization](/docs/development/internationalization/) for locale config, routing, translation catalogs, and the language-addition workflow.
- [Campaign Embeds](/docs/development/campaign-embeds/) for hosted embed routes, resize behavior, and localization rules.
- [Add-On Products](/docs/development/add-on-products/) for the platform-wide merch catalog, inventory model, runtime contract, and shipping behavior.
- [Product Video Workflow](/docs/development/product-video-workflow/) for local capture, rendering, verification, and publication boundaries.
- [Ethical Risk Review](/docs/development/ethical-risk-review/) for evaluating changes involving money, data, messaging, automation, admin power, visibility, and sharing.
- [Agents & Operator Guide](/docs/development/agents-operator-guide/) for repo invariants, source-of-truth guidance, and safe contributor/LLM workflows.

## Day-To-Day Use

This section is the right home base when you are opening your first PR, mapping a feature to existing architecture, or adapting The Pool into a branded fork.
