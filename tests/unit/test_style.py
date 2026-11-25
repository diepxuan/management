#!/usr/bin/env python3
"""Tests for style.py — ANSI palette + status glyphs (salvaged bash env files)."""
import os
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import style


class TestPaletteConstants(unittest.TestCase):
    def test_base_colours_are_ansi_sequences(self):
        for name in ("RED", "GREEN", "YELLOW", "BLUE", "PURPLE", "CYAN", "WHITE", "BLACK"):
            value = getattr(style, name)
            self.assertTrue(value.startswith("\033["), f"{name} không phải ANSI")
            self.assertTrue(value.endswith("m"), f"{name} thiếu hậu tố m")

    def test_bold_and_underline_variants(self):
        self.assertEqual(style.B_GREEN, "\033[1;32m")
        self.assertEqual(style.U_RED, "\033[4;31m")

    def test_background_variants(self):
        self.assertEqual(style.ON_RED, "\033[41m")
        self.assertEqual(style.ON_WHITE, "\033[47m")

    def test_reset_is_zero(self):
        self.assertEqual(style.RESET, "\033[0m")
        self.assertEqual(style.NC, style.RESET)

    def test_glyphs(self):
        self.assertEqual(style.GLYPH_TRUE, "\u2713")
        self.assertEqual(style.GLYPH_FALSE, "\u2717")


class TestColorEnabled(unittest.TestCase):
    def test_disabled_when_no_color_set(self):
        with patch.dict(os.environ, {"NO_COLOR": "1"}, clear=False):
            self.assertFalse(style.color_enabled())

    def test_disabled_when_ductn_no_color_set(self):
        with patch.dict(os.environ, {"DUCTN_NO_COLOR": "1"}, clear=False):
            self.assertFalse(style.color_enabled())

    def test_disabled_when_not_a_tty(self):
        with patch.dict(os.environ, {}, clear=True), patch(
            "sys.stdout.isatty", return_value=False
        ):
            self.assertFalse(style.color_enabled())

    def test_enabled_on_tty(self):
        with patch.dict(os.environ, {}, clear=True), patch(
            "sys.stdout.isatty", return_value=True
        ):
            self.assertTrue(style.color_enabled())


class TestHelpers(unittest.TestCase):
    def test_c_wraps_when_colour_enabled(self):
        with patch.object(style, "color_enabled", return_value=True):
            self.assertEqual(style.c("hi", style.RED), f"{style.RED}hi{style.RESET}")

    def test_c_passthrough_when_disabled(self):
        with patch.object(style, "color_enabled", return_value=False):
            self.assertEqual(style.c("hi", style.RED), "hi")

    def test_ok_markers(self):
        with patch.object(style, "color_enabled", return_value=True):
            self.assertEqual(style.ok("done"), f"{style.TXT_TRUE} done")
        with patch.object(style, "color_enabled", return_value=False):
            self.assertEqual(style.ok("done"), "[v] done")

    def test_fail_markers(self):
        with patch.object(style, "color_enabled", return_value=True):
            self.assertEqual(style.fail("bad"), f"{style.TXT_FALSE} bad")
        with patch.object(style, "color_enabled", return_value=False):
            self.assertEqual(style.fail("bad"), "[x] bad")

    def test_info_markers(self):
        with patch.object(style, "color_enabled", return_value=True):
            self.assertEqual(style.info("note"), f"{style.TXT_INFO} note")
        with patch.object(style, "color_enabled", return_value=False):
            self.assertEqual(style.info("note"), "[i] note")

    def test_legacy_aliases(self):
        """Bash dùng $TXTtrue/$TXTfalse/$TXTinfo — giữ alias cho tương thích."""
        self.assertEqual(style.TXTtrue, style.TXT_TRUE)
        self.assertEqual(style.TXTfalse, style.TXT_FALSE)
        self.assertEqual(style.TXTinfo, style.TXT_INFO)


if __name__ == "__main__":
    unittest.main(verbosity=2)
