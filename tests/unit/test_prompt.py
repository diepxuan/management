#!/usr/bin/env python3
"""Tests for the `ductn prompt` CLI helper."""
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import prompt


class TestPrompt(unittest.TestCase):
    def test_opt_out_path_uses_xdg_config_home(self):
        with patch.dict(os.environ, {"XDG_CONFIG_HOME": "/custom/cfg"}):
            self.assertEqual(prompt._opt_out_path(), Path("/custom/cfg/ductn/no-prompt"))

    def test_opt_out_path_defaults_to_home_dotconfig(self):
        with patch.dict(os.environ, {}, clear=False):
            os.environ.pop("XDG_CONFIG_HOME", None)
            self.assertEqual(prompt._opt_out_path(), Path.home() / ".config" / "ductn" / "no-prompt")

    def test_conffile_exists_true(self):
        with patch.object(Path, "is_file", return_value=True):
            self.assertTrue(prompt._conffile_exists())

    def test_conffile_exists_false(self):
        with patch.object(Path, "is_file", return_value=False):
            self.assertFalse(prompt._conffile_exists())

    def test_status_enabled(self):
        with patch.object(prompt, "_conffile_exists", return_value=True), \
             patch.object(Path, "exists", return_value=False), \
             patch.dict(os.environ, {}, clear=False):
            os.environ.pop("DUCTN_PROMPT_DISABLE", None)
            # rc 0 means enabled
            self.assertEqual(0, prompt.d_prompt(["status"]))

    def test_status_disabled_by_optout(self):
        with patch.object(prompt, "_conffile_exists", return_value=True), \
             patch.object(Path, "exists", return_value=True), \
             patch.dict(os.environ, {}, clear=False):
            os.environ.pop("DUCTN_PROMPT_DISABLE", None)
            self.assertEqual(1, prompt.d_prompt(["status"]))

    def test_status_disabled_by_env(self):
        with patch.object(prompt, "_conffile_exists", return_value=True), \
             patch.object(Path, "exists", return_value=False), \
             patch.dict(os.environ, {"DUCTN_PROMPT_DISABLE": "1"}):
            self.assertEqual(1, prompt.d_prompt(["status"]))

    def test_status_disabled_when_conffile_missing(self):
        with patch.object(prompt, "_conffile_exists", return_value=False), \
             patch.object(Path, "exists", return_value=False), \
             patch.dict(os.environ, {}, clear=False):
            os.environ.pop("DUCTN_PROMPT_DISABLE", None)
            self.assertEqual(1, prompt.d_prompt(["status"]))

    def test_enable_removes_optout(self):
        with tempfile.TemporaryDirectory() as td:
            opt = Path(td) / "ductn" / "no-prompt"
            opt.parent.mkdir(parents=True, exist_ok=True)
            opt.write_text("")
            with patch.object(prompt, "_opt_out_path", return_value=opt):
                rc = prompt.d_prompt(["enable"])
            self.assertEqual(0, rc)
            self.assertFalse(opt.exists())

    def test_enable_no_op_when_missing(self):
        with tempfile.TemporaryDirectory() as td:
            opt = Path(td) / "ductn" / "no-prompt"
            with patch.object(prompt, "_opt_out_path", return_value=opt):
                rc = prompt.d_prompt(["enable"])
            self.assertEqual(0, rc)
            self.assertFalse(opt.exists())

    def test_disable_creates_optout(self):
        with tempfile.TemporaryDirectory() as td:
            opt = Path(td) / "ductn" / "no-prompt"
            self.assertFalse(opt.exists())
            with patch.object(prompt, "_opt_out_path", return_value=opt):
                rc = prompt.d_prompt(["disable"])
            self.assertEqual(0, rc)
            self.assertTrue(opt.exists())

    def test_unknown_subcommand_returns_2(self):
        with patch("sys.stderr") as fake_err:
            rc = prompt.d_prompt(["bogus"])
        self.assertEqual(2, rc)
        fake_err.write.assert_called()

    def test_help_subcommand(self):
        rc = prompt.d_prompt(["--help"])
        self.assertEqual(0, rc)

    def test_default_subcommand_is_status(self):
        with patch.object(prompt, "_print_status", return_value=0) as mock_status:
            rc = prompt.d_prompt([])
        self.assertEqual(0, rc)
        mock_status.assert_called_once_with()


if __name__ == "__main__":
    unittest.main()