#!/usr/bin/env python3

from __future__ import annotations

import re
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from json import loads
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import urlopen

import yaml


ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "docs"
TARGET_DIR = ROOT / "es" / "docs"

SECTION_TITLES = {
    "FAQ": "Preguntas frecuentes",
    "Overview": "Resumen",
    "Development": "Desarrollo",
    "Operations": "Operaciones",
    "Reference": "Referencia",
}

TITLE_OVERRIDES = {
    "About The Pool": "Acerca de The Pool",
    "Terms & Creative Guidelines": "Términos y pautas creativas",
    "Project Overview": "Resumen del proyecto",
    "Customization Guide": "Guía de personalización",
    "Campaign Embeds": "Embeds de campaña",
    "Add-On Products": "Productos complementarios",
    "Pledge Worker": "Worker de promesas",
    "Podman Local Dev": "Desarrollo local con Podman",
    "Testing Guide": "Guía de pruebas",
    "Security Guide": "Guía de seguridad",
    "Security Test Suite": "Suite de pruebas de seguridad",
    "Merge Smoke Checklist": "Checklist de smoke tests antes del merge",
    "CMS Integration": "Integración con CMS",
    "Pull Request Template": "Plantilla de pull request",
    "Roadmap": "Hoja de ruta",
    "Platform Overview": "Resumen de la plataforma",
    "Internationalization (i18n)": "Internacionalización (i18n)",
    "Internationalization": "Internacionalización",
    "Developer Notes": "Notas para desarrolladores",
    "Contributing": "Cómo contribuir",
    "Workflows": "Flujos de trabajo",
    "Shipping": "Envíos",
    "Accessibility": "Accesibilidad",
    "SEO": "SEO",
}

BODY_OVERRIDES = {
    "# FAQ": "# Preguntas frecuentes",
    "# Overview": "# Resumen",
    "# Development": "# Desarrollo",
    "# Operations": "# Operaciones",
    "# Reference": "# Referencia",
    "## Last Updated": "## Última actualización",
}

cache: dict[str, str] = {}
TRANSLATE_SEPARATOR = "\nZXQZXQPOOLBREAKZXQZXQ\n"
TRANSLATE_MAX_CHARS = 2400


def protect_text(text: str) -> tuple[str, list[str]]:
    working = text
    placeholders: list[str] = []

    def protect(pattern: str, value: str) -> str:
        def replacer(match: re.Match[str]) -> str:
            token = f"ZZTOKEN{len(placeholders)}ZZ"
            placeholders.append(match.group(0))
            return token

        return re.sub(pattern, replacer, value)

    working = protect(r"`[^`]+`", working)
    working = protect(r"\{\{.*?\}\}", working)
    working = protect(r"\{%.*?%\}", working)
    working = protect(r"\]\((?:https?://|/)[^)]+\)", working)
    working = protect(r"https?://\S+", working)
    return working, placeholders


def restore_text(text: str, placeholders: list[str]) -> str:
    restored = text
    for index, original in enumerate(placeholders):
        restored = restored.replace(f"ZZTOKEN{index}ZZ", original)
    restored = restored.replace("La Piscina", "The Pool")
    restored = restored.replace("la piscina", "The Pool")
    restored = restored.replace("El Pool", "The Pool")
    restored = restored.replace("el Pool", "The Pool")
    return restored


def translate_texts(texts: list[str]) -> list[str]:
    translated = ["" for _ in texts]
    pending_values = []
    pending_meta = []

    for index, text in enumerate(texts):
        stripped = text.strip()
        if not stripped:
            translated[index] = text
            continue

        if stripped in TITLE_OVERRIDES:
            translated[index] = TITLE_OVERRIDES[stripped]
            continue

        if stripped in SECTION_TITLES:
            translated[index] = SECTION_TITLES[stripped]
            continue

        if stripped in cache:
            translated[index] = cache[stripped]
            continue

        protected, placeholders = protect_text(stripped)
        pending_values.append(protected)
        pending_meta.append((index, stripped, placeholders))

    if pending_values:
        start = 0
        while start < len(pending_values):
            end = start
            chunk_length = 0

            while end < len(pending_values):
                value = pending_values[end]
                separator_length = len(TRANSLATE_SEPARATOR) if end > start else 0
                if end > start and chunk_length + separator_length + len(value) > TRANSLATE_MAX_CHARS:
                    break
                chunk_length += separator_length + len(value)
                end += 1

            chunk_values = pending_values[start:end]
            chunk_meta = pending_meta[start:end]
            joined = TRANSLATE_SEPARATOR.join(chunk_values)
            params = urlencode(
                [
                    ("client", "gtx"),
                    ("sl", "en"),
                    ("tl", "es"),
                    ("dt", "t"),
                    ("q", joined),
                ]
            )
            url = f"https://translate.googleapis.com/translate_a/single?{params}"

            with urlopen(url, timeout=30) as response:
                payload = loads(response.read().decode("utf-8"))

            translated_joined = "".join(part[0] for part in payload[0])
            batch = translated_joined.split(TRANSLATE_SEPARATOR)

            if len(batch) != len(chunk_values):
                raise RuntimeError("Spanish docs translation batch returned an unexpected segment count")

            for (index, stripped, placeholders), value in zip(chunk_meta, batch):
                restored = restore_text(value, placeholders)
                translated[index] = restored
                cache[stripped] = restored

            start = end

    return translated


def translate_text(text: str) -> str:
    return translate_texts([text])[0]


def translate_table_row(line: str) -> str:
    parts = line.split("|")
    cells = []
    translatable_indexes = []

    for index, part in enumerate(parts):
        cells.append(part)
        if part and not re.fullmatch(r"\s*:?-{2,}:?\s*", part):
            translatable_indexes.append(index)

    translated_cells = translate_texts([parts[index] for index in translatable_indexes])
    for index, value in zip(translatable_indexes, translated_cells):
        cells[index] = value
    return "|".join(cells)


def rewrite_docs_links(text: str) -> str:
    text = text.replace("](/docs/", "](/es/docs/")
    text = text.replace("(/docs/", "(/es/docs/")
    text = text.replace('href="/docs/', 'href="/es/docs/')
    text = text.replace('"/docs/', '"/es/docs/')
    text = text.replace(" /docs/", " /es/docs/")
    return text


def translate_line(line: str) -> str:
    if line in BODY_OVERRIDES:
        return BODY_OVERRIDES[line]

    if re.fullmatch(r"\s*", line):
        return line

    if line.startswith("|"):
        return rewrite_docs_links(translate_table_row(line))

    patterns = [
        r"^(#{1,6}\s+)(.+)$",
        r"^(\s*[-*+]\s+)(.+)$",
        r"^(\s*\d+\.\s+)(.+)$",
        r"^(>\s+)(.+)$",
    ]

    for pattern in patterns:
        match = re.match(pattern, line)
        if match:
            return rewrite_docs_links(match.group(1) + translate_text(match.group(2)))

    return rewrite_docs_links(translate_text(line))


def translate_body(body: str) -> str:
    translated_lines = []
    in_fence = False
    fence_marker = ""
    pending_texts: list[str] = []
    pending_prefixes: list[str] = []

    def flush_pending() -> None:
        if not pending_texts:
            return

        for prefix, value in zip(pending_prefixes, translate_texts(pending_texts)):
            translated_lines.append(rewrite_docs_links(prefix + value))

        pending_texts.clear()
        pending_prefixes.clear()

    for line in body.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("```") or stripped.startswith("~~~"):
            flush_pending()
            marker = stripped[:3]
            if not in_fence:
                in_fence = True
                fence_marker = marker
            elif marker == fence_marker:
                in_fence = False
                fence_marker = ""
            translated_lines.append(line)
            continue

        if in_fence:
            translated_lines.append(line)
            continue

        if line in BODY_OVERRIDES:
            flush_pending()
            translated_lines.append(BODY_OVERRIDES[line])
            continue

        if re.fullmatch(r"\s*", line):
            flush_pending()
            translated_lines.append(line)
            continue

        if line.startswith("|"):
            flush_pending()
            translated_lines.append(rewrite_docs_links(translate_table_row(line)))
            continue

        patterns = [
            r"^(#{1,6}\s+)(.+)$",
            r"^(\s*[-*+]\s+)(.+)$",
            r"^(\s*\d+\.\s+)(.+)$",
            r"^(>\s+)(.+)$",
        ]

        matched = False
        for pattern in patterns:
            match = re.match(pattern, line)
            if match:
                pending_prefixes.append(match.group(1))
                pending_texts.append(match.group(2))
                matched = True
                break

        if matched:
            continue

        pending_prefixes.append("")
        pending_texts.append(line)

    flush_pending()
    return "\n".join(translated_lines) + "\n"


def load_front_matter(text: str) -> tuple[dict, str]:
    if not text.startswith("---\n"):
        return {}, text
    _, front_matter, body = text.split("---\n", 2)
    data = yaml.safe_load(front_matter) or {}
    return data, body


def dump_page(data: dict, body: str) -> str:
    front_matter = yaml.safe_dump(data, allow_unicode=True, sort_keys=False).strip()
    return f"---\n{front_matter}\n---\n{body}"


def translate_page(path: Path) -> None:
    relative_path = path.relative_to(SOURCE_DIR)
    target_path = TARGET_DIR / relative_path
    target_path.parent.mkdir(parents=True, exist_ok=True)

    data, body = load_front_matter(path.read_text())

    if "title" in data:
        data["title"] = translate_text(str(data["title"])).strip()
        if str(path.relative_to(ROOT)) == "docs/index.md":
            data["title"] = SECTION_TITLES["FAQ"]

    if "description" in data:
        data["description"] = translate_text(str(data["description"])).strip()

    if "parent" in data:
        parent = str(data["parent"])
        data["parent"] = SECTION_TITLES.get(parent, translate_text(parent).strip())

    data["lang"] = "es"

    translated_body = translate_body(body)
    target_path.write_text(dump_page(data, translated_body))


def main() -> int:
    if not SOURCE_DIR.exists():
        print("docs/ directory not found", file=sys.stderr)
        return 1

    TARGET_DIR.mkdir(parents=True, exist_ok=True)

    paths = sorted(SOURCE_DIR.rglob("*.md"))

    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = {executor.submit(translate_page, path): path for path in paths}
        for future in as_completed(futures):
            future.result()

    print(f"Built Spanish docs in {TARGET_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
