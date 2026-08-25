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
```

These checks validate the committed English and Spanish documentation. CI does not fetch live Pool `main`, so a Pool documentation change cannot unexpectedly block this site's deployment before an intentional sync.
