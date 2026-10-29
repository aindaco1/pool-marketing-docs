#!/usr/bin/env python3
"""Offline checks for source ownership and localized documentation links."""
import re
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import build_spanish_docs as docs


class SpanishDocsTest(unittest.TestCase):
    def test_reviewed_copy_overrides_stale_machine_cache(self):
        source = next(text for text in docs.REVIEWED_TRANSLATIONS if text.startswith("Each run uses the existing Pool"))
        with patch.object(docs, "cache", {source: "destinatario de edad"}), patch.object(docs, "request_translation", side_effect=AssertionError("Network call")):
            translated = docs.translate_text(source)
        self.assertIn("destinatario age", translated)
        self.assertNotIn("destinatario de edad", translated)

    def test_reviewed_copy_preserves_inline_code(self):
        for source, translated in docs.REVIEWED_TRANSLATIONS.items():
            for code in re.findall(r"`[^`]+`", source):
                with self.subTest(source=source[:80], code=code):
                    self.assertIn(code, translated)

    def test_reviewed_wrapped_list_keeps_nested_items_and_code_separate(self):
        source = "- Preserve the saved\n  payment identity.\n  - Nested item\n\n```text\n- Preserve the saved\n  payment identity.\n```\n"
        expected = "- Conservar la identidad de pago guardada.\n  - Nested item\n\n```text\n- Preserve the saved\n  payment identity.\n```\n"
        with patch.object(docs, "REVIEWED_TRANSLATIONS", {"Preserve the saved payment identity.": "Conservar la identidad de pago guardada."}), patch.object(docs, "cache", {"Nested item": "Nested item"}), patch.object(docs, "request_translation", side_effect=AssertionError("Network call")):
            self.assertEqual(expected, docs.translate_body(source))

    def test_curated_policy_requires_the_selected_source(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(docs, "POOL_ROOT", Path(directory)):
                with self.assertRaisesRegex(FileNotFoundError, "Required curated Spanish source"):
                    docs.curated_spanish_body(Path("overview/terms-and-guidelines.md"), "# Terms")

    def test_curated_policy_preserves_source_copy_and_policy_anchor(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "es").mkdir()
            (root / "es/terms.md").write_text(
                "# Términos\n\nCopy from the selected source.\n\n"
                "[Policy]({% include localized-url.html lang=page.lang translation_key='terms' %}#shipping-policy)\n"
            )
            with patch.object(docs, "POOL_ROOT", root):
                body = docs.curated_spanish_body(
                    Path("overview/terms-and-guidelines.md"),
                    "# Terms\n\n## Last Updated\n\nSeptember 6, 2026\n",
                )
            self.assertIn("Copy from the selected source.", body)
            self.assertIn("/es/docs/overview/terms-and-guidelines/#shipping-policy", body)
            self.assertIn("6 de septiembre de 2026", body)

    def test_wrapped_prose_is_translated_as_a_complete_paragraph(self):
        source = "This guide covers shared development\npatterns and ownership.\n\n- First item\n- Second item\n\n```text\nkeep\nthese lines\n```\n"
        expected = "This guide covers shared development patterns and ownership.\n\n- First item\n- Second item\n\n```text\nkeep\nthese lines\n```\n"
        self.assertEqual(expected, docs.unwrap_prose(source))

    def test_code_only_source_links_do_not_require_translation(self):
        source = "[`worker/src/index.js`](https://github.com/aindaco1/pool/blob/main/worker/src/index.js)"
        with patch.object(docs, "cache", {}), patch.object(docs, "request_translation", side_effect=AssertionError("Network call")):
            self.assertEqual(source, docs.translate_text(source))

    def test_wrapped_paragraph_preserves_curated_roadmap_contract(self):
        source = "This document contains prospective work only.\nThe current product has separate guides.\n"
        with patch.object(docs, "translate_texts", return_value=["El producto actual tiene guías separadas."]):
            translated = docs.translate_body(source)
        self.assertIn("Este documento contiene únicamente trabajo prospectivo.", translated)

    def test_links_and_code_keep_their_contracts(self):
        self.assertEqual(
            "[Data](/es/docs/operations/payment-processor/#modelo-de-datos)",
            docs.rewrite_docs_links("[Data](/docs/operations/payment-processor/#data-model)"),
        )
        self.assertEqual(
            "[Media](/es/docs/operations/performance/#media-library)",
            docs.rewrite_docs_links("[Media](/docs/operations/performance/#media-library)"),
        )
        self.assertEqual(
            "[API](/es/docs/reference/worker-api/#routes)",
            docs.rewrite_docs_links("[API](/docs/reference/worker-api/#routes)"),
        )
        body = "### GET or POST /campaign-email/unsubscribe?t={token}\n\n### POST /checkout-intent/start\n\n```json\n{\"token\": \"example\"}\n```\n"
        with patch.object(docs, "request_translation", side_effect=AssertionError("Network call")):
            self.assertEqual(body, docs.translate_body(body))


if __name__ == "__main__":
    unittest.main()
