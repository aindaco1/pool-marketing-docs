# pool-marketing-docs

Marketing site and developer docs for The Pool, built with Jekyll and `just-the-docs`.

## Local Preview

```bash
bundle install
bundle exec jekyll serve
```

The committed English and Spanish docs are sufficient for a local build.
To refresh product documentation, both generators default to the sibling
`../pool` checkout:

```bash
export POOL_SOURCE=/path/to/pool
ruby scripts/sync_pool_docs.rb
python3 scripts/build_spanish_docs.py
```

See the [maintenance guide](docs/maintainers/README.md) for dependencies,
source ownership, import and translation behavior, validation, and the support
checkout contract. The [site roadmap](docs/maintainers/roadmap.md) tracks
prospective website work; the [public docs index](docs/index.md) introduces Pool.
