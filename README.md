# pool-marketing-docs

Marketing site and developer docs for The Pool, built with Jekyll and `just-the-docs`.

## Local preview

```bash
bundle install
POOL_SOURCE=/path/to/pool ruby scripts/sync_pool_docs.rb
python3 scripts/build_spanish_docs.py
bundle exec jekyll serve
```

The imported docs source comes from the Pool repository at `/tmp/pool` by default. Set `POOL_SOURCE=/path/to/pool` if you want to sync from a different checkout.

The sync manifest in `scripts/sync_pool_docs.rb` is the canonical imported-page contract. It validates sources and destinations, rewrites source links, assigns navigation metadata, and generates the public Source Map. The Campaign Creator Checklist remains a Pool-owned public route rather than a duplicated developer-docs page.

## Validation

```bash
ruby -c scripts/sync_pool_docs.rb
bundle exec jekyll build --trace
python3 scripts/audit_docs_current_state.py
python3 scripts/audit_links.py
python3 scripts/audit_seo.py
python3 scripts/audit_support.py
```

These checks validate the committed English and Spanish documentation. CI does not fetch live Pool `main`, so a Pool documentation change cannot unexpectedly block this site's deployment before an intentional sync.

## Dust Wave Support contract

`_data/support.yml` is the single source for the support brand and checkout options. The support page renders that data with `_includes/support-options.html`, keeping provider configuration separate from The Pool's visual presentation. The contract intentionally supports one customer-chosen one-time amount (suggested at $10) and one fixed $5/month option.

`scripts/audit_support.py` validates the built page, UTM attribution, two required cadences, and direct Stripe-hosted checkout links. Production validation rejects Stripe test links. During a deliberate test-mode preview, use:

```bash
SUPPORT_ALLOW_TEST_LINKS=1 python3 scripts/audit_support.py
```

When checkout resources change, create and verify the replacement Product, Prices, and Payment Links first; then update `_data/support.yml` in a coordinated release. Do not archive an old recurring Price or Product while existing subscriptions still depend on it.
