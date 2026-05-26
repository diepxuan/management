#!/usr/bin/env python3
"""Test ssl.py: SSL command behavior."""
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.registry import COMMANDS
from utils.ssl import (
    APACHE_VHOST_DIRS,
    CERTBOT_EMAIL,
    CLFR_ACCESS,
    DEFAULT_SETUP_GROUPS,
    NGINX_VHOST_DIRS,
    _build_certbot_command,
    _certbot_installed,
    _check_cloudflare_credentials,
    _has_matching_vhost,
    _normalize_domains,
    _select_certbot_mode,
    d_ssl_certbot,
    d_ssl_configure,
    d_ssl_install,
    d_ssl_setup,
)


class TestSslConstants(unittest.TestCase):
    """Tests cho SSL constants."""

    def test_default_paths_and_values_match_expected_defaults(self):
        self.assertEqual(CLFR_ACCESS, "/etc/ductn/cloudflare")
        self.assertEqual(CERTBOT_EMAIL, "caothu91@gmail.com")
        self.assertEqual(
            DEFAULT_SETUP_GROUPS,
            [["diepxuan.com", "*.diepxuan.com"], ["vps.diepxuan.com", "*.vps.diepxuan.com"]],
        )
        self.assertEqual(APACHE_VHOST_DIRS, [Path("/etc/apache2/sites-enabled"), Path("/etc/apache2/sites-available")])
        self.assertEqual(NGINX_VHOST_DIRS, [Path("/etc/nginx/sites-enabled"), Path("/etc/nginx/conf.d")])


class TestSslCommandsRegistered(unittest.TestCase):
    """Tests cho SSL commands registration."""

    def test_ssl_commands_exist_without_removed_copy_commands(self):
        for cmd in ["ssl:install", "ssl:setup", "ssl:configure", "ssl:certbot"]:
            self.assertIn(cmd, COMMANDS, f"Command '{cmd}' không có trong COMMANDS")
        for cmd in ["ssl:pull", "ssl:push", "ssl:upload"]:
            self.assertNotIn(cmd, COMMANDS, f"Command '{cmd}' đã bị yêu cầu xóa")


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
        cmd = _build_certbot_command(["example.com", "*.example.com"], "dns-cloudflare")
        self.assertEqual(cmd[:2], ["certbot", "certonly"])
        self.assertIn("--dns-cloudflare", cmd)
        self.assertIn("--dns-cloudflare-credentials", cmd)
        self.assertIn(CLFR_ACCESS, cmd)
        self.assertIn(CERTBOT_EMAIL, cmd)
        self.assertEqual(cmd[-4:], ["-d", "example.com", "-d", "*.example.com"])

    def test_build_certbot_command_uses_apache_plugin(self):
        cmd = _build_certbot_command(["example.com"], "apache")
        self.assertEqual(cmd[:2], ["certbot", "--apache"])
        self.assertNotIn("certonly", cmd)
        self.assertEqual(cmd[-2:], ["-d", "example.com"])

    def test_build_certbot_command_uses_nginx_plugin(self):
        cmd = _build_certbot_command(["example.com"], "nginx")
        self.assertEqual(cmd[:2], ["certbot", "--nginx"])
        self.assertNotIn("certonly", cmd)
        self.assertEqual(cmd[-2:], ["-d", "example.com"])


class TestSslVhostDetection(unittest.TestCase):
    """Tests cho Apache/Nginx vhost auto detection."""

    def test_has_matching_apache_vhost(self):
        with patch("utils.ssl.Path.exists", return_value=True), patch("utils.ssl.Path.rglob") as mock_rglob:
            path = MagicMock()
            path.is_file.return_value = True
            mock_rglob.return_value = [path]
            with patch("utils.ssl._read_text", return_value="ServerName example.com\nServerAlias www.example.com"):
                self.assertTrue(_has_matching_vhost(["example.com"], [Path("/etc/apache2/sites-enabled")], "ServerName"))

    def test_has_matching_nginx_vhost(self):
        with patch("utils.ssl.Path.exists", return_value=True), patch("utils.ssl.Path.rglob") as mock_rglob:
            path = MagicMock()
            path.is_file.return_value = True
            mock_rglob.return_value = [path]
            with patch("utils.ssl._read_text", return_value="server_name example.com www.example.com;"):
                self.assertTrue(_has_matching_vhost(["example.com"], [Path("/etc/nginx/sites-enabled")], "server_name"))

    @patch("utils.ssl._service_installed")
    @patch("utils.ssl._has_matching_vhost")
    def test_selects_apache_when_installed_and_vhost_matches(self, mock_vhost, mock_installed):
        mock_installed.side_effect = lambda command: command == "apache2"
        mock_vhost.return_value = True
        self.assertEqual(_select_certbot_mode(["example.com"]), "apache")

    @patch("utils.ssl._service_installed")
    @patch("utils.ssl._has_matching_vhost")
    def test_selects_nginx_when_apache_missing_and_nginx_matches(self, mock_vhost, mock_installed):
        mock_installed.side_effect = lambda command: command == "nginx"
        mock_vhost.return_value = True
        self.assertEqual(_select_certbot_mode(["example.com"]), "nginx")

    @patch("utils.ssl._service_installed", return_value=True)
    @patch("utils.ssl._has_matching_vhost", return_value=True)
    def test_wildcard_domains_force_dns_cloudflare(self, _mock_vhost, _mock_installed):
        self.assertEqual(_select_certbot_mode(["example.com", "*.example.com"]), "dns-cloudflare")


class TestSslInstall(unittest.TestCase):
    """Tests cho ssl:install."""

    @patch("utils.ssl._is_root", return_value=False)
    @patch("utils.ssl.logging.error")
    def test_install_requires_root(self, mock_log, _mock_root):
        d_ssl_install()
        mock_log.assert_called_once()

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl.subprocess.check_call")
    def test_install_runs_apt_sequence_with_certbot_plugins(self, mock_check_call, _mock_root):
        d_ssl_install()
        expected = [
            ["apt", "install", "software-properties-common", "-y", "--purge", "--auto-remove"],
            ["apt", "update"],
            ["apt", "install", "-y", "--purge", "--auto-remove", "python3-pip"],
            [
                "apt",
                "install",
                "-y",
                "--purge",
                "--auto-remove",
                "certbot",
                "python3-certbot-dns-cloudflare",
                "python3-certbot-apache",
                "python3-certbot-nginx",
            ],
        ]
        self.assertEqual([call.args[0] for call in mock_check_call.call_args_list], expected)


class TestSslCertbotAndSetup(unittest.TestCase):
    """Tests cho ssl:certbot/setup/configure."""

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl.os.chmod")
    @patch("utils.ssl.subprocess.run")
    @patch("utils.ssl._select_certbot_mode", return_value="dns-cloudflare")
    @patch("utils.ssl._check_cloudflare_credentials", return_value=True)
    def test_certbot_runs_once_with_comma_domains(self, _mock_creds, _mock_mode, mock_run, mock_chmod, _mock_root):
        d_ssl_certbot(["example.com,*.example.com"])
        mock_chmod.assert_called_once_with(CLFR_ACCESS, 0o600)
        mock_run.assert_called_once()
        cmd = mock_run.call_args.args[0]
        self.assertEqual(cmd[-4:], ["-d", "example.com", "-d", "*.example.com"])

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl._run_certbot")
    def test_setup_runs_default_domain_groups(self, mock_run_certbot, _mock_root):
        d_ssl_setup()
        self.assertEqual(
            [call.args[0] for call in mock_run_certbot.call_args_list],
            DEFAULT_SETUP_GROUPS,
        )

    @patch("utils.ssl._is_root", return_value=True)
    @patch("utils.ssl.d_ssl_setup")
    def test_configure_calls_setup(self, mock_setup, _mock_root):
        d_ssl_configure()
        mock_setup.assert_called_once_with()


if __name__ == "__main__":
    unittest.main(verbosity=2)
