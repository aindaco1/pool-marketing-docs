# Pool documentation refresh — October 28, 2026

## Source and scope

The import baseline is Pool `main` at
[`748922cbf14fdc7f008fca9b884e45e90bead994`](https://github.com/aindaco1/pool/commit/748922cbf14fdc7f008fca9b884e45e90bead994).
The remote branch matched that revision during this review. The previous site
snapshot was `1f7a95ba03ce1290c5769874de806dc3551c4f86` from September 27.
Pool's current package and release tag are v1.2.26; later backup commits are
included in the imported main-branch guides.

Reviewed the documentation index, owning product and operational guides,
changelog, recent source diffs, checkout release evidence, tax implementation
and regressions, campaign publication contract, and scheduled backup workflow.
Refreshed the full manifest in English and Spanish. Site-owned homepage copy,
FAQ, section indexes, and maintenance guidance were reviewed separately.

The sibling Pool checkout also contains five canonical documentation edits:
README now names v1.2.26 and links to release evidence; English and Spanish About
and Terms clarify editable checkout, partial tax coverage, unchanged confirmed
pledge amounts, and campaign saving/publication. Terms retain the existing
eligibility, refund, fulfillment, and privacy provisions; their revised effective
date is October 28, 2026 in both languages. These source edits were uncommitted during the initial review. The final
publication import uses Pool commit `6c3b90aa21b37d2c493003d42ffaa08fa454a04e`. The source
files imported in this refresh have these SHA-256 hashes:

| Pool source | SHA-256 |
| --- | --- |
| `README.md` | `044933dddb6f5181405945c92581767b9c248a08d240596969fe733085b4ca46` |
| `about.md` | `7a1318a795f61875bd90bd444a42256b240f71ffbe5def3823fa67d5ce17fe5a` |
| `terms.md` | `af92bff2020dcfe1dfd1933e556908423eaebd655fe17fca862cbba701db489e` |
| `es/about.md` | `988bed151b3bed742c76ee5723c1f850c70f6f2e4ba58ee24778b585be3a47ec` |
| `es/terms.md` | `73ab4b224c617a64428c5620a0f357ad56d5e95c65dfcbdcf516462ff4aa3b51` |

## Translation review

`reviewed_spanish_docs.json` stores 77 reviewed translation units, including
recent release notes, payment setup and reservation release, tax coverage, age
encryption, archive verification, and FAQ copy. Reviewed translations override
cached machine output. Wrapped list items are joined only when an exact reviewed
translation exists; nested items and fenced code remain separate. About and
Terms use Pool's curated Spanish sources. Shorter Spanish navigation labels
resolve the header overlap observed in the narrow local preview.

## Validation

- Ruby importer: syntax check and 5 tests / 29 assertions passed.
- Spanish generator: 9 tests passed, including reviewed-cache precedence,
  inline code preservation, wrapped lists, nested items, and fenced code.
- Full English/Spanish regeneration produced identical files with translation
  service calls disabled.
- Marketing/docs Jekyll build passed; current-state, internal-link (87 HTML
  pages), SEO, and live-support-link configuration audits passed.
- Pool Jekyll build passed in a separate temporary output directory. Both
  languages rendered the revised About/Terms copy and dates, resolved operator
  and support variables, and preserved shipping/refund anchors.
- Local browser review confirmed the homepage in both languages, language-aware
  links, corrected Spanish header spacing, and the English FAQ rendering.
- Both repositories passed `git diff --check`; pre-existing untracked files
  were left untouched.

This records local documentation and build verification before publication.
At that stage, no commit, push, production deployment, provider backup run,
payment, or supporter communication had been performed. Publication verification
is separate from these local checks.

## Pre-publication release checks

The final Pool source commit `6c3b90aa21b37d2c493003d42ffaa08fa454a04e`
passed the complete pre-merge gate in an isolated checkout: 1,205 unit tests
passed with one skipped, 127 security tests passed, 178 browser tests passed
with three skipped, and both Worker and mutable-pledge smoke checks passed.
Root and Worker dependency audits passed for production and full scopes with
zero findings. The final marketing build passed all 14 generator tests and the
current-state, internal-link, SEO, and support audits.

The first local attempt stopped because the configuration sync copied a local
Stripe publishable test key into Wrangler config, which the secret scanner
classified as a local secret. That generated change was restored. The isolated
checkout used test-only configuration; its temporary dependency links were
replaced with local copies so Podman could mount them. The final complete run
passed without changing application code, credentials, or the development
checkout's configuration.
