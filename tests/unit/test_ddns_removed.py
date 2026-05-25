#!/usr/bin/env python3
"""Test DDNS commands are removed from Python CLI registry."""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))


class TestDdnsRemoved(unittest.TestCase):
    """Đảm bảo nhóm DDNS command không còn expose trong Python CLI."""

    def test_ddns_commands_not_registered(self):
        from utils.registry import COMMANDS

        ddns_commands = [cmd for cmd in COMMANDS if cmd.startswith("ddns:")]
        self.assertEqual([], ddns_commands)

    def test_ddns_module_removed(self):
        ddns_module = os.path.join(
            os.path.dirname(__file__), "..", "..", "src", "utils", "ddns.py"
        )
        self.assertFalse(os.path.exists(ddns_module))


if __name__ == "__main__":
    unittest.main(verbosity=2)
