#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "date"
require "pathname"
require "set"
require "shellwords"

ROOT = Pathname(__dir__).join("..").expand_path
POOL_ROOT = Pathname(ENV.fetch("POOL_SOURCE", "/tmp/pool")).expand_path
POOL_REPO = ENV.fetch("POOL_REPO", "aindaco1/pool")
POOL_BLOB_BASE = "https://github.com/#{POOL_REPO}/blob/main/"
POOL_TREE_BASE = "https://github.com/#{POOL_REPO}/tree/main/"
METADATA_ONLY_COMMIT_SUBJECTS = [
  "Update docs changelog and date stamps",
  "Fix docs last updated stamps"
].freeze

DOCS = [
  { src: "about.md", dest: "docs/overview/about-the-pool.md", title: "About The Pool", parent: "Overview", nav_order: 1 },
  { src: "terms.md", dest: "docs/overview/terms-and-guidelines.md", title: "Terms & Creative Guidelines", parent: "Overview", nav_order: 2 },
  { src: "docs/CONTRIBUTING.md", dest: "docs/development/contributing.md", title: "Contributing", parent: "Development", nav_order: 1 },
  { src: "docs/PROJECT_OVERVIEW.md", dest: "docs/development/project-overview.md", title: "Project Overview", parent: "Development", nav_order: 2 },
  { src: "docs/WORKFLOWS.md", dest: "docs/development/workflows.md", title: "Workflows", parent: "Development", nav_order: 3 },
  { src: "docs/DEV_NOTES.md", dest: "docs/development/developer-notes.md", title: "Developer Notes", parent: "Development", nav_order: 4 },
  { src: "docs/CUSTOMIZATION.md", dest: "docs/development/customization-guide.md", title: "Customization Guide", parent: "Development", nav_order: 5 },
  { src: "docs/I18N.md", dest: "docs/development/internationalization.md", title: "Internationalization", parent: "Development", nav_order: 6 },
  { src: "docs/EMBEDS.md", dest: "docs/development/campaign-embeds.md", title: "Campaign Embeds", parent: "Development", nav_order: 7 },
  { src: "docs/ADD_ON_PRODUCTS.md", dest: "docs/development/add-on-products.md", title: "Add-On Products", parent: "Development", nav_order: 8 },
  { src: "docs/AGENTS.md", dest: "docs/development/agents-operator-guide.md", title: "Agents & Operator Guide", parent: "Development", nav_order: 9 },
  { src: "docs/DASHBOARD.md", dest: "docs/operations/admin-dashboard.md", title: "Admin Dashboard", parent: "Operations", nav_order: 1 },
  { src: "worker/README.md", dest: "docs/operations/worker.md", title: "Pledge Worker", parent: "Operations", nav_order: 2 },
  { src: "docs/PODMAN.md", dest: "docs/operations/podman-local-dev.md", title: "Podman Local Dev", parent: "Operations", nav_order: 3 },
  { src: "docs/TESTING.md", dest: "docs/operations/testing.md", title: "Testing Guide", parent: "Operations", nav_order: 4 },
  { src: "docs/MERGE_SMOKE_CHECKLIST.md", dest: "docs/operations/merge-smoke-checklist.md", title: "Merge Smoke Checklist", parent: "Operations", nav_order: 5 },
  { src: "docs/SECURITY.md", dest: "docs/operations/security.md", title: "Security Guide", parent: "Operations", nav_order: 6 },
  { src: "tests/security/README.md", dest: "docs/operations/security-test-suite.md", title: "Security Test Suite", parent: "Operations", nav_order: 7 },
  { src: "docs/SHIPPING.md", dest: "docs/operations/shipping.md", title: "Shipping", parent: "Operations", nav_order: 8 },
  { src: "docs/ACCESSIBILITY.md", dest: "docs/operations/accessibility.md", title: "Accessibility", parent: "Operations", nav_order: 9 },
  { src: "docs/SEO.md", dest: "docs/operations/seo.md", title: "SEO", parent: "Operations", nav_order: 10 },
  { src: "docs/PERFORMANCE.md", dest: "docs/operations/performance.md", title: "Performance", parent: "Operations", nav_order: 11 },
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
  "README.md" => "/docs/overview/about-the-pool/",
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

def format_english_date(date)
  date.strftime("%B %-d, %Y")
end

def remove_last_updated(content)
  content.gsub(/\n## Last Updated\n\n[^\n]+(?:\n{2,}|\z)/, "\n")
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

  existing_content = strip_front_matter(target_path.read).strip
  remove_last_updated(existing_content).strip != remove_last_updated(generated_content).strip
end

def last_updated_for(target_path, generated_content)
  return Date.today if content_changed?(target_path, generated_content)

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

ABOUT_REWRITE = <<~MARKDOWN.freeze
  # About The Pool

  **The Pool** is an open-source, static-first crowdfunding platform for independent film, media, and other artist-driven projects.

  It is designed around a simple promise: supporters can pledge toward a creative project without creating an account, and their cards are only charged if the campaign reaches its goal. Behind that lightweight supporter experience, The Pool gives creators and operators real infrastructure for pledge checkout, fulfillment, updates, reporting, admin editing, localization, and deployment.

  Current release milestone: **v1.0.4**. The v1.0 feature set and launch-hardening pass are complete. v1.0.4 adds super-admin plan-usage tracking for Cloudflare Workers/KV and Resend, dashboard net revenue analytics after allocated Stripe processor fees, component-level fee allocation for reports/exports, usage-tracker provider credential docs, and grouped local Worker secret scaffolding.

  ## All-or-Nothing Pledging

  When you back a project on The Pool, your card is saved securely via Stripe, but you are **not charged until the campaign reaches its goal**. If the project does not hit its funding target by the deadline, your card is never charged.

  This protects both backers and creators: you only pay for projects that can actually make their funding goal.

  ## Supporter Experience

  Unlike other platforms, The Pool doesn't require you to create an account. When you pledge, you receive email links to:

  - **Manage your pledge** — cancel, modify amount, or update your payment method
  - **Access the supporter community** — vote on published creative decisions and see exclusive updates

  If your checkout includes more than one campaign, you'll receive separate confirmation emails and manage links for each campaign. Just save those emails. They are your keys.

  For campaigns that have not launched yet, you can also sign up for a one-time launch reminder without creating an account or starting a pledge.

  The pledge flow works like this:

  1. **Browse** — Find a campaign you want to help bring to life.
  2. **Build your pledge** — Add one or more campaigns to your cart, choose any rewards or add-ons, and decide whether to include an optional platform tip.
  3. **Save your payment method** — Enter payment details through Stripe's secure payment UI. Your card is saved, not charged.
  4. **Follow the campaign** — The campaign stays open until its deadline, shown in the configured platform timezone.
  5. **See the result** — If the campaign reaches its goal, your pledge is charged after the campaign ends. If it does not, you are not charged.

  Some checkouts may include platform add-ons, campaign add-ons, delivery upgrades, shipping fees, taxes, or an optional platform tip. The checkout explains what counts toward the campaign's goal and what supports the platform separately.

  Multiple pledges from the same email are combined into one charge when the same campaign succeeds. If more than one campaign from the same checkout succeeds, those charges stay separate by campaign. Optional platform tips and platform add-ons support the team operating the platform and do not count toward a project's funding goal.

  ## Creator And Operator Tools

  The Pool is designed for filmmakers and creative teams that need a campaign they can run without sending supporters through a maze of accounts, plugins, or disconnected tools.

  - **No organizer platform fee** — Campaign funds stay with the project. Supporters can choose an optional 0% to 15% platform tip that helps sustain The Pool without reducing campaign funding.
  - **Built-in pledge checkout** — Supporters pledge through The Pool's cart and review flow, while Stripe securely handles payment details for any later campaign charge.
  - **Reward tiers that fit the project** — Offer digital or physical tiers, collect shipping details when needed, set quantity limits, and use the campaign's configured tax and shipping rules.
  - **Optional platform add-ons** — Offer platform merch alongside pledges when enabled, with separate inventory and shipping handling that does not count toward a campaign's funding goal.
  - **Campaign add-ons** — Sell campaign-specific merch or extras in the same pledge flow while keeping revenue, inventory, and shipping tied to that campaign.
  - **Private admin dashboard** — Give trusted team members a focused workspace for campaign settings, page content, rewards, updates, decisions, reports, supporters, analytics, marketing links, add-ons, and users.
  - **Configurable platform timezone** — Super admins can choose the IANA timezone used for campaign deadlines, countdowns, scheduled reports, and lifecycle automation.
  - **Dashboard media uploads** — Stage campaign and diary images, video, and audio with previews, publish them into campaign asset paths through the normal reviewable workflow, trigger image/video optimization, and clean up dashboard-owned media that is no longer referenced.
  - **Reports when you need them** — Preview and download pledge or fulfillment CSVs from the dashboard, with optional campaign-runner emails during active campaigns.
  - **Upcoming-campaign reminders** — Let potential supporters opt into one launch email before a campaign opens, without creating accounts or mailing-list dependencies.
  - **Embeds for promotion** — Generate live campaign widgets for partner sites, press pages, creator portfolios, or sponsor pages.
  - **Share links and social previews** — Give supporters clear platform share targets while keeping social preview images and descriptions aligned with the campaign's current state.
  - **Production phases** — Show supporters which parts of the budget they can help fund.
  - **Stretch goals** — Make additional creative milestones visible as support grows.
  - **Community decisions** — Invite backers to vote on selected creative choices.
  - **Production diary** — Share updates that keep supporters engaged from launch through fulfillment.
  - **Ongoing support** — Keep accepting support after the main campaign ends, when the campaign is configured for it.
  - **No-account supporter access** — Backers manage pledges and visit supporter-only pages through secure email links instead of creating another password.
  - **Multilingual-ready supporter flows** — Start with English and add translated supporter pages, emails, campaign content, and management screens when a deployment needs more languages.
  - **Safer rich content** — Write campaign pages and diary posts with Markdown and approved media embeds, with unsafe HTML and dangerous links blocked at render time.
  - **Accessibility-minded experience** — Campaign pages, checkout, dialogs, tabs, sliders, and supporter flows are built and tested for keyboard and screen-reader use.

  ## Architecture

  The Pool is a static-first crowdfunding stack. Public pages are generated ahead of time, while trusted server work stays behind Cloudflare Workers for pricing, pledges, admin access, fulfillment data, and serialized settlement.

  | Area | What runs it | Why it matters for forks |
  |------|--------------|--------------------------|
  | Public site | [GitHub Pages](https://docs.github.com/en/pages) and Jekyll | Campaign pages, docs, translated content, and public metadata stay easy to host and review in Git. |
  | Pledge experience | The Pool cart runtime | The cart, reward selection, add-ons, pledge review, and magic-link management stay first-party. |
  | Payments | [Stripe](https://stripe.com) | Stripe owns the sensitive payment fields, saved payment methods, and later charges. |
  | Backend | [Cloudflare Workers](https://workers.cloudflare.com) and KV | The Worker validates totals, stores pledges, serves live stats, powers admin APIs, and handles fulfillment plus campaign-scoped settlement state. |
  | Admin dashboard | The Pool private dashboard | Authorized users can manage campaigns, content, reports, supporters, analytics, marketing links, add-ons, and users without editing files directly. |
  | Email | [Resend](https://resend.com) | Confirmation emails, supporter links, launch reminders, campaign updates, and charge notifications use one transactional email path. |

  The key boundaries are intentionally clear: static content belongs in the site, trusted pledge math belongs in the Worker, payment details belong in Stripe, transactional email belongs in Resend, and role-scoped operations belong in the admin dashboard.

  ## Performance And Cost Shape

  The stack is designed to be practical for small teams and forks. Each major service has a free tier, and the platform avoids unnecessary dynamic work wherever possible. Public campaign pages are static, public live data is combined and browser-cached, and the Worker is reserved for operations that need server-side trust.

  The public page performance model stays static-first. The site minifies generated build artifacts, lets Cloudflare handle transfer compression, reserves stable space for campaign progress and media, serves generated responsive image variants where available, defers remote YouTube hero embeds until play intent, and delays heavier first-party cart code until it is actually needed.

  The admin dashboard follows the same cost discipline. Browsing, filtering, previews, analytics, reports, and local drafts avoid KV writes. Durable writes happen only when an admin explicitly saves dashboard-only state or publishes a campaign/platform change.

  With the v1.0.3 list-budget hardening, idle launch-reminder dispatch, supporter-email retry, and platform add-on inventory paths use queue-state or sold-count projections to avoid unnecessary KV namespace scans during normal read paths.

  ## Forking, Development, And Deployment

  Customization is mostly configuration-driven. Tax, shipping, SEO, localization, platform timezone, logging, email identity, dashboard settings, public branding, checkout styling, and supporter email presentation are kept aligned through config so a fork can change the presentation without rewriting the pledge model.

  For local development, the recommended path is the rootless Podman flow documented in [Podman Local Dev](/docs/operations/podman-local-dev/). It boots Jekyll and the Worker with production-like service boundaries while keeping secrets in local env files.

  For deployment, pushes to `main` build the GitHub Pages site and deploy the Cloudflare Worker when the required repository and Worker secrets are configured. Use [Pledge Worker](/docs/operations/worker/) for Worker setup, [Customization Guide](/docs/development/customization-guide/) for fork-facing config, [Testing Guide](/docs/operations/testing/) for release checks, and [Security Guide](/docs/operations/security/) for secrets, access control, and abuse-path expectations.

  The same architecture supports accessibility and SEO without weakening security. Public pages emit crawlable metadata and conservative structured data, while private magic-link pages such as Manage Pledge, supporter community pages, and the admin dashboard stay out of search indexing. Checkout and management flows add keyboard, focus, dialog, live-region, and landmark behavior around Stripe's secure payment UI rather than replacing it.

  ## Open Source

  The Pool is open source. The entire platform — frontend, Worker, automation, and fork-facing customization surface — is available on GitHub.

  **Source code:** [github.com/aindaco1/pool](https://github.com/aindaco1/pool)

  ---
MARKDOWN

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
  - private admin access uses email magic links, signed session cookies, CSRF checks, and role/campaign scoping
  - admin sign-in can require a Cloudflare Turnstile challenge before login nonce writes or magic-link delivery
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
  - dashboard settings, campaign fields, content blocks, add-ons, tiers, support items, diary entries, decisions, and user records are normalized server-side before persistence
  - dashboard media uploads are scoped by role, campaign access, upload kind, content type, file size, destination directory, and canonical filename
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
  - normal dashboard reads, filters, previews, analytics, report downloads, and local editor drafts are designed to avoid KV writes
  - secret values remain in Worker secrets or ignored local files; the dashboard can report configured/missing status but cannot edit or serialize secret values
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

  ## Current Milestone

  **v1.0.4**

  The v1.0 feature set and release-hardening pass are complete. v1.0.4 adds super-admin plan-usage tracking for Cloudflare Workers/KV and Resend, dashboard net revenue analytics after allocated Stripe processor fees, component-level fee allocation for reports/exports, usage-tracker provider credential docs, and grouped local Worker secret scaffolding.

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

  ### v0.9.1 — Embedded Campaign Sharing

  This point release was the first major follow-up after the larger `0.9` milestone. The emphasis here was making campaign sharing, embeds, and post-checkout polish feel like part of the product rather than sidecar experiments.

  New in this version:

  - improved checkout confirmation behavior and supporter email delivery
  - hosted live campaign embed widget and richer embed-builder flow
  - richer campaign share-card previews aligned with the embed design language
  - embed close-link and return-path polish for campaign widgets
  - docs cleanup and release-polish work following the larger `0.9` milestone
  - countdown behavior cleanup so expired campaign countdowns stop showing after deadlines

  ### v0.9.2 — Commerce And Fulfillment Maturity

  This version turned the platform from “campaign tiers plus basic shipping” into a more complete commerce and fulfillment system.

  New in this version:

  - platform-wide add-on products with inventory awareness, low-stock handling, variant support, and full cart / Manage Pledge integration
  - campaign-specific add-ons that reuse the same UI patterns while still counting toward the owning campaign’s subtotal and funding logic
  - shipping-calculator work that replaced the old flat physical-fee model with Worker-canonical USPS-backed quoting, fallback behavior, free-shipping overrides, and limited delivery-option upgrades
  - reporting changes that kept campaign pledge revenue, platform add-on revenue, and fulfiller ownership more operationally distinct
  - follow-up shipping work around real USPS credentialed smoke coverage, estimate-mode UX, shared shipping-country data, and safer handling for flat-mail/manual-rate cases

  ### v0.9.3 — Operator Hardening And Reporting

  This release focused on making the platform easier to operate safely once the commerce surface got more complex.

  New in this version:

  - read-only projection-drift diagnostics plus local operator tooling so stats, inventory, and campaign indexes could be checked before repair work mutated anything
  - denial-of-service hardening with required `RATELIMIT` KV, tighter write-path rate limits, earlier oversized-payload rejection, and safer retry budgeting around `checkout-intent/abandon`
  - a conservative `cpu_ms` ceiling plus lightweight observability summaries and local observability checks for tuning Worker cost and behavior
  - campaign-runner reporting with `runner_report_emails`, bounded `reports.campaign_runner` config, daily live-campaign ledger emails, and split post-deadline fulfillment flows for campaign versus platform fulfillers
  - a shared report core so scheduled runner emails and local CLI exports stop drifting from each other

  ### v0.9.4 — Tax-Aware Checkout

  This release made tax-aware checkout a first-class part of the platform and rounded out the fork-polish work needed to make the project feel more production-shaped.

  New in this version:

  - provider-driven tax calculation through `flat`, `offline_rules`, `nm_grt`, and `zip_tax` modes instead of only one flat-rate assumption
  - provisional tax UX in cart and checkout so the browser can show `--` until the Worker has enough billing or shipping destination detail to return a real answer
  - final-tax destination plumbing across cart, custom checkout, Manage Pledge, stored pledge data, and supporter emails so tax math stays consistent everywhere
  - a free-first New Mexico path through a vendored starter dataset plus optional EDAC refinement, alongside better local smoke coverage for provider-driven tax setups
  - shared fork-branding polish so the same config surface now themes on-site Stripe Elements, supporter emails, and more of the localized metadata layer
  - localized follow-up work such as cart-button summaries, checkout tax-location helper copy, and locale-aware public metadata / JSON-LD so the tax-aware flows still read cleanly in English and Spanish

  ### v0.9.5 — Local Runtime Parity And Creator Launch Handoff

  This release kept local Worker development aligned with production deployment behavior while tightening the public handoff material creators need before launch.

  New in this version:

  - Podman Worker development now runs on Node 24 to match GitHub Actions deployments
  - host and Podman helper scripts now prefer Node 24 and no longer force the obsolete Node 20 Wrangler path
  - Wrangler 4 local development runs against Worker compatibility date `2026-05-03`, avoiding the older local-runtime polyfill crash under Node 24
  - Podman Worker dependency setup now uses `npm ci` so local container starts do not mutate `worker/package-lock.json`
  - the public Campaign Creator Checklist now covers campaign add-ons, embed-code promotion, shipping fallback/free-shipping decisions, tax expectations, report recipients, and fulfillment handoff
  - a Spanish creator checklist route now exists at `/es/creator-campaign-checklist/`

  ### v1.0.0 — Public Launch Platform

  This release moved The Pool from reusable campaign infrastructure to a production-shaped platform with a private browser operations surface.

  New in this version:

  - private admin dashboard at `/admin/` and `/es/admin/` for role-scoped platform settings, campaign editing, add-ons, reports, analytics, supporters, marketing tools, and users
  - email magic-link admin authentication with signed sessions, CSRF/origin protections, optional Turnstile challenge support, and safe browser APIs that do not expose `ADMIN_SECRET`
  - dashboard editing for campaign settings, content blocks, tiers, support items, campaign add-ons, stretch goals, ongoing items, diary entries, decisions, platform add-ons, and platform settings
  - dashboard Users management backed by Worker KV at `admin-users:v1`, including notification emails for newly created users when Resend is configured
  - dashboard Marketing tools for referral and UTM URL building, saved referral codes, reusable embed-builder controls, and copyable launch snippets
  - role-scoped Analytics, Reports, and Supporters views with sortable/filterable tables, exact-cent dollar display, CSV downloads, and read-only report previews
  - dashboard accessibility, i18n, SEO/noindex, security, mobile/tablet responsiveness, and DRY UI passes
  - final release verification across admin browser flows, pre-merge regression checks, and local Podman smoke for the dashboard's main tabs

  ### v1.0.1 — Dashboard Media And Analytics Patch

  This point release tightened the new dashboard workflow after v1.0.0 and added the analytics data needed for more accurate revenue reporting.

  New in this version:

  - newly charged pledges capture actual Stripe balance transaction fee, net, gross, charge, and balance transaction IDs when available
  - dashboard Analytics prefers stored actual Stripe fees when available and labels mixed or estimated values clearly
  - super admins can backfill older charged pledge records with Stripe balance transaction data without KV list scans
  - campaign and diary content editors can stage image, video, and audio uploads with immediate previews and publish them into the correct campaign asset directories
  - dashboard uploads stay source-preserving in the Worker, while repository tooling handles lossless image compression and WebM derivative generation
  - `npm run media:optimize`, `npm run media:optimize:check`, and the "Optimize dashboard media" GitHub Actions workflow support the post-upload media pipeline
  - Supporters and Analytics return empty read-only views for campaigns without pledge indexes instead of blocking new or empty campaign dashboards

  ### v1.0.2 — Performance, Sharing, And Admin Polish

  This point release made public pages lighter and more predictable while adding safer sharing controls and a small admin performance surface for fork operators.

  New in this version:

  - campaign progress bars and milestone markers render static width and position classes so first load no longer waits for JavaScript to avoid collapsed marker layouts
  - public pages load a lightweight cart-runtime loader first and defer the full cart stack until persisted cart state, recovery state, or clear supporter intent requires it
  - same-origin public document prefetching follows a small local intent model with route allowlists, sensitive-query exclusions, network guards, low per-page limits, and a default-enabled config surface
  - Settings -> Advanced performance exposes intent-prefetch enablement, delay, and page-view limit for super admins, with Worker config mirroring through `INTENT_PREFETCH_*`
  - production Pages builds minify generated `_site` CSS and JavaScript after Jekyll output, while Cloudflare remains responsible for transfer compression
  - campaign pages render reusable icon-only share links for Bluesky, X, Threads, Facebook, SMS, and email with localized URLs and state-aware CTA text where supported
  - responsive share controls appear below the short blurb on mobile/tablet and above the embed button only on desktop
  - admin email sign-in keeps the existing Turnstile challenge after a login attempt and uses the shared dashboard status-message styling for more prominent auth feedback
  - the public Campaign Creator Checklist and Spanish checklist describe creator-facing changes from v0.9.5 through v1.0.2, including share-link planning and dashboard media uploads

  ### v1.0.3 — Platform Timezone, Launch Reminders, And Media Workflow Hardening

  This point release made campaign lifecycle timing configurable for forks, added launch-reminder collection for upcoming campaigns, and tightened media/performance operations for public campaign pages.

  New in this version:

  - super admins can set the default platform timezone from supported IANA timezone options, with Jekyll campaign state, browser countdowns, Worker deadline checks, campaign-runner reports, settlement checks, and admin date/time surfaces sharing the same `platform.timezone` / `PLATFORM_TIMEZONE` model
  - upcoming campaign pages can collect one-time launch reminder signups through a slim localized form with Turnstile, rate limiting, campaign/email dedupe, signed unsubscribe links, and bounded dispatch jobs
  - launch reminder delivery reuses the existing Resend email module, sender configuration, locale catalog, and pacing instead of adding a second email integration
  - the minute-level Worker scheduler now persists `cron:lastRun` hourly instead of every minute, keeping cron health visible without consuming the free-tier KV write budget as baseline churn
  - `_config.local.yml` can blank the reminder Turnstile site key so local development hides the widget consistently with local admin sign-in
  - the Podman media optimizer now includes `optipng` and `gifsicle` for local PNG/GIF source compression through the same repository media workflow
  - responsive image generation now includes a `640w` WebP rung between the existing `480w` and `960w` variants for mobile campaign pages
  - YouTube campaign hero videos render local poster/play facades and defer the remote iframe until supporter play intent
  - the public creator checklists now describe the creator-facing v1.0.3 changes, including launch reminders, platform timezone expectations, deferred YouTube hero embeds, and responsive WebP variants
  - optional `ADMIN_SETTLEMENT_SECRET` and `ADMIN_BROADCAST_SECRET` can narrow settlement and broadcast automation access; scoped routes reject the broader `ADMIN_SECRET` when the narrower secret is configured
  - scheduled, direct, dispatch, and batch settlement paths now share a campaign-scoped `SETTLEMENT_COORDINATOR` Durable Object lock and deterministic Stripe idempotency keys so same-campaign charging cannot overlap
  - multi-campaign checkouts remain supported by fanning checkout bundles into separate campaign-scoped pledge records; settlement locks and batches stay scoped to the campaign being charged
  - GitHub Actions and operator docs now distinguish Worker runtime secrets from repository secrets, including when matching scoped admin secrets must exist in both places
  - Cloudflare deploy and report-export docs now require `CLOUDFLARE_ACCOUNT_ID`, recommend user-scoped deploy tokens, and document narrower cache-purge and read-only KV token options
  - `worker/.dev.vars` guidance now explicitly calls for local-only values rather than production-secret backups
  - dashboard image/video uploads request the repository media optimizer with `scope=changed`, while publish-time cleanup removes same-campaign dashboard-owned media that disappeared from authored content and is not referenced elsewhere
  - launch reminder dispatch, supporter email retry, and platform add-on inventory paths now use queue-state or sold-count projections to avoid unnecessary KV list scans during idle or normal read paths

  ### v1.0.4 — Admin Plan Usage And Net Revenue Analytics

  This point release tightened the admin operator surface around provider usage limits, revenue reporting, and local secret setup.

  New in this version:

  - super admins can view read-only Cloudflare Workers/KV and Resend plan usage from Settings without exposing provider tokens to the browser
  - usage cards support provider-detected plan names where available, warning thresholds, progress bars, and provider links for account follow-up
  - dashboard Analytics now shows net campaign and platform revenue after allocated actual or estimated Stripe processor fees while keeping gross revenue cards visible for reconciliation
  - fee allocation is component-aware across campaign revenue, platform revenue, tax, and shipping so table and CSV exports reconcile with stored Stripe balance transactions or estimates
  - Worker and operator docs now describe the Cloudflare GraphQL Analytics / Billing Read token boundary, Resend usage behavior, and plan override variables
  - local Worker `.dev.vars` scaffolding and `npm run secrets:dev` output are grouped by purpose, including Plan Usage provider settings and overrides

  ## Future Features

  Work still planned after `1.0.4` includes:

  - further tax-calculator work for broader US and international coverage, better local-jurisdiction depth, and clearer tax-data refresh workflows
  - richer campaign marketing tools such as announcement composition and consent-aware abandoned-cart follow-up
  - different prices per add-on variation
  - email-protected campaign preview pages for super admins, campaign users, and invited reviewers

  ## Known Issues

  **Credit Card Autofill**: credit-card number, expiry, and CVC fields live inside Stripe-controlled secure UI, so browser autofill support there is constrained by Stripe rather than the surrounding app.
MARKDOWN

CHANGELOG_103_ENTRY = <<~MARKDOWN.freeze
  ## v1.0.3 - 2026-06-01

  - Added optional scoped admin automation secrets: `ADMIN_SETTLEMENT_SECRET` for settlement routes and `ADMIN_BROADCAST_SECRET` for announcement, diary, and milestone routes. When a scoped secret is configured, those routes reject the broader `ADMIN_SECRET`.
  - Added campaign-scoped settlement serialization with the `SETTLEMENT_COORDINATOR` Durable Object, same-campaign batch validation, and deterministic Stripe idempotency keys for campaign/supporter charge groups.
  - Clarified that multi-campaign checkouts still fan out into separate campaign-scoped pledge records, while settlement locks, batches, job state, and completion markers stay keyed to the campaign being charged.
  - Updated deployment and operator docs for `CLOUDFLARE_ACCOUNT_ID`, user-scoped Cloudflare deploy tokens, narrower cache-purge tokens, read-only KV report-export tokens, and the difference between Worker runtime secrets and GitHub repository secrets.
  - Tightened local secret guidance so `worker/.dev.vars` uses separate local-only values and is not treated as a production secret backup.
  - Updated dashboard media documentation for image/video optimizer dispatch with `scope=changed`, source-preserving uploads, audio source preservation, and publish-time cleanup of unreferenced same-campaign dashboard-owned media.
  - Documented the list-budget hardening for launch reminder dispatch, supporter confirmation email retry queues, and platform add-on sold-count projections so idle or normal read paths avoid unnecessary KV namespace scans.
  - Updated logging documentation to reflect that console logging remains enabled by default while lower-severity verbose debug/info/log output defaults off.
  - Added configurable platform timezone handling across Jekyll campaign state, browser countdowns, Worker lifecycle automation, campaign-runner reports, dashboard settings, and Worker config mirroring. The default remains `America/Denver` for compatibility, and super admins can choose from supported IANA timezones.
  - Added upcoming-campaign launch reminders with a slim public signup form, Cloudflare Turnstile verification, campaign/email dedupe, signed unsubscribe links, bounded KV dispatch jobs, and Resend delivery through the existing shared email module.
  - Reduced baseline Workers KV write usage by changing the minute-level scheduler heartbeat to persist hourly instead of every minute, preserving cron health visibility while keeping the free-tier write budget available for real mutations.
  - Updated local development so `_config.local.yml` can hide launch reminder Turnstile widgets the same way local admin sign-in can hide its Turnstile widget.
  - Extended the Podman media optimizer image and wrappers with `optipng` and `gifsicle` so local PNG/GIF source compression uses the same repository media workflow as responsive image and video derivative generation.
  - Added a mobile PageSpeed performance pass for campaign pages: YouTube hero videos now render as local poster/play facades and load the remote iframe only after play intent, avoiding the initial YouTube JavaScript/CSS cost.
  - Added responsive hero-image preloads and a `640w` WebP derivative rung so mobile campaign pages can choose smaller browser assets between the existing `480w` and `960w` variants.
  - Updated the media optimizer to skip generated responsive WebP derivatives during source optimization, keeping generated browser assets up to date without recursively re-encoding them.
MARKDOWN

CHANGELOG_102_ENTRY = <<~MARKDOWN.freeze
  ## v1.0.2 - 2026-06-01

  - Added public-page performance fixes from the PageSpeed review: remote-video campaign pages no longer preload hidden fallback hero images, tier images opt into lazy/async decoding, default brand logos reserve their intrinsic dimensions, and public pages avoid eager Stripe preconnects before cart intent.
  - Extended the dashboard media optimization pipeline to generate responsive WebP image variants for PNG, JPEG, and GIF source images, so public campaign templates can serve smaller browser assets while keeping original uploads as source-of-truth fallbacks.
  - Added a manual `scope=all` option to the **Optimize dashboard media** workflow so existing campaigns can be reprocessed through the same media pipeline used for new dashboard uploads.
  - Updated campaign, tier, card, gallery, and content-image templates to use generated responsive variants when they exist without changing visible page structure or campaign Markdown references.
MARKDOWN

def rewrite_copy(content, current_src)
  rewritten = content.dup

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

  rewritten = strip_sections(
    rewritten,
    ["Goals", "Non-Goals", "Remaining Follow-Up", "Current Follow-Up Work", "Follow-Up Candidates"]
  )

  case current_src
  when "README.md"
    rewritten.sub!(
      /\*\*Dust Wave's open-source crowdfunding platform\*\* — \[site\.example\.com\]\(https:\/\/site\.example\.com\)\n\n/,
      "**Open-source crowdfunding platform starter**\n\n"
    )
    rewritten.sub!(
      /^Current release milestone: \*\*v1\.0\.\d+\*\*\. .+$/,
      "Current release milestone: **v1.0.4**. The v1.0 feature set and launch hardening pass are complete; v1.0.4 adds super-admin plan-usage tracking, net revenue analytics after allocated Stripe processor fees, component-level fee allocation, usage-tracker provider credential docs, and grouped local Worker secret scaffolding."
    )
    rewritten.gsub!("the v0.9.5 through v1.0.2 creator-facing changes", "the v0.9.5 through v1.0.4 creator-facing changes")
    rewritten.gsub!("the v0.9.5 through v1.0.3 creator-facing changes", "the v0.9.5 through v1.0.4 creator-facing changes")
    rewritten.gsub!(/\n\*🄯 Dust Wave\*\n/, "\n")
    rewritten.gsub!("*🄯 Dust Wave*", "")
    rewritten.gsub!(/^\*🄯 Dust Wave\*$/m, "")
  when "about.md"
    rewritten = ABOUT_REWRITE.dup
  when "CHANGELOG.md"
    if rewritten.include?("manual `scope=all` option") || rewritten.include?("mobile PageSpeed performance pass")
      rewritten.gsub!(/^## v1\.0\.3 - 2026-06-01\n[\s\S]*?(?=^## v1\.0\.[0-9]+|\z)/m, "")
      rewritten.gsub!(/^## v1\.0\.2 - 2026-06-01\n[\s\S]*?(?=^## v1\.0\.[0-9]+|\z)/m, "")
    end

    unless rewritten.match?(/^## v1\.0\.3\b/m)
      if rewritten.match?(/^## v1\.0\.2\b/m)
        rewritten.sub!(/(?=^## v1\.0\.2\b)/m, "#{CHANGELOG_103_ENTRY}\n")
      elsif rewritten.match?(/^## v1\.0\.1\b/m)
        rewritten.sub!(/(?=^## v1\.0\.1\b)/m, "#{CHANGELOG_103_ENTRY}\n")
      else
        rewritten.sub!("# Changelog\n\n", "# Changelog\n\n#{CHANGELOG_103_ENTRY}\n")
      end
    end

    unless rewritten.match?(/^## v1\.0\.2 - 2026-06-01\b/m)
      if rewritten.match?(/^## v1\.0\.1\b/m)
        rewritten.sub!(/(?=^## v1\.0\.1\b)/m, "#{CHANGELOG_102_ENTRY}\n")
      else
        rewritten.sub!("# Changelog\n\n", "# Changelog\n\n#{CHANGELOG_102_ENTRY}\n")
      end
    end
  when "docs/CUSTOMIZATION.md"
    rewritten.gsub!("such as `v1.0.2`", "such as `v1.0.3`")
    rewritten.gsub!("version: 1.0.2", "version: 1.0.3")
    rewritten.gsub!("release_label: v1.0.2", "release_label: v1.0.3")
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
  when "docs/PROJECT_OVERVIEW.md"
    rewritten.gsub!(/^# Project Overview.*$/, "# Project Overview")
    rewritten.gsub!("- Company name: **Dust Wave** (two words, not \"DustWave\")", "- Company name: set this to your organization or studio name")
    rewritten.gsub!("- Design system: Matches dust-wave-shop (minimalist black/white, 8px grid, Inter + Gambado Sans)", "- Design system: adapt the supported design tokens and typography to your own brand")
    rewritten.gsub!("optional platform tip from a shared pricing model", "optional platform tip from a shared pricing model")
    rewritten.gsub!("- platform tips are optional, default to 5%, and are capped at 15%.", "- Platform tips are optional, default to 5%, and are capped at 15%.")
  when "docs/ADD_ON_PRODUCTS.md"
    rewritten.gsub!("## Initial Dust Wave Import", "## Initial Merch Import")
    rewritten.gsub!("The current first-wave catalog is based on the live your merch store at [shop.example.com](https://shop.example.com/):", "The current first-wave catalog is shown as an example merch import from [shop.example.com](https://shop.example.com/):")
  when "docs/SEO.md"
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
  next if SELECTED_DOC_SOURCES.any? && !SELECTED_DOC_SOURCES.include?(doc[:src])

  source_path = POOL_ROOT.join(doc[:src])
  target_path = ROOT.join(doc[:dest])

  unless source_path.file?
    warn "Missing source file: #{source_path}"
    next
  end

  content = strip_front_matter(source_path.read)
  content = rewrite_links(content, doc[:src]).strip
  content = rewrite_copy(content, doc[:src]).strip
  content = stamp_last_updated(content, last_updated_for(target_path, content))

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
