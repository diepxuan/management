#!/usr/bin/env python3
"""Tests for professional CLI output."""
import io
import os
import sys
import unittest
from contextlib import redirect_stdout, redirect_stderr
from unittest.mock import patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

import ductn
from utils import about
from utils.command import _commands_by_group


class TestCliOutput(unittest.TestCase):
    def run_cli(self, argv):
        stdout = io.StringIO()
        stderr = io.StringIO()
        with patch.object(sys, "argv", ["ductn"] + argv), redirect_stdout(stdout), redirect_stderr(stderr):
            with self.assertRaises(SystemExit) as ctx:
                ductn.main()
        return ctx.exception.code, stdout.getvalue(), stderr.getvalue()

    def test_no_args_prints_professional_help_without_huge_choices_blob(self):
        code, stdout, stderr = self.run_cli([])
        output = stdout + stderr

        self.assertEqual(code, 0)
        self.assertIn("ductn", output)
        self.assertIn("Usage:", output)
        self.assertIn("Common commands:", output)
        self.assertIn("Command groups:", output)
        self.assertIn("Run `ductn help`", output)
        self.assertNotIn("{update,commands,help,version", output)

    def test_unknown_command_prints_clean_error(self):
        code, stdout, stderr = self.run_cli(["does:not:exist"])
        output = stdout + stderr

        self.assertEqual(code, 2)
        self.assertIn("Unknown command: does:not:exist", output)
        self.assertIn("Run `ductn commands`", output)
        self.assertNotIn("invalid choice", output)
        self.assertNotIn("{update,commands,help,version", output)

    def test_help_command_groups_commands(self):
        stdout = io.StringIO()
        with redirect_stdout(stdout):
            about.d_help()
        output = stdout.getvalue()

        self.assertIn("Command groups", output)
        self.assertIn("apt", output)
        self.assertIn("apt:check", output)
        self.assertIn("ssh", output)
        self.assertIn("ssh:cleanup", output)
        self.assertNotIn("zfs:disk:format👢disk", output)

    def test_commands_by_group_returns_grouped_commands(self):
        grouped = _commands_by_group()
        self.assertIn("apt", grouped)
        self.assertIn("apt:check", grouped["apt"])
        self.assertIn("ssh", grouped)
        self.assertIn("ssh:cleanup", grouped["ssh"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
