#!/usr/bin/env python3
"""Tests for helpers.py — hash:md5 / ssh (salvaged from functions.sh)."""
import os
import sys
import unittest
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import helpers


class TestRandomSuffix(unittest.TestCase):
    def test_default_length_is_20(self):
        """Bash dùng `head -c 20` — giữ đúng 20 ký tự."""
        self.assertEqual(len(helpers._random_suffix()), 20)

    def test_custom_length(self):
        self.assertEqual(len(helpers._random_suffix(8)), 8)

    def test_only_lowercase_and_digits(self):
        for value in (helpers._random_suffix() for _ in range(20)):
            self.assertTrue(value.isalnum())
            self.assertEqual(value, value.lower())

    def test_values_differ(self):
        """Hai lần gọi phải khác nhau (bash $RANDOM cũng vậy)."""
        values = {helpers._random_suffix() for _ in range(20)}
        self.assertGreater(len(values), 15)


class TestHashMd5Command(unittest.TestCase):
    def test_prints_value(self):
        with patch("builtins.print") as mock_print:
            helpers.d_hash_md5()
        mock_print.assert_called_once()
        printed = mock_print.call_args[0][0]
        self.assertEqual(len(printed), 20)

    def test_registered_as_hash_md5(self):
        from utils.registry import COMMANDS

        self.assertIn("hash:md5", COMMANDS)
        self.assertIs(COMMANDS["hash:md5"], helpers.d_hash_md5)


class TestSshCommand(unittest.TestCase):
    @patch("utils.helpers.subprocess.run")
    def test_prints_stdout(self, mock_run):
        mock_run.return_value = MagicMock(returncode=0, stdout="hello\n", stderr="")
        with patch("builtins.print") as mock_print:
            helpers.d_ssh(["host1", "echo", "hello"])
        mock_print.assert_called_once_with("hello\n", end="")

    @patch("utils.helpers.subprocess.run")
    def test_uses_dash_t(self, mock_run):
        """Bash: `ssh -T $1 "$2"`."""
        mock_run.return_value = MagicMock(returncode=0, stdout="", stderr="")
        helpers.d_ssh(["host1", "uptime"])
        cmd = mock_run.call_args[0][0]
        self.assertEqual(cmd[0], "ssh")
        self.assertEqual(cmd[1], "-T")
        self.assertEqual(cmd[2], "host1")
        self.assertEqual(cmd[3], "uptime")

    @patch("utils.helpers.subprocess.run")
    def test_joins_remaining_args(self, mock_run):
        mock_run.return_value = MagicMock(returncode=0, stdout="", stderr="")
        helpers.d_ssh(["host1", "ls", "-la", "/tmp"])
        self.assertEqual(mock_run.call_args[0][0][3], "ls -la /tmp")

    def test_requires_two_args(self):
        with patch("utils.helpers.logging.error") as mock_error:
            helpers.d_ssh(["onlyhost"])
        mock_error.assert_called_once()

    def test_requires_args(self):
        with patch("utils.helpers.logging.error") as mock_error:
            helpers.d_ssh()
        mock_error.assert_called_once()

    @patch("utils.helpers.subprocess.run", side_effect=FileNotFoundError)
    def test_missing_ssh_binary(self, _run):
        with patch("utils.helpers.logging.error") as mock_error:
            helpers.d_ssh(["host1", "uptime"])
        mock_error.assert_called_once()


if __name__ == "__main__":
    unittest.main(verbosity=2)
