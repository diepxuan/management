#!/usr/bin/env python3
"""Test VPN commands are removed from Python CLI registry."""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))


class TestVpnRemoved(unittest.TestCase):
    """Đảm bảo nhóm VPN command không còn expose trong Python CLI."""

    def test_vpn_commands_not_registered(self):
        from utils.registry import COMMANDS

        vpn_commands = [cmd for cmd in COMMANDS if cmd.startswith("vpn:")]
        self.assertEqual([], vpn_commands)

    def test_vpn_module_removed(self):
        vpn_module = os.path.join(
            os.path.dirname(__file__), "..", "..", "src", "utils", "vpn.py"
        )
        self.assertFalse(os.path.exists(vpn_module))


if __name__ == "__main__":
    unittest.main(verbosity=2)
