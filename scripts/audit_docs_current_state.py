#!/usr/bin/env python3
"""Reject stale status language and incomplete generated documentation."""
from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
SPANISH_DOCS = ROOT / "es" / "docs"
CURRENT_STATE_EXCLUSIONS = {
    DOCS / "reference" / "changelog.md",
    DOCS / "reference" / "roadmap.md",
}
SPANISH_CURRENT_STATE_EXCLUSIONS = {
    SPANISH_DOCS / "reference" / "changelog.md",
    SPANISH_DOCS / "reference" / "roadmap.md",
}

FORBIDDEN_CURRENT_STATE = {
    "completed-work heading": re.compile(r"^##\s+Completed\s*$", re.I | re.M),
    "future-feature inventory heading": re.compile(r"^##\s+Future Features\s*$", re.I | re.M),
    "known-issues inventory heading": re.compile(r"^##\s+Known Issues\s*$", re.I | re.M),
    "vulnerability ledger heading": re.compile(r"^##\s+Vulnerability Summary\s*$", re.I | re.M),
    "follow-up ledger heading": re.compile(
        r"^##\s+(?:Accepted Tradeoffs\s*/\s*Follow-Up Candidates|Current Follow-Up Work|Remaining Follow-Up|Next Likely Steps)\s*$",
        re.I | re.M,
    ),
    "release review ledger": re.compile(r"^##\s+v?\d[^\n]*Review Record\s*$", re.I | re.M),
    "legacy roadmap description": re.compile(r"roadmap[^\n]*completed work, planned features, and known issues", re.I),
    "legacy security description": re.compile(r"security[^\n]*vulnerability history", re.I),
    "legacy contributor description": re.compile(r"contributing[^\n]*current project status", re.I),
    "translation placeholder leak": re.compile(
        r"ZZTOKEN|ZXQZXQ|ZXC[A-Z0-9]+ZX|BEGIN SOURCE|END SOURCE",
        re.I,
    ),
}

FORBIDDEN_SPANISH_CURRENT_STATE = {
    "completed-work heading": re.compile(r"^##\s+(?:Terminado|Completado)\s*$", re.I | re.M),
    "future-feature inventory heading": re.compile(r"^##\s+(?:Características|Funciones) futuras\s*$", re.I | re.M),
    "known-issues inventory heading": re.compile(r"^##\s+Problemas conocidos\s*$", re.I | re.M),
    "vulnerability ledger heading": re.compile(r"^##\s+Resumen de vulnerabilidad(?:es)?\s*$", re.I | re.M),
    "follow-up ledger heading": re.compile(
        r"^##\s+(?:Trabajo de seguimiento actual|Seguimiento restante|Próximos pasos probables)\s*$",
        re.I | re.M,
    ),
    "release review ledger": re.compile(r"^##\s+Registro de revisión[^\n]*$", re.I | re.M),
    "legacy roadmap description": re.compile(
        r"hoja de ruta[^\n]*(?:trabajo completado|funciones planificadas|problemas conocidos)",
        re.I,
    ),
    "legacy security description": re.compile(r"seguridad[^\n]*historial de vulnerabilidades", re.I),
    "legacy contributor description": re.compile(r"contribu[^\n]*estado actual del proyecto", re.I),
    "translation placeholder leak": re.compile(
        r"ZZTOKEN|ZXQZXQ|ZXC[A-Z0-9]+ZX|BEGIN SOURCE|END SOURCE|FIN DOCUMENTOS",
        re.I,
    ),
}

REQUIRED_DOCS = {
    Path("development/product-video-workflow.md"),
    Path("development/architecture.md"),
    Path("development/content-model.md"),
    Path("operations/deployment.md"),
    Path("reference/worker-api.md"),
    Path("operations/tax-calculator.md"),
    Path("reference/source-map.md"),
}


def relative(path: Path) -> str:
    return str(path.relative_to(ROOT))


def add_pattern_errors(
    docs_root: Path,
    exclusions: set[Path],
    patterns: dict[str, re.Pattern[str]],
    errors: list[str],
) -> None:
    if not docs_root.exists():
        errors.append(f"{relative(docs_root)} directory is missing")
        return

    for path in sorted(docs_root.rglob("*.md")):
        if path in exclusions or "maintainers" in path.relative_to(docs_root).parts:
            continue
        body = path.read_text(errors="replace")
        for label, pattern in patterns.items():
            match = pattern.search(body)
            if match:
                line = body.count("\n", 0, match.start()) + 1
                errors.append(f"{relative(path)}:{line}: {label}")


def audit_roadmap(path: Path, contract: str, errors: list[str]) -> None:
    if not path.exists():
        errors.append(f"{relative(path)} is missing")
        return

    body = path.read_text(errors="replace")
    if contract not in body:
        errors.append(f"{relative(path)}: missing prospective-work contract")
    if re.search(r"^- \[x\]", body, re.I | re.M):
        errors.append(f"{relative(path)}: contains completed checklist work")


def audit_tree_parity(errors: list[str]) -> None:
    english = {path.relative_to(DOCS) for path in DOCS.rglob("*.md") if "maintainers" not in path.relative_to(DOCS).parts}
    spanish = {path.relative_to(SPANISH_DOCS) for path in SPANISH_DOCS.rglob("*.md")}

    for path in sorted(english - spanish):
        errors.append(f"es/docs/{path}: missing Spanish page")
    for path in sorted(spanish - english):
        errors.append(f"es/docs/{path}: has no English source page")
    for path in sorted(REQUIRED_DOCS - english):
        errors.append(f"docs/{path}: required generated page is missing")


def main() -> int:
    errors: list[str] = []
    add_pattern_errors(DOCS, CURRENT_STATE_EXCLUSIONS, FORBIDDEN_CURRENT_STATE, errors)
    add_pattern_errors(
        SPANISH_DOCS,
        SPANISH_CURRENT_STATE_EXCLUSIONS,
        FORBIDDEN_SPANISH_CURRENT_STATE,
        errors,
    )
    audit_roadmap(
        DOCS / "reference" / "roadmap.md",
        "This document contains prospective work only.",
        errors,
    )
    audit_roadmap(
        SPANISH_DOCS / "reference" / "roadmap.md",
        "Este documento contiene únicamente trabajo prospectivo.",
        errors,
    )
    audit_tree_parity(errors)
    site = ROOT / "_site"
    if site.exists():
        for excluded in ("docs/maintainers", "scripts", "README.md", "LICENSE", "ROADMAP.md", "design-qa.md"):
            if (site / excluded).exists():
                errors.append(f"_site/{excluded}: repository-only material leaked into the public build")

    if errors:
        print("Current-state documentation audit failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Current-state documentation audit passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
