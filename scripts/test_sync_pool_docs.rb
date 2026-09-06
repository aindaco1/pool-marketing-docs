#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "sync_pool_docs"

class PoolDocsSyncTest < Minitest::Test
  def with_fixture
    Dir.mktmpdir("pool-docs-sync") do |directory|
      root = Pathname(directory).join("site")
      pool = Pathname(directory).join("pool")
      FileUtils.mkdir_p(root.join("scripts"))
      FileUtils.cp(ROOT.join("scripts/sync_pool_docs.rb"), root.join("scripts"))
      DOCS.each do |doc|
        source = pool.join(doc[:src])
        FileUtils.mkdir_p(source.dirname)
        source.write("# #{doc[:title]}\n\nFixture content.\n")
      end
      yield root, pool
    end
  end

  def run_sync(root, source = nil)
    Open3.capture3(
      { "POOL_SOURCE" => source&.to_s, "POOL_DOCS" => nil },
      RbConfig.ruby, root.join("scripts/sync_pool_docs.rb").to_s
    )
  end

  def test_full_import_uses_sibling_source_and_is_repeatable
    with_fixture do |root, pool|
      pool.join("docs/ARCHITECTURE.md").write(<<~MARKDOWN)
        # Architecture

        [Fields](CONTENT_MODEL.md#campaign-fields)
        [Routes](WORKER_API.md#routes)
        [Releases](DEPLOYMENT.md)
        [Index](README.md)
        [Source](https://github.com/aindaco1/pool/blob/main/worker/src/index.js)

        Clone `aindaco1/pool` for `https://pool.dustwave.xyz`.
      MARKDOWN
      pool.join("worker/src").mkpath
      pool.join("worker/src/index.js").write("// fixture\n")
      pool.join("worker/README.md").write("# Worker\n\n[Source](src/index.js)\n")
      _out, err, status = run_sync(root)
      assert status.success?, err
      page = root.join("docs/development/architecture.md").read
      assert_includes page, "](/docs/development/content-model/#campaign-fields)"
      assert_includes page, "](/docs/reference/worker-api/#routes)"
      assert_includes page, "](/docs/operations/deployment/)"
      assert_includes page, "](/docs/development/)"
      assert_includes page, "https://github.com/aindaco1/pool/blob/main/worker/src/index.js"
      assert_includes page, "Clone `your-org/your-project` for `https://site.example.com`"
      assert_includes root.join("docs/operations/worker.md").read, "https://github.com/aindaco1/pool/blob/main/worker/src/index.js"
      assert_includes root.join(SOURCE_MAP_DEST).read, "docs/WORKER_API.md"
      before = root.glob("docs/**/*.md").to_h { |path| [path.to_s, path.read] }
      _out, err, status = run_sync(root)
      assert status.success?, err
      assert_equal before, root.glob("docs/**/*.md").to_h { |path| [path.to_s, path.read] }
    end
  end

  def test_many_source_urls_are_preserved_without_placeholder_collisions
    links = 12.times.map { |number| "https://github.com/aindaco1/pool/blob/main/file#{number}.md" }
    content = links.map { |url| "[Source](#{url})" }.join("\n")
    assert_equal content, rewrite_copy(content, "README.md")
  end

  def test_missing_source_fails_before_any_writes
    with_fixture do |root, pool|
      pool.join("docs/WORKER_API.md").delete
      _out, err, status = run_sync(root, pool)
      refute status.success?
      assert_includes err, "Missing source file:"
      assert_empty root.glob("docs/**/*.md")
    end
  end

  def test_explicit_source_overrides_default
    with_fixture do |root, pool|
      moved = pool.sub_ext("-selected")
      FileUtils.mv(pool, moved)
      _out, err, status = run_sync(root, moved)
      assert status.success?, err
      assert root.join("docs/development/architecture.md").file?
    end
  end

  def test_curated_pages_are_not_overwritten
    with_fixture do |root, pool|
      curated = root.join("docs/development/workflows.md")
      curated.dirname.mkpath
      curated.write("# Follow the new guides\n")
      _out, err, status = run_sync(root, pool)
      assert status.success?, err
      assert_equal "# Follow the new guides\n", curated.read
    end
  end
end
