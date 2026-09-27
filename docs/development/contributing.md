---
title: "Contributing"
parent: "Development"
nav_order: 1
render_with_liquid: false
---

# Contributing to The Pool

## Last Updated

September 27, 2026

This guide covers onboarding, the contribution workflow, and shared development
patterns. Start with [AGENTS](/docs/development/agents-operator-guide/) and the
[documentation index](/docs/development/) to identify the guide that owns your change.

## Development Setup

Use the Node version in [.nvmrc](https://github.com/aindaco1/pool/blob/main/.nvmrc), Git, and Podman for the standard
local path. Host Jekyll additionally needs Ruby and Bundler; Stripe CLI is
optional for real test-mode webhook forwarding.

From the repository root:

```bash
git submodule update --init --recursive
npm ci
npm run setup:deploy -- --mode=local
npm run podman:doctor
./scripts/dev.sh --podman
```

See [Podman](/docs/operations/podman-local-dev/) for container setup, supported hosts, service supervision,
resource requirements, and logs. Use [Testing](/docs/operations/testing/) for fixture seeding,
manual checkout, and browser tests; the automated browser harness serves a
built static site.

`npm run secrets:dev` creates/updates ignored `worker/.dev.vars` from the example,
generates local signing/session secrets, and prompts for optional provider
keys without printing them. Local admin bootstrap access uses
`ADMIN_BOOTSTRAP_EMAILS`; the dashboard shows credential status only.
[Security](/docs/operations/security/) defines secret boundaries, and
[Deployment](/docs/operations/deployment/) owns hosted account/namespace setup.

Canonical settings belong in `_config.yml`. `_config.local.yml` carries only
local overrides. Supported dev/test scripts synchronize `worker/wrangler.toml`;
after direct configuration changes, restart the stack or run
`npm run sync:worker-config`. See [Customization](/docs/development/customization-guide/).

### Host Fallback

Install the locked host dependencies from the repository root:

```bash
bundle install
npm ci --prefix worker
```

Then use the existing launcher:

```bash
./scripts/dev.sh
```

For manual service startup, run these in separate terminals from the repository root:

```bash
bundle exec jekyll serve --config _config.yml,_config.local.yml --port 4000
```

```bash
npm --prefix worker run dev
```

Configure a single Stripe listener and its matching local webhook secret using
[Payment Processor](/docs/operations/payment-processor/). Provider setup is optional for
fixture-based checks; real test-mode payments need the matching test credentials.
If styles are stale, `bundle exec jekyll clean` clears the generated site/cache.

## Contribution Workflow

1. Inspect `git status`; preserve unrelated edits and initialize the recorded shared dependencies.
2. Read the implementation, nearby tests, [Architecture](/docs/development/architecture/), and the relevant domain guide before changing behavior.
3. Use the existing shared configuration, rendering, validation, and persistence paths.
4. Run the narrowest meaningful check, then the complete `npm run test:premerge` gate for substantial or release-facing changes. [Testing](/docs/operations/testing/) owns commands and [Merge Smoke](/docs/operations/merge-smoke-checklist/) owns operator sign-off.
5. Update the authoritative guide when behavior changes, record completed changes under Unreleased in the [Changelog](/docs/reference/changelog/), and keep prospective work in the [Roadmap](/docs/reference/roadmap/).
6. Open a focused PR using the [PR template](/docs/reference/pull-request-template/), with relevant validation and rollback information.

Use `feat/`, `fix/`, or `docs/` branch names and conventional commit prefixes
such as `feat`, `fix`, `docs`, `chore`, or `infra`. Link related issues.
Include rendered screenshots for UI changes, including desktop/tablet/mobile
and Spanish admin views when those surfaces change.

Review [Ethical Risk](/docs/development/ethical-risk-review/) for changes to money, supporter data,
messaging, analytics, admin power, visibility, or automation. Dashboard work
also requires the relevant [Accessibility](/docs/operations/accessibility/), [I18N](/docs/development/internationalization/),
[Security](/docs/operations/security/), and [SEO](/docs/operations/seo/) contracts.

## Local Workspace Cleanup

Run cleanup after validation and after stopping services that use the generated
output. Start with `git status --short`, `git worktree list`, and
`git ls-files --others --ignored --exclude-standard --directory`; being ignored
does not mean a file is disposable.

| Keep for development, testing, or recovery | Regenerate when needed |
| --- | --- |
| Source, `_campaigns/`, `_campaign_drafts/`, repository media, tests/fixtures, and committed release evidence | `_site/` and temporary duplicate site builds |
| Jev corpus/report/review files cited in release evidence | Jev run `site/` directories |
| Root and Worker `node_modules/`, installed Ruby gems, `.bundle/` configuration, and shared submodules | `.jekyll-cache/`, `.sass-cache/`, and `.jekyll-metadata` |
| `_config.local*.yml`, `worker/.dev.vars`, and local environment files | Completed `test-results/`, `playwright-report/`, and coverage output |
| `worker/.wrangler/state/`, browser profiles/drafts, and recovery exports | Inspected disposable files under `tmp/` and `worker/.wrangler/tmp/` |
| Podman machines, development images/volumes, and Playwright browser installations | Obsolete logs and screenshots already retained in release evidence |

Inspect `tmp/` before clearing it: recovery exports or an unfinished investigation
are not build artifacts. Move selected output to a dated recovery directory
outside the checkout or the system Trash, and record its original paths. Avoid
blanket `git clean -fdx`, browser-storage clearing, or container/volume pruning.
Restarting `./scripts/dev.sh --podman` rebuilds the site; the browser harness also
builds `_site/` automatically. [Testing](/docs/operations/testing/#local-test-data) owns deliberate
local-state resets.

Fetch/prune remote references, compare each branch tip with its merged PR, and
check that no worktree uses it. Squash-merged branches may not appear under
`git branch --merged`; verify the PR head and merge commit instead. Preserve
unmerged work, or incorporate a verified generated correction before removing
its branch. Save branch names and commit IDs, with a Git bundle for commits not
reachable from main, before removing stale local and remote refs. Recheck tips
immediately before deletion so another collaborator’s newer commit is retained.

## Development Patterns

Theme and email/checkout branding use the `design.*` / `platform.*` surface in
[Customization](/docs/development/customization-guide/). Jekyll compiles `assets/main.scss` and the
Pool partials under `assets/partials/` plus the pinned Platform design styles; add styles to the existing
component or page partial. Font stylesheets load from the document head.
Generated asset minification belongs to [Performance](/docs/operations/performance/).

### Liquid Includes and Collections

Inside an include, read passed values through `include`, for example
`{{ include.pledged }}` for `{% include progress.html pledged=campaign.pledged_amount %}`.
An empty YAML array is truthy in Liquid; use a size check:

```liquid
{% if page.support_items and page.support_items.size > 0 %}
  <!-- Render the collection -->
{% endif %}
```

Quote YAML strings containing special characters and guard division by zero
before computing progress. [Content Model](/docs/development/content-model/) owns campaign
field examples and countdown boundaries.

### Cart and Mobile Layers

Shared UI talks to `window.PoolCartProvider` through the existing cart runtime
includes and scripts. Stripe owns the payment iframe. Do not introduce a second
cart path or hosted-cart DOM patches.

The mobile menu toggle gains elevated stacking only while `.is-open`; its
closed state must remain underneath the cart overlay. Reuse `_includes/header.html` and the pinned Platform
`shared/dust-wave-platform/packages/design-core/styles/_layout.scss` pattern
when changing navigation or dialogs. Shared code upgrades follow the immutable
Platform boundary; do not patch the submodule in place.

### Accessibility and Localization Helpers

Use `.sr-only` for supporting text, labeled controls, decorative SVG state,
and the existing live regions/focus behavior. `_includes/a11y.html` supplies
`sr-text` and `external-link` patterns. Alt text is recommended for meaningful images and does not block saving or publishing;
intentional decorative images use the explicit decorative state.

Shared strings use `_includes/t.html`, with interpolation and locale fallback.
Public links use the locale helpers; token/query/hash preservation is part of
those helpers' contract. See [Accessibility](/docs/operations/accessibility/) and
[I18N](/docs/development/internationalization/) for the maintained behavior and verification requirements.
