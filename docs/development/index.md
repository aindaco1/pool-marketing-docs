---
title: Development
nav_order: 3
has_children: true
---

# Development

## Last Updated

July 16, 2026

Contribution flow, architecture notes, implementation gotchas, and fork-facing extension points live here.

## Recommended Path

1. [Platform README](/docs/development/platform-readme/) for the current release, features, quick start, test surface, and deployment model.
2. [Contributing](/docs/development/contributing/) for prerequisites, local setup, GitHub workflow, and the current project status.
3. [Project Overview](/docs/development/project-overview/) for the system summary, funding flow, campaign lifecycle, and code map.
4. [Workflows](/docs/development/workflows/) for the pledge state machine, storage model, and Worker route behavior.
5. [Payment Processor](/docs/operations/payment-processor/) for canonical checkout, Stripe integration, settlement, and reconciliation.
6. [Developer Notes](/docs/development/developer-notes/) for stack-specific implementation details, content model guidance, and gotchas.
7. [Agents & Operator Guide](/docs/development/agents-operator-guide/) for the safest way to make repo changes without drifting site, Worker, checkout, or localized behavior out of sync.

## Configuration And Extension

- [Customization Guide](/docs/development/customization-guide/) for the supported `_config.yml` surface, design tokens, pricing, shipping, and fork branding knobs.
- [Internationalization](/docs/development/internationalization/) for locale config, routing, translation catalogs, and the language-addition workflow.
- [Campaign Embeds](/docs/development/campaign-embeds/) for hosted embed routes, resize behavior, and localization rules.
- [Add-On Products](/docs/development/add-on-products/) for the platform-wide merch catalog, inventory model, runtime contract, and shipping behavior.
- [Ethical Risk Review](/docs/development/ethical-risk-review/) for evaluating changes involving money, data, messaging, automation, admin power, visibility, and sharing.
- [Agents & Operator Guide](/docs/development/agents-operator-guide/) for repo invariants, source-of-truth guidance, and safe contributor/LLM workflows.

## Day-To-Day Use

This section is the right home base when you are opening your first PR, mapping a feature to existing architecture, or adapting The Pool into a branded fork.
