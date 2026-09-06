# Maintain the Marketing and Documentation Site

This repository publishes The Pool's marketing pages and developer docs with
Jekyll and `just-the-docs`. Pool owns product behavior and imported procedures.
This directory owns the website's maintenance workflow and is excluded from
Jekyll output and Spanish page generation.

## Documentation Ownership

- Root `README.md` is the contributor entry point; `LICENSE` remains at root.
- Root `index.md`, `support.md`, and `confirmation.md` are Jekyll page sources.
  Keep their public URLs, layouts, and localization behavior intact.
- `docs/overview`, `docs/development`, `docs/operations`, and `docs/reference`
  contain published English pages. `es/docs` contains their Spanish counterparts.
- `scripts/sync_pool_docs.rb` owns the imported-page manifest and source map.
  Change Pool's owning guide first, then regenerate imported pages here.
- Section indexes, the FAQ, and the three legacy migration pages are maintained
  here. Update their reading paths when upstream ownership changes.
- [Site roadmap](roadmap.md) contains prospective work for this repository.
  [Support design QA](release-evidence/2026-08-25-support-design-qa.md) is dated
  evidence, not a current operational guide.

## Import From Pool

Both generators default to the sibling `../pool` checkout. An explicit
`POOL_SOURCE` overrides it; use the same checkout for both languages. Inspect
its status and revision before importing. The Source Map records its HEAD;
commit or otherwise review any source edits before treating that revision as
reproducible provenance.

```bash
export POOL_SOURCE=/path/to/pool
git -C "$POOL_SOURCE" status --short --branch
git -C "$POOL_SOURCE" log -1 --oneline
ruby scripts/sync_pool_docs.rb
python3 scripts/build_spanish_docs.py
```

The Spanish generator requires Python packages `requests` and `PyYAML`
(run `python3 -m pip install -r scripts/requirements-docs-i18n.txt` in an
activated virtual environment).
It joins wrapped prose into complete paragraphs while preserving lists and code
blocks. It reuses committed translations and an ignored local translation cache, then
uses the configured translation service for changed prose. About and Terms
come from Pool's curated Spanish sources; missing sources fail explicitly.
Review changed translations and code examples before publication.

`POOL_DOCS=docs/ARCHITECTURE.md` selects English sources for a focused import;
`POOL_TRANSLATION_FILES=development/architecture.md` selects Spanish pages.
Run a full sync before publication to refresh the Source Map and source revision.
The manifest validates all active
sources before writing any page. Source-file links resolve to imported routes
where available and to the real Pool repository otherwise. The upstream
`docs/README.md` links to the site's maintained Development index.

Pool's Campaign Creator Checklist and release evidence remain in the source
repository. The retired Project Overview, Workflows, and Developer Notes URLs
contain short links to their current owning guides, without copied procedures.

## Preview and Validate

```bash
bundle install
ruby -c scripts/sync_pool_docs.rb
ruby scripts/test_sync_pool_docs.rb
python3 scripts/test_build_spanish_docs.py
bundle exec jekyll build --trace
python3 scripts/audit_docs_current_state.py
python3 scripts/audit_links.py
python3 scripts/audit_seo.py
python3 scripts/audit_support.py
bundle exec jekyll serve
```

The documentation audit checks locale parity and confirms that maintainer
notes and tooling stay out of the built site. Review the rendered navigation,
new guides, legacy URLs, language switcher, and public entry pages.

CI validates committed English and Spanish pages. It does not fetch live Pool
`main` or call translation services. Pushes to this repository's `main` run the
Pages deployment workflow; local validation alone does not establish deployment.

## Dust Wave Support contract

`_data/support.yml` is the single source for the support brand and checkout options. The support page renders that data with `_includes/support-options.html`, keeping provider configuration separate from The Pool's visual presentation. The contract intentionally supports one customer-chosen one-time amount (suggested at $10) and one fixed $5/month option.

`scripts/audit_support.py` validates the built page, UTM attribution, two required cadences, and direct Stripe-hosted checkout links. Production validation rejects Stripe test links. During a deliberate test-mode preview, use:

```bash
SUPPORT_ALLOW_TEST_LINKS=1 python3 scripts/audit_support.py
```

When checkout resources change, create and verify the replacement Product, Prices, and Payment Links first; then update `_data/support.yml` in a coordinated release. Do not archive an old recurring Price or Product while existing subscriptions still depend on it.
