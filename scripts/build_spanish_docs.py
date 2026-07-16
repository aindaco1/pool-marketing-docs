#!/usr/bin/env python3

from __future__ import annotations

import re
import os
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from json import loads
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import urlopen

import yaml


ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "docs"
TARGET_DIR = ROOT / "es" / "docs"
POOL_ROOT = Path(os.environ.get("POOL_SOURCE", "/tmp/pool")).expanduser().resolve()

CURATED_SPANISH_SOURCES = {
    Path("overview/about-the-pool.md"): Path("es/about.md"),
    Path("overview/terms-and-guidelines.md"): Path("es/terms.md"),
}

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
    "Agents & Operator Guide": "Guía para agentes y operadores",
    "Pledge Worker": "Worker de promesas",
    "Podman Local Dev": "Desarrollo local con Podman",
    "Testing Guide": "Guía de pruebas",
    "Security Guide": "Guía de seguridad",
    "Security Test Suite": "Suite de pruebas de seguridad",
    "Merge Smoke Checklist": "Checklist de smoke tests antes del merge",
    "Admin Dashboard": "Panel de administración",
    "Changelog": "Registro de cambios",
    "Pull Request Template": "Plantilla de pull request",
    "Roadmap": "Hoja de ruta",
    "Internationalization (i18n)": "Internacionalización (i18n)",
    "Internationalization": "Internacionalización",
    "Developer Notes": "Notas para desarrolladores",
    "Contributing": "Cómo contribuir",
    "Workflows": "Flujos de trabajo",
    "Shipping": "Envíos",
    "Accessibility": "Accesibilidad",
    "Performance": "Rendimiento",
    "SEO": "SEO",
    "Payment Processor": "Procesador de pagos",
    "Email System": "Sistema de correo electrónico",
    "Backup, Restore, and Recovery": "Copias de seguridad, restauración y recuperación",
    "Ethical Risk Review": "Revisión de riesgos éticos",
    "Platform README": "README de la plataforma",
}

BODY_OVERRIDES = {
    "# FAQ": "# Preguntas frecuentes",
    "# Overview": "# Resumen",
    "# Development": "# Desarrollo",
    "# Operations": "# Operaciones",
    "# Reference": "# Referencia",
    "# AGENTS": "# Guía para agentes y operadores",
    "# Pool Backup, Restore, and Recovery": "# Copias de seguridad, restauración y recuperación de The Pool",
    "# Payment Processor": "# Procesador de pagos",
    "# Email System": "# Sistema de correo electrónico",
    "# Ethical Risk Review": "# Revisión de riesgos éticos",
    "**Open-source crowdfunding platform starter**": "**Base de plataforma de crowdfunding de código abierto**",
    "A static Jekyll + first-party cart site for all-or-nothing creative crowdfunding. Backers build a pledge in The Pool’s browser-owned cart, the Cloudflare Worker canonicalizes the contribution via `/checkout-intent/start`, and Stripe collects and saves card details through a secure on-site payment step so cards are only charged after a successful campaign reaches its deadline. A single checkout can include items from multiple campaigns; after webhook confirmation, the Worker fans that bundle out into separate campaign-scoped pledge records. If funded, the Worker scheduler dispatches batched settlement and charges pledges off-session. Supporters can optionally add a platform tip, manage pledges through order-scoped magic links, and revisit a desktop-friendly Manage Pledge dashboard with Active / Closed sections.": "Un sitio estático de Jekyll con un carrito propio para crowdfunding creativo de todo o nada. Los patrocinadores crean un aporte en el carrito de The Pool, el Worker de Cloudflare valida la contribución mediante `/checkout-intent/start` y Stripe recopila y guarda los datos de la tarjeta en un paso de pago seguro dentro del sitio, de modo que la tarjeta solo se cobra si una campaña exitosa alcanza su fecha límite. Una sola sesión de pago puede incluir artículos de varias campañas; tras la confirmación del webhook, el Worker distribuye ese paquete en registros de aporte separados por campaña. Si la campaña se financia, el programador del Worker envía la liquidación por lotes y cobra los aportes fuera de sesión. Los patrocinadores pueden añadir una propina opcional para la plataforma, gestionar sus aportes mediante enlaces mágicos limitados al pedido y volver a un panel de gestión de aportes optimizado para escritorio con secciones Activos y Cerrados.",
    "## Last Updated": "## Última actualización",
}

MONTH_OVERRIDES = {
    "January": "enero",
    "February": "febrero",
    "March": "marzo",
    "April": "abril",
    "May": "mayo",
    "June": "junio",
    "July": "julio",
    "August": "agosto",
    "September": "septiembre",
    "October": "octubre",
    "November": "noviembre",
    "December": "diciembre",
}

cache: dict[str, str] = {}
TRANSLATE_SEPARATOR = "\nZXQZXQPOOLBREAKZXQZXQ\n"
TRANSLATE_MAX_CHARS = int(os.environ.get("POOL_TRANSLATE_MAX_CHARS", "1200"))
TRANSLATE_TIMEOUT_SECONDS = float(os.environ.get("POOL_TRANSLATE_TIMEOUT_SECONDS", "15"))
TRANSLATE_RETRIES = int(os.environ.get("POOL_TRANSLATE_RETRIES", "3"))


def protect_text(text: str) -> tuple[str, list[str]]:
    working = text
    placeholders: list[str] = []

    def protect(pattern: str, value: str, replacement: str | None = None, flags: int = 0) -> str:
        def replacer(match: re.Match[str]) -> str:
            token = f"ZZTOKEN{len(placeholders)}ZZ"
            replacement_value = replacement or match.group(0)
            if replacement and match.group(0)[0].isupper():
                replacement_value = replacement_value[0].upper() + replacement_value[1:]
            placeholders.append(replacement_value)
            return token

        return re.sub(pattern, replacer, value, flags=flags)

    working = protect(r"`[^`]+`", working)
    working = protect(r"\{\{.*?\}\}", working)
    working = protect(r"\{%.*?%\}", working)
    working = protect(r"\]\((?:https?://|/)[^)]+\)", working)
    working = protect(r"https?://\S+", working)
    preferred_phrases = [
        (r"\bfans that bundle out into\b", "distribuye ese paquete en"),
        (r"\bplatform tips\b", "propinas de plataforma"),
        (r"\bplatform tip\b", "propina de plataforma"),
        (r"\bfans out\b", "se distribuye"),
        (r"\bfan out\b", "distribuirse"),
    ]
    for pattern, replacement in preferred_phrases:
        working = protect(pattern, working, replacement, flags=re.IGNORECASE)
    protected_terms = [
        "Cloudflare Workers",
        "GitHub Pages",
        "Durable Objects",
        "Durable Object",
        "Stripe Elements",
        "ZIP.TAX",
        "WYSIWYG",
        "Cloudflare",
        "Turnstile",
        "Wrangler",
        "GitHub",
        "Jekyll",
        "Podman",
        "Resend",
        "Stripe",
        "Worker",
        "Workers",
        "Blast",
        "Store",
        "USPS",
        "CSV",
        "KV",
        "QR",
        "SEO",
        "UTM",
        "Node.js",
        "Vitest",
        "Playwright",
        "Liquid",
        "Sass",
    ]
    working = protect(r"\bThe Pool\b", working)
    working = protect(r"\bPool\b", working, "The Pool")
    for term in protected_terms:
        working = protect(rf"\b{re.escape(term)}\b", working)
    return working, placeholders


def restore_text(text: str, placeholders: list[str]) -> str:
    restored = text
    for index, original in enumerate(placeholders):
        restored = restored.replace(f"ZZTOKEN{index}ZZ", original)
    restored = restored.replace("La Piscina", "The Pool")
    restored = restored.replace("La piscina", "The Pool")
    restored = restored.replace("la piscina", "The Pool")
    restored = restored.replace("El Pool", "The Pool")
    restored = restored.replace("el Pool", "The Pool")
    restored = re.sub(r"(\]\([^)]+\))\]", r"\1", restored)
    restored = re.sub(r"\bcompromiso de stock\b", "reserva de existencias", restored, flags=re.IGNORECASE)
    restored = re.sub(
        r"\bcompromisos\b",
        lambda match: "Aportes" if match.group(0)[0].isupper() else "aportes",
        restored,
        flags=re.IGNORECASE,
    )
    restored = re.sub(
        r"\bcompromiso\b",
        lambda match: "Aporte" if match.group(0)[0].isupper() else "aporte",
        restored,
        flags=re.IGNORECASE,
    )
    restored = re.sub(
        r"\bpromesas\b",
        lambda match: "Aportes" if match.group(0)[0].isupper() else "aportes",
        restored,
        flags=re.IGNORECASE,
    )
    restored = re.sub(
        r"\bpromesa\b",
        lambda match: "Aporte" if match.group(0)[0].isupper() else "aporte",
        restored,
        flags=re.IGNORECASE,
    )
    agreement_replacements = [
        (r"\ba la aporte\b", "al aporte"),
        (r"\bde la aporte\b", "del aporte"),
        (r"\blas aportes\b", "los aportes"),
        (r"\bla aporte\b", "el aporte"),
        (r"\bunas aportes\b", "unos aportes"),
        (r"\buna aporte\b", "un aporte"),
        (r"\bestas aportes\b", "estos aportes"),
        (r"\besta aporte\b", "este aporte"),
        (r"\besas aportes\b", "esos aportes"),
        (r"\besa aporte\b", "ese aporte"),
        (r"\botras aportes\b", "otros aportes"),
        (r"\botra aporte\b", "otro aporte"),
        (r"\baportes activas\b", "aportes activos"),
        (r"\baporte activa\b", "aporte activo"),
        (r"\baportes almacenadas\b", "aportes almacenados"),
        (r"\baporte almacenada\b", "aporte almacenado"),
        (r"\baportes guardadas\b", "aportes guardados"),
        (r"\baporte guardada\b", "aporte guardado"),
        (r"\baportes cargadas\b", "aportes cargados"),
        (r"\baporte cargada\b", "aporte cargado"),
        (r"\baportes canceladas\b", "aportes cancelados"),
        (r"\baporte cancelada\b", "aporte cancelado"),
        (r"\baportes modificadas\b", "aportes modificados"),
        (r"\baporte modificada\b", "aporte modificado"),
        (r"\bun propina\b", "una propina"),
        (r"\bunos propinas\b", "unas propinas"),
        (r"\bel propina\b", "la propina"),
        (r"\blos propinas\b", "las propinas"),
    ]
    for pattern, replacement in agreement_replacements:
        restored = re.sub(pattern, replacement, restored, flags=re.IGNORECASE)
    restored = re.sub(r"\breserva de existencias físico\b", "reserva de existencias física", restored, flags=re.IGNORECASE)
    restored = re.sub(
        r"\b(?:seguidores|partidarios)\b",
        lambda match: "Patrocinadores" if match.group(0)[0].isupper() else "patrocinadores",
        restored,
        flags=re.IGNORECASE,
    )
    restored = re.sub(
        r"\b(?:seguidor|partidario)\b",
        lambda match: "Patrocinador" if match.group(0)[0].isupper() else "patrocinador",
        restored,
        flags=re.IGNORECASE,
    )
    return restored


def translate_date_line(text: str) -> str | None:
    match = re.fullmatch(r"([A-Za-z]+) ([0-9]{1,2}), ([0-9]{4})", text.strip())
    if not match:
        return None

    month, day, year = match.groups()
    translated_month = MONTH_OVERRIDES.get(month)
    if translated_month is None:
        return None

    return f"{int(day)} de {translated_month} de {year}"


def translate_texts(texts: list[str]) -> list[str]:
    translated = ["" for _ in texts]
    pending_values = []
    pending_meta = []

    for index, text in enumerate(texts):
        stripped = text.strip()
        if not stripped:
            translated[index] = text
            continue

        translated_date = translate_date_line(stripped)
        if translated_date is not None:
            translated[index] = translated_date
            continue

        if stripped in TITLE_OVERRIDES:
            translated[index] = TITLE_OVERRIDES[stripped]
            continue

        if stripped in SECTION_TITLES:
            translated[index] = SECTION_TITLES[stripped]
            continue

        if stripped in cache:
            translated[index] = restore_text(cache[stripped], [])
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

            last_error = None
            payload = None
            for attempt in range(TRANSLATE_RETRIES):
                try:
                    with urlopen(url, timeout=TRANSLATE_TIMEOUT_SECONDS) as response:
                        payload = loads(response.read().decode("utf-8"))
                    break
                except Exception as error:  # noqa: BLE001
                    last_error = error
                    if attempt == TRANSLATE_RETRIES - 1:
                        raise
                    time.sleep(min(2**attempt, 5))

            if payload is None and last_error is not None:
                raise last_error

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
    if re.match(r"^#{1,6}\s+(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)\s+/\S+", line):
        return line

    if re.fullmatch(r"\s*\{:[^}]+\}\s*", line):
        return line

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

        if re.match(r"^#{1,6}\s+(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)\s+/\S+", line):
            flush_pending()
            translated_lines.append(line)
            continue

        if re.fullmatch(r"\s*\{:[^}]+\}\s*", line):
            flush_pending()
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


def curated_spanish_body(relative_path: Path, english_body: str) -> str | None:
    source_relative_path = CURATED_SPANISH_SOURCES.get(relative_path)
    if source_relative_path is None:
        return None

    source_path = POOL_ROOT / source_relative_path
    if not source_path.is_file():
        return None

    _, body = load_front_matter(source_path.read_text())
    body = re.sub(r"^\{% assign .+? %\}\n?", "", body, flags=re.MULTILINE)
    body = re.sub(r"\n_Última actualización:.*?_\s*\Z", "\n", body)
    body = body.replace(
        "**The Pool** es la plataforma de crowdfunding de código abierto de {{ operator_name }} para",
        "**The Pool** es una plataforma de crowdfunding de código abierto para",
    )
    body = body.replace(
        "ayudar a {{ operator_name }} a operar el servicio",
        "ayudar a operar el servicio",
    )
    body = body.replace("{{ operator_name }}", "la persona operadora de la plataforma")
    body = body.replace(
        "[{{ support_email }}](mailto:{{ support_email }})",
        "[support@example.com](mailto:support@example.com)",
    )
    body = body.replace(
        "{% include localized-url.html lang=page.lang translation_key='terms' %}#returns-refunds",
        "/es/docs/overview/terms-and-guidelines/#returns-refunds",
    )
    body = body.replace(
        "{% include localized-url.html lang=page.lang translation_key='terms' %}#shipping-policy",
        "/es/docs/overview/terms-and-guidelines/#shipping-policy",
    )

    date_match = re.search(r"^## Last Updated\n\n([^\n]+)", english_body, flags=re.MULTILINE)
    translated_date = translate_date_line(date_match.group(1)) if date_match else None
    if translated_date:
        lines = body.splitlines()
        h1_index = next((index for index, line in enumerate(lines) if line.startswith("# ")), None)
        if h1_index is not None:
            insert_index = h1_index + 1
            while insert_index < len(lines) and not lines[insert_index].strip():
                lines.pop(insert_index)
            lines[insert_index:insert_index] = [
                "",
                "## Última actualización",
                "",
                translated_date,
                "",
            ]
            body = "\n".join(lines) + "\n"

    return body


def committed_text(relative_path: Path) -> str | None:
    result = subprocess.run(
        ["git", "show", f"HEAD:{relative_path.as_posix()}"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    return result.stdout if result.returncode == 0 else None


def cache_translation_pair(source: str, target: str) -> None:
    source_value = source.strip()
    target_value = target.strip()
    if source_value and target_value and source_value not in cache:
        cache[source_value] = target_value


def seed_cache_from_committed_docs() -> None:
    """Reuse prior translations for unchanged lines during a docs sync."""

    for target_path in sorted(TARGET_DIR.rglob("*.md")):
        relative_path = target_path.relative_to(TARGET_DIR)
        source_text = committed_text(Path("docs") / relative_path)
        target_text = committed_text(Path("es/docs") / relative_path)
        if source_text is None or target_text is None:
            continue

        _, source_body = load_front_matter(source_text)
        _, target_body = load_front_matter(target_text)
        source_lines = source_body.splitlines()
        target_lines = target_body.splitlines()
        if len(source_lines) != len(target_lines):
            continue

        in_fence = False
        fence_marker = ""
        patterns = [
            r"^(#{1,6}\s+)(.+)$",
            r"^(\s*[-*+]\s+)(.+)$",
            r"^(\s*\d+\.\s+)(.+)$",
            r"^(>\s+)(.+)$",
        ]

        for source_line, target_line in zip(source_lines, target_lines):
            stripped = source_line.lstrip()
            if stripped.startswith("```") or stripped.startswith("~~~"):
                marker = stripped[:3]
                if not in_fence:
                    in_fence = True
                    fence_marker = marker
                elif marker == fence_marker:
                    in_fence = False
                    fence_marker = ""
                continue

            if in_fence or not source_line.strip() or not target_line.strip():
                continue

            if source_line.startswith("|") and target_line.startswith("|"):
                source_cells = source_line.split("|")
                target_cells = target_line.split("|")
                if len(source_cells) == len(target_cells):
                    for source_cell, target_cell in zip(source_cells, target_cells):
                        if not re.fullmatch(r"\s*:?-{2,}:?\s*", source_cell):
                            cache_translation_pair(source_cell, target_cell)
                continue

            paired = False
            for pattern in patterns:
                source_match = re.match(pattern, source_line)
                target_match = re.match(pattern, target_line)
                if source_match and target_match:
                    cache_translation_pair(source_match.group(2), target_match.group(2))
                    paired = True
                    break

            if not paired:
                cache_translation_pair(source_line, target_line)


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

    translated_body = (curated_spanish_body(relative_path, body) or translate_body(body)).rstrip() + "\n"
    target_path.write_text(dump_page(data, translated_body))


def main() -> int:
    if not SOURCE_DIR.exists():
        print("docs/ directory not found", file=sys.stderr)
        return 1

    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    seed_cache_from_committed_docs()

    requested_files = {
        value.strip()
        for value in os.environ.get("POOL_TRANSLATION_FILES", "").split(",")
        if value.strip()
    }

    paths = sorted(SOURCE_DIR.rglob("*.md"))
    if requested_files:
        paths = [
            path
            for path in paths
            if str(path.relative_to(ROOT)) in requested_files
            or str(path.relative_to(SOURCE_DIR)) in requested_files
        ]

    max_workers = max(1, int(os.environ.get("POOL_TRANSLATION_WORKERS", "1")))

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(translate_page, path): path for path in paths}
        for future in as_completed(futures):
            future.result()

    print(f"Built Spanish docs in {TARGET_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
