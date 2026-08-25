#!/usr/bin/env python3
"""Check generated HTML for broken internal links and anchors."""
from __future__ import annotations

import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlparse


ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "_site"


class PageParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.hrefs: list[str] = []
        self.ids: set[str] = set()

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        data = {key: value or "" for key, value in attrs}
        if data.get("id"):
            self.ids.add(data["id"])
        if tag == "a" and data.get("href"):
            self.hrefs.append(data["href"])


def target_for(path: str) -> Path:
    clean = unquote(path).lstrip("/")
    candidate = SITE / clean
    if path.endswith("/"):
        return candidate / "index.html"
    if candidate.is_file():
        return candidate
    if (candidate / "index.html").is_file():
        return candidate / "index.html"
    if candidate.suffix == "" and candidate.with_suffix(".html").is_file():
        return candidate.with_suffix(".html")
    return candidate


def main() -> int:
    if not SITE.exists():
        print("Internal link audit failed:\n- _site does not exist; run a Jekyll build first")
        return 1

    site_root = SITE.resolve()
    parsed: dict[Path, PageParser] = {}
    for page in SITE.rglob("*.html"):
        parser = PageParser()
        parser.feed(page.read_text(errors="replace"))
        parsed[page.resolve()] = parser

    errors: list[str] = []
    for page, parser in parsed.items():
        for href in parser.hrefs:
            url = urlparse(href)
            if url.scheme or url.netloc or href.startswith(("mailto:", "tel:", "javascript:", "//")):
                continue
            if url.path:
                if url.path.startswith("/"):
                    target = target_for(url.path)
                else:
                    relative_target = (page.parent / unquote(url.path)).resolve()
                    if url.path.endswith("/"):
                        target = relative_target / "index.html"
                    elif relative_target.is_file():
                        target = relative_target
                    elif (relative_target / "index.html").is_file():
                        target = relative_target / "index.html"
                    else:
                        target = relative_target
            else:
                target = page

            target = target.resolve()
            label = page.relative_to(SITE)
            if not target.is_relative_to(site_root) or not target.is_file():
                errors.append(f"{label}: missing {href}")
                continue
            if url.fragment and target.suffix == ".html":
                target_parser = parsed.get(target)
                if target_parser and unquote(url.fragment) not in target_parser.ids:
                    errors.append(f"{label}: missing anchor {href}")

    if errors:
        print("Internal link audit failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"Internal link audit passed ({len(parsed)} HTML pages)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
