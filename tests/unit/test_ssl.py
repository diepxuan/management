#!/usr/bin/env python3
"""Test ssl.py: SSL migration command behavior."""
import os
import sys
import unittest
from unittest.mock import mock_open, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.registry import COMMANDS
from utils.ssl import (
    CERT_FILES,
    CERTBOT_EMAIL,
    CLFR_ACCESS,
    DEFAULT_CERT_DOMAIN,
    DEFAULT_SETUP_GROUPS,
    LE_BASE,
    _build_certbot_command,
    _certbot_installed,
    _check_cloudflare_credentials,
    _normalize_domains,
    d_ssl_certbot,
    d_ssl_configure,
    d_ssl_install,
    d_ssl_pull,
    d_ssl_push,
    d_ssl_setup,
    d_ssl_upload,
)


class TestSslConstants(unittest.TestCase):
    """Tests cho SSL constants."""

    def test_default_paths_and_values_match_legacy_bash(self):
        self.assertEqual(CLFR_ACCESS, "/etc/ductn/cloudflare")
        self.assertEqual(LE_BASE, "/etc/letsencrypt/live")
        self.assertEqual(CERTBOT_EMAIL, "caothu91@gmail.com")
        self.assertEqual(DEFAULT_CERT_DOMAIN, "diepxuan.com")
        self.assertEqual(CERT_FILES, ["cert.pem", "chain.pem", "fullchain.pem", "privkey.pem"])
        self.assertEqual(
            DEFAULT_SETUP_GROUPS,
            [["diepxuan.com", "*.diepxuan.com"], ["vps.diepxuan.com", "*.vps.diepxuan.com"]],
        )


class TestSslCommandsRegistered(unittest.TestCase):
    """Tests cho SSL commands registration."""

    def test_ssl_commands_exist(self):
        ssl_cmds = [
            "ssl:install",
            "ssl:setup",
            "ssl:configure",
            "ssl:certbot",
            "ssl:pull",
            "ssl:push",
            "ssl:upload",
        ]
        for cmd in ssl_cmds:
            self.assertIn(cmd, COMMANDS, f"Command '{cmd}' không có trong COMMANDS")


class TestSslHelpers(unittest.TestCase):
    """Tests cho helper functions."""

    @patch("utils.ssl.shutil.which")
    def test_certbot_exists(self, mock_which):
        mock_which.return_value = "/usr/bin/certbot"
        self.assertTrue(_certbot_installed())

    @patch("utils.ssl.shutil.which")
    def test_certbot_missing(self, mock_which):
        mock_which.return_value = None
        self.assertFalse(_certbot_installed())

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

    def test_normalize_domains_accepts_comma_and_space_args(self):
        self.assertEqual(
            _normalize_domains(["example.com,*.example.com", "www.example.com"]),
            ["example.com", "*.example.com", "www.example.com"],
        )

    def test_build_certbot_command_uses_dns_cloudflare_options(self):
        cmd = _build_certbot_command(["example.com", "*.example.com"])
        self.assertEqual(cmd[:2], ["certbot", "certonly"])
        self.assertIn("--dns-cloudflare", cmd)
        self.assertIn("--dns-cloudflare-credentials", cmd)
        self.assertIn(CLFR_ACCESS, cmd)
        self.assertIn(CERTBOT_EMAIL, cmd)
        self.assertEqual(cmd[-4:], ["-d", "example.com", "-d", "*.example.com"])


class TestSslInstall(unittest.TestCase):
    """Tests cho ssl:install."""

    @patch("utils.ssl._is_root", return_value=False)
    @patch("utils.ssl.logging.error")
    def test_install_requires_root(self, mock_log, _mock_root):
        d_ssl_install()
        mock_log.assert_called_once()

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl.subprocess.check_call")
    def test_install_runs_legacy_apt_sequence(self, mock_check_call, _mock_root):
        d_ssl_install()
        expected = [
            ["apt", "install", "software-properties-common", "-y", "--purge", "--auto-remove"],
            ["apt", "update"],
            ["apt", "install", "-y", "--purge", "--auto-remove", "python3-pip"],
            ["apt", "install", "-y", "--purge", "--auto-remove", "certbot", "python3-certbot-dns-cloudflare"],
        ]
        self.assertEqual([call.args[0] for call in mock_check_call.call_args_list], expected)


class TestSslCertbotAndSetup(unittest.TestCase):
    """Tests cho ssl:certbot/setup/configure."""

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl.os.chmod")
    @patch("utils.ssl.subprocess.run")
    @patch("utils.ssl._check_cloudflare_credentials", return_value=True)
    def test_certbot_runs_once_with_comma_domains(self, _mock_creds, mock_run, mock_chmod, _mock_root):
        d_ssl_certbot(["example.com,*.example.com"])
        mock_chmod.assert_called_once_with(CLFR_ACCESS, 0o600)
        mock_run.assert_called_once()
        cmd = mock_run.call_args.args[0]
        self.assertEqual(cmd[-4:], ["-d", "example.com", "-d", "*.example.com"])

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl.subprocess.check_call")
    @patch("utils.ssl._run_certbot")
    def test_setup_runs_default_domain_groups_then_restarts_apache(self, mock_run_certbot, mock_check_call, _mock_root):
        d_ssl_setup()
        self.assertEqual(
            [call.args[0] for call in mock_run_certbot.call_args_list],
            DEFAULT_SETUP_GROUPS,
        )
        mock_check_call.assert_called_once_with(["service", "apache2", "restart"])

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl.d_ssl_setup")
    @patch("utils.ssl._check_cloudflare_credentials", return_value=True)
    def test_configure_calls_setup_when_credentials_exist(self, _mock_creds, mock_setup, _mock_root):
        d_ssl_configure()
        mock_setup.assert_called_once_with()


class TestSslCopy(unittest.TestCase):
    """Tests cho ssl:pull/push/upload."""

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl.os.makedirs")
    @patch("utils.ssl.subprocess.run")
    @patch("builtins.open", new_callable=mock_open)
    def test_pull_defaults_to_diepxuan_domain_and_reads_remote_files(
        self, mock_file, mock_run, mock_makedirs, _mock_root
    ):
        mock_run.return_value.stdout = "CERTDATA"
        d_ssl_pull(["server.example.com"])
        mock_makedirs.assert_called_once_with(f"{LE_BASE}/{DEFAULT_CERT_DOMAIN}/", exist_ok=True)
        self.assertEqual(mock_run.call_count, len(CERT_FILES))
        first_cmd = mock_run.call_args_list[0].args[0]
        self.assertEqual(
            first_cmd,
            ["ssh", "server.example.com", f"sudo cat {LE_BASE}/{DEFAULT_CERT_DOMAIN}/cert.pem"],
        )
        mock_file.assert_any_call(f"{LE_BASE}/{DEFAULT_CERT_DOMAIN}/cert.pem", "w")

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl.subprocess.run")
    def test_push_defaults_to_diepxuan_domain_and_writes_remote_files(self, mock_run, _mock_root):
        d_ssl_push(["server.example.com"])
        self.assertEqual(mock_run.call_count, len(CERT_FILES))
        first_cmd = mock_run.call_args_list[0].args[0]
        self.assertEqual(
            first_cmd,
            f"sudo cat {LE_BASE}/{DEFAULT_CERT_DOMAIN}/cert.pem | "
            f"ssh server.example.com \"sudo tee {LE_BASE}/{DEFAULT_CERT_DOMAIN}/cert.pem\"",
        )

    @patch("utils.ssl.d_ssl_push")
    def test_upload_aliases_push(self, mock_push):
        d_ssl_upload(["server.example.com"])
        mock_push.assert_called_once_with(["server.example.com"])

    @patch("utils.ssl.logging.error")
    def test_pull_without_remote_shows_usage(self, mock_log):
        d_ssl_pull([])
        mock_log.assert_called_once()


if __name__ == "__main__":
    unittest.main(verbosity=2)
