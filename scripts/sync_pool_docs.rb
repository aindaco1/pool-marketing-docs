#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "pathname"
require "open3"
require "set"
require "shellwords"

ROOT = Pathname(__dir__).join("..").expand_path
POOL_ROOT = Pathname(ENV.fetch("POOL_SOURCE", ROOT.join("../pool").to_s)).expand_path
POOL_REPO = ENV.fetch("POOL_REPO", "aindaco1/pool")
POOL_BLOB_BASE = "https://github.com/#{POOL_REPO}/blob/main/"
POOL_TREE_BASE = "https://github.com/#{POOL_REPO}/tree/main/"
SOURCE_MAP_DEST = "docs/reference/source-map.md"
METADATA_ONLY_COMMIT_SUBJECTS = [
  "Update docs changelog and date stamps",
  "Fix docs last updated stamps"
].freeze

# This manifest is the canonical source-to-destination contract. Link aliases,
# generated navigation metadata, validation, and the public source map all
# derive from it.
DOCS = [
  { src: "about.md", dest: "docs/overview/about-the-pool.md", title: "About The Pool", parent: "Overview", nav_order: 1 },
  { src: "terms.md", dest: "docs/overview/terms-and-guidelines.md", title: "Terms & Creative Guidelines", parent: "Overview", nav_order: 2 },
  { src: "docs/CONTRIBUTING.md", dest: "docs/development/contributing.md", title: "Contributing", parent: "Development", nav_order: 1 },
  { src: "docs/ARCHITECTURE.md", dest: "docs/development/architecture.md", title: "Architecture", parent: "Development", nav_order: 2 },
  { src: "docs/CONTENT_MODEL.md", dest: "docs/development/content-model.md", title: "Campaign Content Model", parent: "Development", nav_order: 3 },
  { src: "docs/CUSTOMIZATION.md", dest: "docs/development/customization-guide.md", title: "Customization Guide", parent: "Development", nav_order: 5 },
  { src: "docs/I18N.md", dest: "docs/development/internationalization.md", title: "Internationalization", parent: "Development", nav_order: 6 },
  { src: "docs/EMBEDS.md", dest: "docs/development/campaign-embeds.md", title: "Campaign Embeds", parent: "Development", nav_order: 7 },
  { src: "docs/ADD_ON_PRODUCTS.md", dest: "docs/development/add-on-products.md", title: "Add-On Products", parent: "Development", nav_order: 8 },
  { src: "docs/PRODUCT_VIDEO_WORKFLOW.md", dest: "docs/development/product-video-workflow.md", title: "Product Video Workflow", parent: "Development", nav_order: 9 },
  { src: "AGENTS.md", dest: "docs/development/agents-operator-guide.md", title: "Agents & Operator Guide", parent: "Development", nav_order: 10 },
  { src: "README.md", dest: "docs/development/platform-readme.md", title: "Platform README", parent: "Development", nav_order: 11 },
  { src: "docs/ETHICAL_RISK.md", dest: "docs/development/ethical-risk-review.md", title: "Ethical Risk Review", parent: "Development", nav_order: 12 },
  { src: "docs/DASHBOARD.md", dest: "docs/operations/admin-dashboard.md", title: "Admin Dashboard", parent: "Operations", nav_order: 1 },
  { src: "worker/README.md", dest: "docs/operations/worker.md", title: "Pledge Worker", parent: "Operations", nav_order: 2 },
  { src: "docs/PAYMENT_PROCESSOR.md", dest: "docs/operations/payment-processor.md", title: "Payment Processor", parent: "Operations", nav_order: 3 },
  { src: "docs/EMAIL.md", dest: "docs/operations/email-system.md", title: "Email System", parent: "Operations", nav_order: 4 },
  { src: "docs/PODMAN.md", dest: "docs/operations/podman-local-dev.md", title: "Podman Local Dev", parent: "Operations", nav_order: 5 },
  { src: "docs/TESTING.md", dest: "docs/operations/testing.md", title: "Testing Guide", parent: "Operations", nav_order: 6 },
  { src: "docs/MERGE_SMOKE_CHECKLIST.md", dest: "docs/operations/merge-smoke-checklist.md", title: "Merge Smoke Checklist", parent: "Operations", nav_order: 7 },
  { src: "docs/SECURITY.md", dest: "docs/operations/security.md", title: "Security Guide", parent: "Operations", nav_order: 8 },
  { src: "tests/security/README.md", dest: "docs/operations/security-test-suite.md", title: "Security Test Suite", parent: "Operations", nav_order: 9 },
  { src: "docs/BACKUP_RESTORE.md", dest: "docs/operations/backup-restore.md", title: "Backup, Restore, and Recovery", parent: "Operations", nav_order: 10 },
  { src: "docs/SHIPPING.md", dest: "docs/operations/shipping.md", title: "Shipping", parent: "Operations", nav_order: 11 },
  { src: "docs/TAX_CALCULATOR.md", dest: "docs/operations/tax-calculator.md", title: "Tax Calculator", parent: "Operations", nav_order: 12 },
  { src: "docs/ACCESSIBILITY.md", dest: "docs/operations/accessibility.md", title: "Accessibility", parent: "Operations", nav_order: 13 },
  { src: "docs/SEO.md", dest: "docs/operations/seo.md", title: "SEO", parent: "Operations", nav_order: 14 },
  { src: "docs/PERFORMANCE.md", dest: "docs/operations/performance.md", title: "Performance", parent: "Operations", nav_order: 15 },
  { src: "docs/DEPLOYMENT.md", dest: "docs/operations/deployment.md", title: "Deployment", parent: "Operations", nav_order: 16 },
  { src: "docs/WORKER_API.md", dest: "docs/reference/worker-api.md", title: "Worker API", parent: "Reference", nav_order: 5 },
  { src: "CHANGELOG.md", dest: "docs/reference/changelog.md", title: "Changelog", parent: "Reference", nav_order: 1 },
  { src: "docs/ROADMAP.md", dest: "docs/reference/roadmap.md", title: "Roadmap", parent: "Reference", nav_order: 2 },
  { src: "docs/PULL_REQUEST_TEMPLATE.md", dest: "docs/reference/pull-request-template.md", title: "Pull Request Template", parent: "Reference", nav_order: 3 }
].freeze

SELECTED_DOC_SOURCES = ENV.fetch("POOL_DOCS", "")
  .split(",")
  .map(&:strip)
  .reject(&:empty?)
  .to_set

ALIASES = {
  "docs/README.md" => "/docs/development/",
  "docs/" => "/docs/",
  "./docs/" => "/docs/",
  "es/about.md" => "/docs/overview/about-the-pool/",
  "es/terms.md" => "/docs/overview/terms-and-guidelines/",
  "robots.txt" => "/robots.txt",
  "sitemap.xml" => "/sitemap.xml"
}.freeze

DESTINATIONS = DOCS.each_with_object(ALIASES.dup) do |doc, memo|
  memo[doc[:src]] = "/" + doc[:dest].sub(/\.md$/, "/")
end.freeze

def strip_front_matter(content)
  return content unless content.start_with?("---\n")

  lines = content.lines
  closing_index = lines[1..].find_index { |line| line.strip == "---" }
  return content unless closing_index

  lines[(closing_index + 2)..].join
end

def external_target?(raw_target)
  raw_target.start_with?("http://", "https://", "#", "mailto:", "tel:")
end

def split_target(raw_target)
  match = raw_target.match(/\A([^?#]+)([?#].*)?\z/)
  return [raw_target, ""] unless match

  [match[1], match[2] || ""]
end

def repo_url_for(path)
  source_path = POOL_ROOT.join(path)
  return "#{POOL_TREE_BASE}#{path}" if source_path.directory?
  return "#{POOL_BLOB_BASE}#{path}" if source_path.file?

  nil
end

def normalize_link(current_src, raw_target)
  return raw_target if external_target?(raw_target)

  path, suffix = split_target(raw_target)
  return "/docs/#{suffix}" if path == "docs/" || path == "./docs/"

  current_dir = Pathname(current_src).dirname
  normalized = current_dir.join(path).cleanpath.to_s.sub(%r{\A\./}, "")
  replacement = DESTINATIONS[normalized] || repo_url_for(normalized)
  return raw_target unless replacement

  replacement + suffix
end

def rewrite_links(content, current_src)
  content.gsub(/\]\(([^)]+)\)/) do |match|
    target = Regexp.last_match(1)
    replacement = normalize_link(current_src, target)
    match.sub("(#{target})", "(#{replacement})")
  end
end

def format_english_date(date)
  date.strftime("%B %-d, %Y")
end

def remove_last_updated(content)
  content.gsub(/\n## Last Updated\n\n[^\n]+(?:\n{2,}|\z)/, "\n")
end

def normalized_content(content)
  remove_last_updated(content)
    .lines
    .map(&:rstrip)
    .join("\n")
    .strip
end

def existing_last_updated_for(target_path)
  return nil unless target_path.file?

  date_string = strip_front_matter(target_path.read)[/^## Last Updated\s*\n\s*([^\n]+)\s*$/m, 1]
  return nil unless date_string

  Date.strptime(date_string.strip, "%B %d, %Y")
rescue Date::Error
  nil
end

def last_changed_date_for(target_path)
  relative_path = target_path.relative_path_from(ROOT).to_s
  log = Dir.chdir(ROOT) do
    `git log --format=%H%x09%cs%x09%s -- #{relative_path.shellescape} 2>/dev/null`
  end

  log.each_line do |line|
    _sha, date_string, subject = line.chomp.split("\t", 3)
    next if METADATA_ONLY_COMMIT_SUBJECTS.include?(subject)

    return Date.iso8601(date_string)
  end

  Date.today
end

def content_changed?(target_path, generated_content)
  return true unless target_path.file?

  existing_content = strip_front_matter(target_path.read)
  normalized_content(existing_content) != normalized_content(generated_content)
end

def last_updated_for(target_path, generated_content)
  return Date.today if content_changed?(target_path, generated_content)
  existing_last_updated = existing_last_updated_for(target_path)
  return existing_last_updated if existing_last_updated

  last_changed_date_for(target_path)
end

def stamp_last_updated(content, last_updated)
  lines = remove_last_updated(content).lines
  h1_index = lines.find_index { |line| line.start_with?("# ") }
  return lines.join unless h1_index

  insert_index = h1_index + 1
  lines.delete_at(insert_index) while lines[insert_index]&.strip == ""

  stamp = ["\n", "## Last Updated\n", "\n", "#{format_english_date(last_updated)}\n", "\n"]
  lines.insert(insert_index, *stamp)

  lines.join.gsub(/(\d{4}\n)\n{2,}(?=## )/, "\\1\n")
end

GENERIC_REPLACEMENTS = [
  ["https://pool.dustwave.xyz", "https://site.example.com"],
  ["https://pledge.dustwave.xyz", "https://worker.example.com"],
  ["https://shop.dustwave.xyz/", "https://shop.example.com/"],
  ["https://shop.dustwave.xyz", "https://shop.example.com"],
  ["pool.dustwave.xyz", "site.example.com"],
  ["pledge.dustwave.xyz", "worker.example.com"],
  ["shop.dustwave.xyz", "shop.example.com"],
  ["info@dustwave.xyz", "support@example.com"],
  ["alonso@dustwave.xyz", "security@example.com"],
  ["pledges@dustwave.xyz", "pledges@example.com"],
  ["dustwave.xyz", "example.com"],
  ["aindaco1/pool", "your-org/your-project"],
  ["Dust Wave shop", "your merch store"],
  ["The Pool Dev", "Project Dev"],
  ["Test from The Pool", "Test from your deployment"],
  ["Dust Wave platform tip", "platform tip"],
  ["Dust Wave tip", "platform tip"]
].freeze

def rewrite_copy(content, current_src)
  source_links = []
  rewritten = content.gsub(%r{https://github\.com/#{Regexp.escape(POOL_REPO)}[^\s)\]]*}) do |url|
    source_links << url
    "POOL_SOURCE_LINK_#{source_links.length - 1}_END"
  end

  GENERIC_REPLACEMENTS.each do |from, to|
    rewritten.gsub!(from, to)
  end

  local_only_file_references = [
    "[`_config.local.yml`](../_config.local.yml)",
    "[`_config.local.yml`](_config.local.yml)",
    "[`worker/.dev.vars`](../worker/.dev.vars)",
    "[`worker/.dev.vars`](worker/.dev.vars)"
  ]

  local_only_file_references.each do |reference|
    label = reference[/\[`([^`]+)`\]/, 1]
    rewritten.gsub!(reference, "`#{label}`")
  end

  rewritten.gsub!(/^\s*_Last updated:\s+.*?_\s*$\n?/i, "")

  case current_src
  when "README.md"
    rewritten.sub!(
      /\*\*Dust Wave's open-source crowdfunding platform\*\* — \[site\.example\.com\]\(https:\/\/site\.example\.com\)\n\n/,
      "**Open-source crowdfunding platform starter**\n\n"
    )
    rewritten.gsub!(/\n\*🄯 Dust Wave\*\n/, "\n")
    rewritten.gsub!("*🄯 Dust Wave*", "")
    rewritten.gsub!(/^\*🄯 Dust Wave\*$/m, "")
  when "about.md"
    rewritten.gsub!(/^\{% assign .+? %\}\n?/, "")
    rewritten.gsub!("**The Pool** is {{ operator_name }}'s", "**The Pool** is an")
    rewritten.gsub!("help {{ operator_name }} operate the service", "help operate the service")
    rewritten.gsub!("{{ operator_name }}", "the platform operator")
    rewritten.gsub!(
      "{% include localized-url.html lang=page.lang translation_key='terms' %}#returns-refunds",
      "/docs/overview/terms-and-guidelines/#returns-refunds"
    )
    rewritten.gsub!(
      "{% include localized-url.html lang=page.lang translation_key='terms' %}#shipping-policy",
      "/docs/overview/terms-and-guidelines/#shipping-policy"
    )
    rewritten.gsub!("[{{ support_email }}](mailto:{{ support_email }})", "[support@example.com](mailto:support@example.com)")
    rewritten.gsub!(
      "[github.com/your-org/your-project](https://github.com/your-org/your-project)",
      "[github.com/aindaco1/pool](https://github.com/aindaco1/pool)"
    )
  when "terms.md"
    rewritten.gsub!(/^\{% assign .+? %\}\n?/, "")
    rewritten.gsub!("{{ operator_name }}", "the platform operator")
    rewritten.gsub!("[{{ support_email }}](mailto:{{ support_email }})", "[support@example.com](mailto:support@example.com)")
    rewritten.gsub!(
      "[GitHub repository](https://github.com/your-org/your-project)",
      "[GitHub repository](https://github.com/aindaco1/pool)"
    )
  when "CHANGELOG.md"
    rewritten.gsub!(/^- Updated release metadata to `[^`]+`\.\n/, "")
  when "docs/CUSTOMIZATION.md", "docs/SEO.md"
    rewritten.gsub!('  default_social_image_alt: "Dust Wave on The Pool"', '  default_social_image_alt: "Social card for your deployment"')
  when "docs/PULL_REQUEST_TEMPLATE.md"
    rewritten.sub!(/\n## Rollback Plan\n<!-- How to revert safely if needed -->\n?\z/, "\n")
  when "docs/TESTING.md"
    rewritten.gsub!("2. Add `example.com`", "2. Add your verified sending domain")
    rewritten.gsub!("- [ ] Verify `example.com` domain in Resend", "- [ ] Verify your sending domain in Resend")
    rewritten.gsub!("- **Domain**: Verify `example.com` for sending from `pledges@example.com`", "- **Domain**: Verify your sending domain for the configured transactional sender")
  when "docs/CONTRIBUTING.md"
    rewritten.gsub!("2. Add CNAME file: `site.example.com`", "2. Add a `CNAME` file for your public site domain")
    rewritten.gsub!("- [ ] Verify `CNAME` is set to `site.example.com`", "- [ ] Verify `CNAME` is set to your public site domain")
    rewritten.gsub!("| **Dust Wave** | Company name (two words, not \"DustWave\") |", "| **Platform operator** | Company or studio name for your deployment |")
  when "docs/ADD_ON_PRODUCTS.md"
    rewritten.gsub!("## Initial Dust Wave Import", "## Initial Merch Import")
    rewritten.gsub!("The current first-wave catalog is based on the live your merch store at [shop.example.com](https://shop.example.com/):", "The current first-wave catalog is shown as an example merch import from [shop.example.com](https://shop.example.com/):")
  when "docs/SECURITY.md"
    rewritten.gsub!(/^- \*\*Primary:\*\* \[security@example\.com\]\n/, "")
  end

  source_links.each_with_index { |url, index| rewritten.gsub!("POOL_SOURCE_LINK_#{index}_END", url) }
  rewritten.gsub!("[github.com/your-org/your-project](https://github.com/#{POOL_REPO})", "[github.com/#{POOL_REPO}](https://github.com/#{POOL_REPO})")
  rewritten.gsub!(/[ \t]+$/, "")
  rewritten
end

def front_matter_for(doc)
  <<~YAML
    ---
    title: #{doc[:title].dump}
    parent: #{doc[:parent].dump}
    nav_order: #{doc[:nav_order]}
    render_with_liquid: false
    ---

  YAML
end

def write_generated_page(target_path, front_matter, content)
  content = stamp_last_updated(content.strip, last_updated_for(target_path, content))
  FileUtils.mkdir_p(target_path.dirname)
  target_path.write(front_matter + content + "\n")
  puts "Wrote #{target_path.relative_path_from(ROOT)}"
end

def validate_manifest!
  errors = []
  errors << "Pool source directory does not exist: #{POOL_ROOT}" unless POOL_ROOT.directory?

  sources = DOCS.map { |doc| doc[:src] }
  destinations = DOCS.map { |doc| doc[:dest] }
  nav_positions = DOCS.map { |doc| [doc[:parent], doc[:nav_order]] }

  sources.tally.each { |value, count| errors << "Duplicate source: #{value}" if count > 1 }
  destinations.tally.each { |value, count| errors << "Duplicate destination: #{value}" if count > 1 }
  nav_positions.tally.each { |value, count| errors << "Duplicate navigation position: #{value.join(' / ')}" if count > 1 }

  unknown_selected = SELECTED_DOC_SOURCES - sources.to_set
  unknown_selected.each { |source| errors << "Unknown POOL_DOCS source: #{source}" }

  active_docs = SELECTED_DOC_SOURCES.empty? ? DOCS : DOCS.select { |doc| SELECTED_DOC_SOURCES.include?(doc[:src]) }
  active_docs.each do |doc|
    errors << "Missing source file: #{POOL_ROOT.join(doc[:src])}" unless POOL_ROOT.join(doc[:src]).file?
    destination = Pathname(doc[:dest])
    errors << "Unsafe destination: #{doc[:dest]}" if destination.absolute? || destination.each_filename.include?("..")
    errors << "Destination must be Markdown: #{doc[:dest]}" unless destination.extname == ".md"
  end

  abort("Pool documentation sync cannot continue:\n- #{errors.join("\n- ")}") unless errors.empty?
end

def source_map_body
  revision, status = Open3.capture2("git", "-C", POOL_ROOT.to_s, "rev-parse", "HEAD", err: File::NULL)
  provenance = if status.success?
    dirty, = Open3.capture2("git", "-C", POOL_ROOT.to_s, "status", "--porcelain", "--", *DOCS.map { |doc| doc[:src] }, "es/about.md", "es/terms.md")
    note = dirty.empty? ? "" : " The source checkout includes uncommitted documentation edits; this revision is the baseline, not the complete imported snapshot."
    "Imported from Pool revision [`#{revision.strip[0, 12]}`](https://github.com/#{POOL_REPO}/commit/#{revision.strip}).#{note}"
  else
    "Imported from a local Pool source directory without Git revision metadata."
  end
  rows = DOCS.map do |doc|
    source = "[`#{doc[:src]}`](#{POOL_BLOB_BASE}#{doc[:src]})"
    route = "/" + doc[:dest].sub(/\.md$/, "/")
    destination = "[#{doc[:title]}](#{route})"
    "| #{source} | #{destination} | #{doc[:parent]} |"
  end

  <<~MARKDOWN
    # Source Map

    The Pool repository is the canonical source for imported product and
    developer documentation. This page is generated from the same manifest the
    sync script uses for validation, link rewriting, navigation metadata, and
    output paths.

    #{provenance}

    The [Development index](/docs/development/) follows the ownership and task
    paths in Pool's [documentation index](#{POOL_BLOB_BASE}docs/README.md).
    Architecture owns system relationships and lifecycle; Campaign Content Model
    owns authoring fields; Worker API owns endpoint contracts; Deployment owns
    release wiring. Detailed procedures stay in their owning guide.

    | Pool source | Marketing documentation | Section |
    | --- | --- | --- |
    #{rows.join("\n")}

    ## Regenerate Documentation

    ```bash
    export POOL_SOURCE=/path/to/pool
    ruby scripts/sync_pool_docs.rb
    python3 scripts/build_spanish_docs.py
    ```

    The Campaign Creator Checklist remains a Pool-owned public route and is not
    duplicated into this developer documentation tree. Release evidence stays in
    Pool's [release-evidence directory](#{POOL_TREE_BASE}docs/release-evidence/).

    Project Overview, Workflows, and Developer Notes retain their old URLs as
    short migration pages. They no longer duplicate the current guides.

  MARKDOWN
end

def sync_docs!
  validate_manifest!

  active_docs = SELECTED_DOC_SOURCES.empty? ? DOCS : DOCS.select { |doc| SELECTED_DOC_SOURCES.include?(doc[:src]) }
  active_docs.each do |doc|
    source_path = POOL_ROOT.join(doc[:src])
    target_path = ROOT.join(doc[:dest])
    content = strip_front_matter(source_path.read)
    content = rewrite_copy(content, doc[:src])
    content = rewrite_links(content, doc[:src])
    write_generated_page(target_path, front_matter_for(doc), content)
  end

  if SELECTED_DOC_SOURCES.empty?
    source_map = {
      title: "Source Map",
      parent: "Reference",
      nav_order: 4
    }
    write_generated_page(ROOT.join(SOURCE_MAP_DEST), front_matter_for(source_map), source_map_body)
  end
end

sync_docs! if $PROGRAM_NAME == __FILE__
