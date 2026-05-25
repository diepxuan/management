#!/usr/bin/env python3
"""Test ssl.py: SSL helper functions and constants."""
import sys
import os
import unittest
from unittest.mock import patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.ssl import CLFR_ACCESS, LE_BASE, CERTBOT_EMAIL
from utils.ssl import _certbot_installed, _check_cloudflare_credentials


class TestSslConstants(unittest.TestCase):
    """Tests cho SSL constants."""

    def test_clfr_access_path(self):
        self.assertEqual(CLFR_ACCESS, "/etc/ductn/cloudflare")

    def test_le_base_path(self):
        self.assertEqual(LE_BASE, "/etc/letsencrypt/live")

    def test_certbot_email(self):
        self.assertEqual(CERTBOT_EMAIL, "caothu91@gmail.com")


class TestCertbotInstalled(unittest.TestCase):
    """Tests cho hàm _certbot_installed."""

    @patch("utils.ssl.shutil.which")
    def test_certbot_exists(self, mock_which):
        mock_which.return_value = "/usr/bin/certbot"
        self.assertTrue(_certbot_installed())

    @patch("utils.ssl.shutil.which")
    def test_certbot_missing(self, mock_which):
        mock_which.return_value = None
        self.assertFalse(_certbot_installed())


class TestCheckCloudflareCredentials(unittest.TestCase):
    """Tests cho hàm _check_cloudflare_credentials."""

    @patch("utils.ssl.os.path.exists")
    def test_credentials_exist(self, mock_exists):
        mock_exists.return_value = True
        self.assertTrue(_check_cloudflare_credentials())

    @patch("utils.ssl.os.path.exists")
    @patch("utils.ssl.logging.error")
    def test_credentials_missing(self, mock_log, mock_exists):
        mock_exists.return_value = False
        self.assertFalse(_check_cloudflare_credentials())
        mock_log.assert_called_once()


class TestSslCommandsRegistered(unittest.TestCase):
    """Tests cho SSL commands registration."""

    def setUp(self):
        from utils.registry import COMMANDS
        self.commands = COMMANDS

    def test_ssl_commands_exist(self):
        ssl_cmds = [
            "ssl:install", "ssl:setup", "ssl:configure",
            "ssl:certbot", "ssl:pull", "ssl:push", "ssl:upload",
        ]
        for cmd in ssl_cmds:
            self.assertIn(cmd, self.commands, f"Command '{cmd}' không có trong COMMANDS")


if __name__ == "__main__":
    unittest.main(verbosity=2)
