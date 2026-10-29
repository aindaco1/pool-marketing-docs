# Pool roadmap review — October 28, 2026

Reviewed Pool `main` at `748922cbf14fdc7f008fca9b884e45e90bead994`, plus
the pinned Platform implementation, against `docs/ROADMAP.md`. The revised
canonical roadmap contains remaining work and conditional product decisions.
It is 783 words, down from 3,674. No future feature is marked implemented.

## Decisions and evidence

| Previous item | Disposition | Evidence in Pool or its pinned Platform checkout |
| --- | --- | --- |
| Basic tax fallback, data provenance, provider timeout, and quote API documentation work | Remove completed portions; retain coverage, classification, diagnostics, and reporting gaps. | `worker/src/tax.js`, `worker/src/index.js` (`handleTaxQuote`), `docs/TAX_CALCULATOR.md`, and Platform `packages/tax-core/src/`. |
| A separate monthly Pool tax-rate watcher | Replace with expansion of the existing weekly Platform candidate-review workflow and reviewed consumer pins. | Platform `.github/workflows/open-tax-data.yml`; candidate creation is not automatic adoption. |
| New Mexico starter metadata | Preserve existing source/generation fields; retain refresh, expanded coverage, effective periods, and stale-data behavior. | Platform `packages/tax-core/src/nm-grt-starter.js` has five locations. |
| Manual checkout and generic Podman wrappers | Remove the broad duplicate workflow item; retain physical Linux/Windows validation. | `scripts/test-checkout.sh --podman` starts containers and a host headed browser; this does not establish container GUI support or physical-host acceptance. |
| A declarative pod specification | Remove from the active list without claiming completion; reconsider if the existing development scripts present a concrete need. | Current `docs/PODMAN.md` and development helpers remain the operating contract. |
| Their Love Google Shopping launch | Move out of the platform roadmap as campaign operations, not as completed work. | `_campaigns/their-love.md` has a July 26 deadline, shopping disabled, and no availability date. `docs/SEO.md` retains launch requirements. No Merchant Center acceptance was inferred. |
| Routine SEO, accessibility, and localization checks | Keep in the owning guides and release checklist. Retain unfinished manual acceptance and Jev calibration separately. | `docs/SEO.md`, `docs/ACCESSIBILITY.md`, `docs/INTERNATIONALIZATION.md`, `docs/TESTING.md`, and `docs/MERGE_SMOKE_CHECKLIST.md`. |
| Supporter access, Podcast benefits, polls/votes, and additional locales | Keep conditional on a concrete use case. Acknowledge existing admin session/preview flows and the signed Podcast bridge. | `assets/js/manage-page.js`, `assets/js/admin-dashboard.js`, `worker/src/podcast-benefits.js`, and `_config.yml`. |
| Shared inventory and POS | Retain four implementation milestones and preserve the entire original specification in `docs/proposals/shared-inventory-pos.md`. | Exact comparison confirmed all original proposal requirements were preserved. Provider assumptions still need test-mode investigation. |

## Local source fingerprints

| Pool source | SHA-256 |
| --- | --- |
| `docs/ROADMAP.md` | `63beb1bf7978458bdb9f2a720d83f393b79d647081ee1e1f9b5a760c02b2cb21` |
| `docs/proposals/shared-inventory-pos.md` | `3364c371ba9ad7cad1ae54a05bfd8bac0391af7c3b1135ef84933f59ffc996f6` |

## Website and validation

- Regenerated the English roadmap from Pool and the Spanish roadmap with 32
  additional reviewed translation units (109 total). Spanish generation ran
  with translation-service requests disabled.
- Importer tests: 5 tests / 29 assertions passed. Spanish generator: 9 tests passed.
- Jekyll build, current-state audit, internal links (87 HTML pages), SEO audit,
  support audit, and both repositories' `git diff --check` passed.
- Local browser review confirmed both languages, headings, task lists, and
  localized guide links; the English preview was captured for review.

This review records checks before publication. The final website import uses
Pool commit `6c3b90aa21b37d2c493003d42ffaa08fa454a04e`. Publish the Pool source
before the website so the new proposal link resolves. Deployment verification
is separate from this review; none of these checks validate proposed features.
