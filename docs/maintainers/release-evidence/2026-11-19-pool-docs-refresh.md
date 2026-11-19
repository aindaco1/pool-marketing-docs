# Pool documentation refresh — November 19, 2026

## Source and scope

Reviewed Pool main at `cdef6df8c5d5b2b6177f47ad173b12c26c24367c`, including
the pinned Platform 0.51.1 at `d0b9e9595e2f57cbff26219db2bf78c26235d2f9`.
The previous website import was `6c3b90aa21b37d2c493003d42ffaa08fa454a04e`.
The reviewed Pool documentation is committed at `4ed4b6f8877e118a67d95fc88b2a91a2c4d514a7`.
The Source Map now records that exact revision. The checks below describe local
validation; production deployment is verified separately after pushing both repositories.

Read Pool's operating guide, documentation index, current owning guides,
changelog, November release evidence, and relevant source changes. Checked
report formulas and CSV semantics, provider deadlines, editor ownership,
inventory reservations, setup tooling, and the remaining roadmap proposals.

Pool source updates cover About and Terms in both languages, the README,
changelog, dashboard ownership, provider timeouts, maintenance deployment,
Jev acceptance criteria, and roadmap. The website imports the newer backup,
email, reporting, media, Podman, SEO, architecture, and API guidance as well.
Site-owned homepage copy, FAQ, and navigation indexes were updated separately.
Terms clarify gross campaign progress and recorded/estimated fees; they do
not introduce a new supporter charge or change refund, access, or privacy rules.

## Roadmap decisions

| Area | Treatment and evidence |
| --- | --- |
| Tax transport | Existing typed errors, estimate metadata, and deadlines through response bodies are the baseline. Remaining work concerns consistent explanations, coverage, item categories, and jurisdiction-level exports. See `worker/src/tax.js` and Platform `packages/tax-core/src/provider.js`. |
| Reporting | Daily pledge reports already include Stripe fee allocation and once-per-pledge CSV snapshots. Retain the distinct tax-liability export proposal. See `worker/src/pledge-financials.js`, `docs/DASHBOARD.md`, and the November 17 report evidence. |
| Inventory | Pool already uses a Durable Object with shared reservation mechanics. Keep cross-channel Pool/Store/POS authority and reconciliation as proposed work. See `worker/src/tier-inventory-do.js` and `docs/proposals/shared-inventory-pos.md`. |
| Terminal setup | Local/production setup, dry runs, and readiness checks already exist in `scripts/setup-deploy.mjs`. Consolidate a richer terminal interface into a conditional onboarding decision. |
| Validation checklist | Remove duplicated product-roadmap tasks. Accessibility owns manual assistive-technology checks; Podman records physical Linux/Windows coverage gaps; Testing now explicitly owns the Jev calibration and held-out acceptance criteria. No unperformed check is marked complete. |
| Campaign-dependent features | Retain supporter-link recovery, creator-content translations, Podcast entitlement completion, and poll/vote differentiation as conditional decisions. Existing admin sessions, localized UI, signed bridge, and tally storage are not proposed again. |

The previously removed roadmap introductory disclaimer remains absent.

## Website validation

- Full English import and Spanish regeneration are idempotent across 84 Markdown
  pages. Regeneration completed with translation-network requests disabled.
- Added 66 reviewed Spanish translation units and maintained localized section
  anchors. About and Terms use Pool's curated Spanish sources.
- Importer tests: 5 tests, 29 assertions; Spanish generator: 9 tests. All pass.
- Production Jekyll builds pass for both repositories.
- Current-state, internal-link (87 HTML pages), SEO, and support audits pass.
- Checked rendered About/Terms in Pool and the website's Terms/Roadmap in both
  languages, including policy anchors, dates, fee wording, and removed roadmap
  text. Browser inspection confirmed the roadmap, Spanish report section, and
  updated Spanish homepage copy.
- Pool root and Worker dependency audits pass in both production and full scopes
  with zero findings on this run. Existing historical exceptions are not used.

## Pool regression gate

The complete premerge gate runs in an isolated checkout containing the reviewed
documentation patch, matching submodules, and copied dependencies. Local
credentials, user drafts, and the three pre-existing untracked files in the
working Pool checkout are excluded. All 12 edited Pool source files matched
the isolated validation snapshot.

The full gate passed: 1,252 unit tests (one skipped), 127 security tests, host
Worker smoke, Podman mutable-pledge smoke, and 178 browser tests (three existing
fixture-dependent skips). Secret, template, syntax, and build-artifact checks
also passed. Browser fixtures do not establish live provider acceptance.

Temporary Pool test services have stopped; only the docs preview remains on
port 4184. The isolated checkout, source-page preview, patch, audit output, and
phase logs were moved to the recoverable local archive:

`/Users/aindaco1/.Trash/pool-docs-review-20261119-v_uz2jq9`

No production payment or live email send was performed during validation.
Publication uses the normal main-branch Pages workflows; no Worker deployment
is required for these documentation and static-page changes.
