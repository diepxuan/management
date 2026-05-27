#!/usr/bin/env python3
"""Test ssh.py: SSH helper functions."""
import sys
import os
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.ssh import _fix_ssh_permissions


class TestSshPermissions(unittest.TestCase):
    """Tests cho hàm _fix_ssh_permissions."""

    @patch("utils.ssh.os.path.expanduser")
    def test_creates_ssh_dir(self, mock_expanduser):
        """Tạo .ssh directory nếu chưa có."""
        with tempfile.TemporaryDirectory() as tmpdir:
            ssh_dir = os.path.join(tmpdir, ".ssh")
            mock_expanduser.return_value = ssh_dir

            _fix_ssh_permissions()

            self.assertTrue(os.path.exists(ssh_dir))
            mode = oct(os.stat(ssh_dir).st_mode)[-3:]
            self.assertEqual(mode, "700")


class TestSshCommandsRegistered(unittest.TestCase):
    """Tests cho SSH commands registration."""

    def setUp(self):
        from utils.registry import COMMANDS
        self.commands = COMMANDS

    def test_ssh_commands_exist(self):
        ssh_cmds = ["ssh:cleanup"]
        for cmd in ssh_cmds:
            self.assertIn(cmd, self.commands, f"Command '{cmd}' không có trong COMMANDS")


if __name__ == "__main__":
    unittest.main(verbosity=2)
