#!/usr/bin/env python3
"""Test MySQL commands are removed from Python CLI registry."""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))


class TestMysqlRemoved(unittest.TestCase):
    """Đảm bảo nhóm MySQL command không còn expose trong Python CLI."""

    def test_mysql_commands_not_registered(self):
        from utils.registry import COMMANDS

        mysql_commands = [cmd for cmd in COMMANDS if cmd.startswith("mysql:")]
        self.assertEqual([], mysql_commands)

    def test_mysql_module_removed(self):
        mysql_module = os.path.join(
            os.path.dirname(__file__), "..", "..", "src", "utils", "mysql_utils.py"
        )
        self.assertFalse(os.path.exists(mysql_module))


if __name__ == "__main__":
    unittest.main(verbosity=2)
