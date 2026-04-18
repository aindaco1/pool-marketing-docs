#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "pathname"

ROOT = Pathname(__dir__).join("..").expand_path
POOL_ROOT = Pathname(ENV.fetch("POOL_SOURCE", "/tmp/pool")).expand_path
POOL_REPO = ENV.fetch("POOL_REPO", "aindaco1/pool")
POOL_BLOB_BASE = "https://github.com/#{POOL_REPO}/blob/main/"
POOL_TREE_BASE = "https://github.com/#{POOL_REPO}/tree/main/"

DOCS = [
  { src: "README.md", dest: "docs/overview/platform.md", title: "Platform Overview", parent: "Overview", nav_order: 1 },
  { src: "about.md", dest: "docs/overview/about-the-pool.md", title: "About The Pool", parent: "Overview", nav_order: 2 },
  { src: "terms.md", dest: "docs/overview/terms-and-guidelines.md", title: "Terms & Creative Guidelines", parent: "Overview", nav_order: 3 },
  { src: "docs/CONTRIBUTING.md", dest: "docs/development/contributing.md", title: "Contributing", parent: "Development", nav_order: 1 },
  { src: "docs/PROJECT_OVERVIEW.md", dest: "docs/development/project-overview.md", title: "Project Overview", parent: "Development", nav_order: 2 },
  { src: "docs/WORKFLOWS.md", dest: "docs/development/workflows.md", title: "Workflows", parent: "Development", nav_order: 3 },
  { src: "docs/DEV_NOTES.md", dest: "docs/development/developer-notes.md", title: "Developer Notes", parent: "Development", nav_order: 4 },
  { src: "docs/CUSTOMIZATION.md", dest: "docs/development/customization-guide.md", title: "Customization Guide", parent: "Development", nav_order: 5 },
  { src: "docs/I18N.md", dest: "docs/development/internationalization.md", title: "Internationalization", parent: "Development", nav_order: 6 },
  { src: "docs/EMBEDS.md", dest: "docs/development/campaign-embeds.md", title: "Campaign Embeds", parent: "Development", nav_order: 7 },
  { src: "docs/ADD_ON_PRODUCTS.md", dest: "docs/development/add-on-products.md", title: "Add-On Products", parent: "Development", nav_order: 8 },
  { src: "worker/README.md", dest: "docs/operations/worker.md", title: "Pledge Worker", parent: "Operations", nav_order: 1 },
  { src: "docs/PODMAN.md", dest: "docs/operations/podman-local-dev.md", title: "Podman Local Dev", parent: "Operations", nav_order: 2 },
  { src: "docs/TESTING.md", dest: "docs/operations/testing.md", title: "Testing Guide", parent: "Operations", nav_order: 3 },
  { src: "docs/MERGE_SMOKE_CHECKLIST.md", dest: "docs/operations/merge-smoke-checklist.md", title: "Merge Smoke Checklist", parent: "Operations", nav_order: 4 },
  { src: "docs/SECURITY.md", dest: "docs/operations/security.md", title: "Security Guide", parent: "Operations", nav_order: 5 },
  { src: "tests/security/README.md", dest: "docs/operations/security-test-suite.md", title: "Security Test Suite", parent: "Operations", nav_order: 6 },
  { src: "docs/SHIPPING.md", dest: "docs/operations/shipping.md", title: "Shipping", parent: "Operations", nav_order: 7 },
  { src: "docs/ACCESSIBILITY.md", dest: "docs/operations/accessibility.md", title: "Accessibility", parent: "Operations", nav_order: 8 },
  { src: "docs/SEO.md", dest: "docs/operations/seo.md", title: "SEO", parent: "Operations", nav_order: 9 },
  { src: "docs/CMS.md", dest: "docs/reference/cms-integration.md", title: "CMS Integration", parent: "Reference", nav_order: 1 },
  { src: "docs/ROADMAP.md", dest: "docs/reference/roadmap.md", title: "Roadmap", parent: "Reference", nav_order: 2 },
  { src: "docs/PULL_REQUEST_TEMPLATE.md", dest: "docs/reference/pull-request-template.md", title: "Pull Request Template", parent: "Reference", nav_order: 3 }
].freeze

ALIASES = {
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
  replacement = DESTINATIONS[normalized] || repo_url_for(normalized) || raw_target

  replacement + suffix
end

def rewrite_links(content, current_src)
  content.gsub(/\]\(([^)]+)\)/) do |match|
    target = Regexp.last_match(1)
    replacement = normalize_link(current_src, target)
    match.sub("(#{target})", "(#{replacement})")
  end
end

def strip_sections(content, titles)
  pattern = Regexp.new(
    "^(?:##|###)\\s+(?:#{titles.map { |title| Regexp.escape(title) }.join("|")})\\s*\\n[\\s\\S]*?(?=^(?:#|##|###)\\s+|\\z)",
    Regexp::MULTILINE
  )

  content.gsub(pattern, "")
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

SECURITY_HARDENING_REWRITE = <<~MARKDOWN.freeze
  ## Security Hardening Overview

  The current security posture is designed around a few core principles:

  - keep pricing, pledge state, and settlement server-canonical
  - scope supporter access as narrowly as possible
  - fail closed when secrets or environment checks are missing
  - keep browser storage and cacheable responses low-sensitivity by default
  - validate authored content and request payloads before they reach sensitive logic
  - preserve operational visibility through repeatable security testing and explicit secrets handling

  ### Access Control And Environment Gating

  - magic links are scoped to specific pledge and campaign paths rather than broad user accounts
  - `/test/*` routes are gated behind test mode and are not meant to be reachable in normal deployments
  - admin routes require an explicit secret and are intended to fail closed when not configured correctly
  - supporter voting is keyed to the supporter email identity associated with the authorized pledge, which prevents simple multi-pledge vote amplification

  ### Webhook, Admin, And Origin Protections

  - Stripe webhook handling is built around signature verification and an explicit configured secret
  - admin-secret comparison is timing-safe rather than using a naive direct comparison
  - sensitive browser POST flows such as checkout bootstrap, completion, and payment-method updates are origin-checked against the configured site base
  - legacy callback surfaces that no longer belong to the live payment flow are intentionally removed rather than left dormant

  ### Browser And Response Hardening

  - order-specific checkout bootstrap and completion responses are served with `Cache-Control: private, no-store`
  - long-lived browser persistence is limited to cart structure and pricing inputs, while contact and address drafts stay session-scoped
  - short-lived recovery markers are used for checkout continuity instead of leaving sensitive in-flight state in storage indefinitely
  - security response headers reduce MIME sniffing, framing risk, and unnecessary referrer leakage

  ### Input And Content Validation

  - checkout-start payloads validate campaign identifiers, email addresses, cart items, and contribution inputs before canonical reconstruction
  - voting endpoints validate decision identifiers and option values before they reach state-changing logic
  - creator-authored labels and rich content are escaped or sanitized by default, with only a very small allowlisted HTML subset preserved
  - structured embeds are allowlisted to exact approved providers and URL shapes instead of broad substring checks
  - markdown link destinations are constrained to safe schemes and internal links

  ### Inventory And Data Integrity

  - scarce limited-tier inventory is coordinated through a per-campaign Durable Object rather than trusting client-visible KV state for race-sensitive truth
  - public inventory remains a projection for efficient reads, while reservation and commit truth stays in the coordinator
  - checkout completion invalidates cached stats and inventory so restored pages do not keep showing stale pre-pledge totals
  - settlement and reporting depend on server-owned pledge records rather than browser-submitted totals

  ### Abuse Controls And Operational Safeguards

  - rate limiting is available for expensive routes such as checkout, pledge management, admin operations, and webhooks
  - blocked requests are designed to fail closed without turning abuse into excessive extra KV writes
  - the secret-audit and security test suites are part of the documented verification path
  - the security model assumes operators will keep deployment secrets rotated, scoped, and out of repository history

  ## Accepted Boundaries

  Some tradeoffs remain intentional in the current model:

  - magic links are long-lived because accountless pledge management has to remain usable across campaign timelines
  - tokens still arrive through emailed URLs, so the platform relies on scoped access, response headers, and limited browser persistence rather than a full token-exchange flow

  If a deployment needs a stricter posture than that default, the most likely next steps would be shorter token lifetimes, easier token reissue flows, and a one-time token exchange that removes raw tokens from visible URLs after entry.

  ---
MARKDOWN

ROADMAP_REWRITE = <<~MARKDOWN.freeze
  # Roadmap

  This roadmap is organized as a release history of the real project states we actually used, rather than a flat completed-features list.

  ## Release History

  ### v0.5 — WME Launch

  This was the first version used to launch WME and prove the core platform model in the wild.

  New in this version:

  - Jekyll + GitHub Pages public campaign site with a working campaign presentation system
  - Cloudflare Worker backend for pledge storage, live stats, emails, and campaign lifecycle automation
  - all-or-nothing campaign logic with deferred charging instead of immediate capture
  - no-account supporter management through magic-link pledge access
  - campaign funding with tiers, support items, custom amounts, and basic post-pledge reporting
  - production-diary and supporter-update foundations for creator communication
  - Pages CMS integration so campaign content could be edited without a pure Git workflow

  ### v0.6 — Pre-Tecolote State

  This was the state of the project right before Tecolote launched. The emphasis here was making the system more reliable for a second real campaign with heavier content and more edge cases.

  New in this version:

  - multi-campaign readiness instead of a one-campaign proof of concept
  - stronger deadline handling, timezone fixes, and campaign-state transitions
  - deployment rebuild and cache-purge improvements around campaign status changes
  - milestone-email reliability fixes and settlement bug fixes from the WME experience
  - improved pledge-management behavior once campaigns moved past their live window
  - better support for richer campaign assets, updated public copy, and launch-polish work needed for Tecolote

  ### v0.7 — Platform Tip Slider

  This version introduced the optional platform-tip system and made it a first-class part of the supporter experience.

  New in this version:

  - optional platform tips from `0%` to `15%`, with `5%` as the default
  - tip slider and tip-aware totals in cart, checkout, and Manage Pledge
  - instant summary updates so supporters could see subtotal, tip, and total changes immediately
  - tip-aware supporter emails and pledge-flow documentation
  - improved manage-page layout and responsiveness around tip editing and tier swaps
  - stronger local checkout stability and broader automated coverage for tip-aware pledge flows

  ### v0.8 — Security Hardening

  This version was the hardening pass that moved the project from “working” to “defensible.”

  New in this version:

  - stricter checkout and token verification around first-party pledge flows
  - webhook, admin, and business-logic hardening across the Worker
  - stronger merge-readiness checks and local smoke workflows for sensitive pledge paths
  - improved local testing and developer tooling so hardening work could be validated repeatably
  - deployment automation for the Worker on `main`
  - a clearer move away from legacy hosted-cart assumptions and toward the newer first-party checkout model

  ### v0.9 — Local `0.9` Milestone

  This was the large local milestone marked by the repo’s `Version 0.9 complete` commit. It represented the first version that felt like a broadly reusable platform rather than a campaign-specific implementation.

  New in this version:

  - native first-party Stripe payment flow inside the site, plus the same secure pattern for `Update Card`
  - Podman-backed local development and testing
  - limited-inventory oversell protection with a per-campaign coordinator
  - accessibility hardening across dialogs, tabs, sliders, live regions, and key public/supporter flows
  - shared design-system redesign, mobile-responsiveness pass, and broader style-system cleanup
  - variable-first customization for forks through structured config and Worker mirroring
  - English/Spanish i18n completion for public pages, key supporter flows, and shared runtime copy
  - SEO fundamentals including canonical metadata, structured data, sitemap/robots handling, and share-card improvements
  - shipping-calculator work with USPS quoting, fallback behavior, and delivery-option handling
  - platform add-ons, campaign add-ons, projection drift checks, and broader reporting/operations maturity

  ### v0.9.1 — Current Local App State

  This is the current local state of the app. It is the version reflected in the local config and represents work completed after the `0.9` milestone rather than a separately deployed public release.

  New in this version:

  - improved checkout confirmation behavior and supporter email delivery
  - hosted live campaign embed widget and richer embed-builder flow
  - richer campaign share-card previews aligned with the embed design language
  - embed close-link and return-path polish for campaign widgets
  - docs cleanup and release-polish work following the larger `0.9` milestone
  - countdown behavior cleanup so expired campaign countdowns stop showing after deadlines

  ## Next

  Work still planned after `0.9.1` includes:

  - read-only or lightly interactive admin tooling for operators
  - a stronger content-editor story than the current Pages CMS setup
  - replacing flat-rate sales-tax logic with a more robust tax-calculation model
  - additional denial-of-service defense work
  - more flexible pricing support for add-on variants

  ## Known Issues

  **Credit Card Autofill**: credit-card number, expiry, and CVC fields live inside Stripe-controlled secure UI, so browser autofill support there is constrained by Stripe rather than the surrounding app.
MARKDOWN

def rewrite_copy(content, current_src)
  rewritten = content.dup

  GENERIC_REPLACEMENTS.each do |from, to|
    rewritten.gsub!(from, to)
  end

  rewritten.gsub!(/^\s*_Last updated:\s+.*?_\s*$\n?/i, "")

  rewritten = strip_sections(
    rewritten,
    ["Goals", "Non-Goals", "Remaining Follow-Up", "Current Follow-Up Work", "Follow-Up Candidates"]
  )

  case current_src
  when "README.md"
    rewritten.sub!(
      /\*\*Dust Wave's open-source crowdfunding platform\*\* — \[site\.example\.com\]\(https:\/\/site\.example\.com\)\n\nCurrent release milestone: \*\*v0\.9\.1\*\*\. The Pool will treat \*\*v1\.0\*\* as the wider public launch milestone once the remaining roadmap items are complete\.\n\n/,
      "**Open-source crowdfunding platform starter**\n\n"
    )
    rewritten.gsub!(/\n\*🄯 Dust Wave\*\n/, "\n")
    rewritten.gsub!("*🄯 Dust Wave*", "")
    rewritten.gsub!(/^\*🄯 Dust Wave\*$/m, "")
  when "about.md"
    rewritten.sub!(
      "**The Pool** is Dust Wave's crowdfunding platform for independent film and creative projects, built on open-source technology.",
      "**The Pool** is an open-source crowdfunding platform for independent film and creative projects."
    )
    rewritten.sub!(
      /\nThe current platform release milestone is \*\*v0\.9\.1\*\*\. Dust Wave is reserving \*\*v1\.0\*\* for the wider public launch once the remaining roadmap items are complete\.\n/,
      "\n"
    )
    rewritten.gsub!(/\n\*The Pool is created and maintained by.*\n/, "\n")
    rewritten.gsub!(
      "Those support Dust Wave directly, do not count toward a campaign's funding goal, and can be digital or physical.",
      "Those support the platform operator directly, do not count toward a campaign's funding goal, and can be digital or physical."
    )
    rewritten.gsub!(
      "Optional platform tips and platform add-ons go to Dust Wave to help maintain The Pool and do not count toward a project's funding goal.",
      "Optional platform tips and platform add-ons go to the platform operator to help maintain the deployment and do not count toward a project's funding goal."
    )
    rewritten.gsub!("*The Pool is created and maintained by [Dust Wave](https://example.com).*", "")
    rewritten.gsub!(/^\*The Pool is created and maintained by .*?\*$/m, "")
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
  when "docs/PROJECT_OVERVIEW.md"
    rewritten.gsub!("# Project Overview — The Pool (Dust Wave Crowdfund)", "# Project Overview — The Pool")
    rewritten.gsub!("- Company name: **Dust Wave** (two words, not \"DustWave\")", "- Company name: set this to your organization or studio name")
    rewritten.gsub!("- Design system: Matches dust-wave-shop (minimalist black/white, 8px grid, Inter + Gambado Sans)", "- Design system: adapt the supported design tokens and typography to your own brand")
    rewritten.gsub!("optional platform tip from a shared pricing model", "optional platform tip from a shared pricing model")
    rewritten.gsub!("- platform tips are optional, default to 5%, and are capped at 15%.", "- Platform tips are optional, default to 5%, and are capped at 15%.")
  when "docs/ADD_ON_PRODUCTS.md"
    rewritten.gsub!("## Initial Dust Wave Import", "## Initial Merch Import")
    rewritten.gsub!("The current first-wave catalog is based on the live your merch store at [shop.example.com](https://shop.example.com/):", "The current first-wave catalog is shown as an example merch import from [shop.example.com](https://shop.example.com/):")
  when "docs/SEO.md"
    rewritten.gsub!('  default_social_image_alt: "Dust Wave on The Pool"', '  default_social_image_alt: "Social card for your deployment"')
  when "docs/CUSTOMIZATION.md"
    rewritten.gsub!('  default_social_image_alt: "Dust Wave on The Pool"', '  default_social_image_alt: "Social card for your deployment"')
  when "docs/SECURITY.md"
    rewritten.sub!(
      /## Vulnerability Summary.*?(?=## Secrets Checklist)/m,
      "#{SECURITY_HARDENING_REWRITE}\n\n"
    )
    rewritten.gsub!(/^- \*\*Primary:\*\* \[security@example\.com\]\n/, "")
  when "docs/ROADMAP.md"
    rewritten = ROADMAP_REWRITE.dup
  when "worker/README.md"
    rewritten.sub!(
      /(The Pool currently only needs USPS OAuth plus the default pricing\/shipping-options product set for live quote calculation\. It does \*\*not\*\* require USPS Labels \/ Ship \/ EPA setup unless the project later grows into label generation\.)/,
      <<~MARKDOWN.strip
        \\1

        Example local `worker/.dev.vars` file:

        ```dotenv
        STRIPE_SECRET_KEY_TEST=sk_test_your_test_key
        STRIPE_WEBHOOK_SECRET_TEST=whsec_your_test_webhook_secret
        CHECKOUT_INTENT_SECRET=replace_with_a_long_random_string
        MAGIC_LINK_SECRET=replace_with_a_different_long_random_string
        RESEND_API_KEY=re_example_key
        ADMIN_SECRET=replace_with_a_third_long_random_string
        USPS_CLIENT_SECRET=replace_with_usps_client_secret
        ```

        Notes:

        - keep `worker/.dev.vars` untracked and gitignored
        - use local/test secrets here, not live production credentials
        - `./scripts/dev.sh --podman` may auto-generate or update some local-only values such as `CHECKOUT_INTENT_SECRET` or the Stripe webhook secret during development
      MARKDOWN
    )
  end

  rewritten
end

DOCS.each do |doc|
  source_path = POOL_ROOT.join(doc[:src])
  target_path = ROOT.join(doc[:dest])

  unless source_path.file?
    warn "Missing source file: #{source_path}"
    next
  end

  content = strip_front_matter(source_path.read)
  content = rewrite_links(content, doc[:src]).strip
  content = rewrite_copy(content, doc[:src]).strip

  front_matter = <<~YAML
    ---
    title: #{doc[:title].dump}
    parent: #{doc[:parent].dump}
    nav_order: #{doc[:nav_order]}
    render_with_liquid: false
    ---

  YAML

  FileUtils.mkdir_p(target_path.dirname)
  target_path.write(front_matter + content + "\n")
  puts "Wrote #{target_path.relative_path_from(ROOT)}"
end
