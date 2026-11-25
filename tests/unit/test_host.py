#!/usr/bin/env python3
"""Tests for host.py — _host_domain() resolution order (fix/5.8.6)."""
import os
import sys
import unittest
from unittest.mock import mock_open, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import host


class TestLooksLikeIpv4(unittest.TestCase):
    def test_valid_ipv4(self):
        self.assertTrue(host._looks_like_ipv4("192.168.1.1"))
        self.assertTrue(host._looks_like_ipv4("10.0.0.0"))
        self.assertTrue(host._looks_like_ipv4("255.255.255.255"))

    def test_invalid(self):
        self.assertFalse(host._looks_like_ipv4(""))
        self.assertFalse(host._looks_like_ipv4("diepxuan.corp"))
        self.assertFalse(host._looks_like_ipv4("192.168.1"))
        self.assertFalse(host._looks_like_ipv4("256.1.1.1"))
        self.assertFalse(host._looks_like_ipv4("a.b.c.d"))
        self.assertFalse(host._looks_like_ipv4("192.168.1.1.5"))


class TestDomainFromResolvConf(unittest.TestCase):
    def test_returns_first_search_domain(self):
        data = "# managed\nsearch diepxuan.corp\nnameserver 1.1.1.1\n"
        with patch("builtins.open", mock_open(read_data=data)):
            self.assertEqual(host._domain_from_resolv_conf(), "diepxuan.corp")

    def test_takes_first_of_multiple_search(self):
        data = "search diepxuan.corp corp.local\n"
        with patch("builtins.open", mock_open(read_data=data)):
            self.assertEqual(host._domain_from_resolv_conf(), "diepxuan.corp")

    def test_strips_inline_comment(self):
        data = "search diepxuan.corp # primary\n"
        with patch("builtins.open", mock_open(read_data=data)):
            self.assertEqual(host._domain_from_resolv_conf(), "diepxuan.corp")

    def test_skips_comment_lines(self):
        data = "# search old.invalid\nsearch diepxuan.corp\n"
        with patch("builtins.open", mock_open(read_data=data)):
            self.assertEqual(host._domain_from_resolv_conf(), "diepxuan.corp")

    def test_returns_none_without_search(self):
        with patch("builtins.open", mock_open(read_data="nameserver 1.1.1.1\n")):
            self.assertIsNone(host._domain_from_resolv_conf())

    def test_returns_none_when_search_empty(self):
        with patch("builtins.open", mock_open(read_data="search\n")):
            self.assertIsNone(host._domain_from_resolv_conf())

    def test_returns_none_when_file_missing(self):
        with patch("builtins.open", side_effect=FileNotFoundError):
            self.assertIsNone(host._domain_from_resolv_conf())

    def test_returns_none_on_oserror(self):
        with patch("builtins.open", side_effect=OSError("denied")):
            self.assertIsNone(host._domain_from_resolv_conf())


class TestHostDomain(unittest.TestCase):
    """Pin thứ tự ưu tiên của _host_domain()."""

    def test_resolv_conf_wins_over_synthetic_fqdn(self):
        """Bug gốc: host Proxmox có FQDN postgresql.192.168.1.1 nhưng
        /etc/resolv.conf search diepxuan.corp => phải trả diepxuan.corp."""
        data = "search diepxuan.corp\nnameserver 192.168.1.2\n"
        with patch("builtins.open", mock_open(read_data=data)):
            with patch("socket.getfqdn", return_value="postgresql.192.168.1.1"):
                with patch("socket.gethostname", return_value="postgresql"):
                    self.assertEqual(host._host_domain(), "diepxuan.corp")

    def test_falls_back_to_fqdn_without_search(self):
        with patch("builtins.open", side_effect=FileNotFoundError):
            with patch("socket.getfqdn", return_value="db.diepxuan.corp"):
                with patch("socket.gethostname", return_value="db"):
                    self.assertEqual(host._host_domain(), "diepxuan.corp")

    def test_rejects_ip_shaped_fqdn_suffix(self):
        """Không có search + FQDN postgresql.192.168.1.1 => DEFAULT_DOMAIN,
        không được trả 192.168.1.1 (zone không tồn tại)."""
        with patch("builtins.open", side_effect=FileNotFoundError):
            with patch("socket.getfqdn", return_value="postgresql.192.168.1.1"):
                with patch("socket.gethostname", return_value="postgresql"):
                    self.assertEqual(host._host_domain(), host.DEFAULT_DOMAIN)

    def test_falls_back_to_default_on_ipv6(self):
        with patch("builtins.open", side_effect=FileNotFoundError):
            with patch("socket.getfqdn", return_value="::1"):
                with patch("socket.gethostname", return_value="localhost"):
                    self.assertEqual(host._host_domain(), host.DEFAULT_DOMAIN)

    def test_never_returns_empty(self):
        with patch("builtins.open", side_effect=FileNotFoundError):
            with patch("socket.getfqdn", return_value="host"):
                with patch("socket.gethostname", return_value="host"):
                    result = host._host_domain()
        self.assertIsInstance(result, str)
        self.assertTrue(result)


if __name__ == "__main__":
    unittest.main(verbosity=2)
