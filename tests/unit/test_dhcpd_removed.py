#!/usr/bin/env python3
"""Test DHCPD commands are removed from Python CLI registry."""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))


class TestDhcpdRemoved(unittest.TestCase):
    """Đảm bảo nhóm DHCPD command không còn expose trong Python CLI."""

    def test_dhcp_commands_not_registered(self):
        from utils.registry import COMMANDS

        dhcp_commands = [cmd for cmd in COMMANDS if cmd.startswith("dhcp:") or cmd.startswith("sys:dhcp:")]
        self.assertEqual([], dhcp_commands)

    def test_dhcpd_module_removed(self):
        dhcpd_module = os.path.join(
            os.path.dirname(__file__), "..", "..", "src", "utils", "dhcpd.py"
        )
        self.assertFalse(os.path.exists(dhcpd_module))


if __name__ == "__main__":
    unittest.main(verbosity=2)
