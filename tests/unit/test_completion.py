#!/usr/bin/env python3
"""Tests for completion cache helpers."""

import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.completion import command_cache_content, write_command_cache
from utils.registry import COMMANDS


class TestCompletionCache(unittest.TestCase):
    def test_command_cache_content_contains_registered_command(self):
        content = command_cache_content()
        self.assertTrue(content.endswith("\n"))
        self.assertIn("completion:cache", content.split())
        self.assertIn("commands", content.split())

    def test_write_command_cache(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            target = Path(tmpdir) / "commands"
            result = write_command_cache(target)
            self.assertEqual(target, result)
            self.assertTrue(target.exists())
            self.assertEqual(command_cache_content(), target.read_text(encoding="utf-8"))

    def test_completion_cache_command_registered(self):
        self.assertIn("completion:cache", COMMANDS)


if __name__ == "__main__":
    unittest.main(verbosity=2)
