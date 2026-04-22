# pool-marketing-docs

Marketing site and developer docs for The Pool, built with Jekyll and `just-the-docs`.

## Local preview

```bash
bundle install
POOL_SOURCE=/path/to/pool ruby scripts/sync_pool_docs.rb
bundle exec jekyll serve
```

The imported docs source comes from the Pool repository at `/tmp/pool` by default. Set `POOL_SOURCE=/path/to/pool` if you want to sync from a different checkout.
