#!/usr/bin/env python3
"""Validate the committed Dust Wave Support checkout contract."""
from __future__ import annotations

import os
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import parse_qs, urlparse

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "_site"
CONTRACT = "dust_wave_support_v1"
EXPECTED_PAGES = {"support/index.html": ("thepool", {"one_time", "monthly"})}
ALLOW_TEST_LINKS = os.environ.get("SUPPORT_ALLOW_TEST_LINKS") == "1"


class SupportParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.contracts: list[str] = []
        self.links: list[dict[str, str]] = []
        self.forbidden_tags: list[str] = []
        self.script_sources: list[str] = []
        self.has_dust_wave_link = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        data = {key: value or "" for key, value in attrs}
        if data.get("data-support-contract"):
            self.contracts.append(data["data-support-contract"])
        if tag == "a" and data.get("data-support-cadence"):
            self.links.append(data)
        if tag == "stripe-buy-button":
            self.forbidden_tags.append(tag)
        if tag == "script" and data.get("src"):
            self.script_sources.append(data["src"])
        if tag == "a" and data.get("href") == "https://dustwave.xyz":
            self.has_dust_wave_link = True


def audit_page(rel: str, source: str, cadences: set[str], errors: list[str]) -> None:
    path = SITE / rel
    if not path.exists():
        errors.append(f"missing support page: {rel}")
        return

    parser = SupportParser()
    parser.feed(path.read_text(errors="replace"))
    label = f"/{rel}"
    if parser.contracts != [CONTRACT]:
        errors.append(f"{label}: expected one {CONTRACT!r} contract marker")
    if parser.forbidden_tags:
        errors.append(f"{label}: embedded Stripe Buy Button is forbidden")
    if any("js.stripe.com/v3/buy-button.js" in src for src in parser.script_sources):
        errors.append(f"{label}: obsolete Stripe Buy Button loader is present")
    if not parser.has_dust_wave_link:
        errors.append(f"{label}: maintainer attribution does not link to Dust Wave")

    html = path.read_text(errors="replace")
    if "Meet Dust Wave" in html or "Conoce a Dust Wave" in html:
        errors.append(f"{label}: redundant standalone Dust Wave link returned")
    if "Both options continue to a secure Stripe checkout" in html:
        errors.append(f"{label}: redundant Stripe checkout explainer returned")
    if "Ambas opciones continúan a un checkout seguro de Stripe" in html:
        errors.append(f"{label}: redundant Stripe checkout explainer returned")

    found_cadences = {link.get("data-support-cadence", "") for link in parser.links}
    if len(parser.links) != len(cadences) or found_cadences != cadences:
        errors.append(f"{label}: expected exactly one checkout link for each of {sorted(cadences)}")

    for link in parser.links:
        cadence = link.get("data-support-cadence", "unknown")
        href = link.get("href", "")
        payment_link_id = link.get("data-payment-link-id", "")
        parsed = urlparse(href)
        query = parse_qs(parsed.query)
        if parsed.scheme != "https" or parsed.netloc != "buy.stripe.com":
            errors.append(f"{label}: {cadence} checkout is not an HTTPS Stripe Payment Link")
        if parsed.path.startswith("/test_") and not ALLOW_TEST_LINKS:
            errors.append(f"{label}: {cadence} checkout still uses a Stripe test link")
        if not payment_link_id.startswith("plink_"):
            errors.append(f"{label}: {cadence} checkout is missing its Payment Link id")
        expected_query = {
            "utm_source": source,
            "utm_medium": "website",
            "utm_campaign": "dust_wave_support",
        }
        for key, value in expected_query.items():
            if query.get(key) != [value]:
                errors.append(f"{label}: {cadence} checkout has invalid {key}")


def main() -> int:
    errors: list[str] = []
    if not SITE.exists():
        errors.append("_site does not exist; run a Jekyll build first")
    else:
        for rel, (source, cadences) in EXPECTED_PAGES.items():
            audit_page(rel, source, cadences, errors)

    if errors:
        print("Support audit failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    mode = "test links allowed" if ALLOW_TEST_LINKS else "live links required"
    print(f"Support audit passed ({mode})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
