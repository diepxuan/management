#!/usr/bin/env python3
"""Tests for interface.py — platform branching (macOS vs Linux).

Bối cảnh 5.8.7: `get_active_service()` gọi `route get default` trên MỌI nền
tảng, nhưng đó là cú pháp macOS. Trên Linux lệnh trả exit 3 và
`interface:service` crash bằng CalledProcessError.
"""
import os
import subprocess
import sys
import unittest
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import interface


def _out(text):
    return MagicMock(returncode=0, stdout=text, stderr="")


class TestGetDefaultInterfaceLinux(unittest.TestCase):
    @patch("utils.interface.sys.platform", "linux")
    @patch("utils.interface.subprocess.check_output")
    def test_parses_ip_route(self, mock_check):
        mock_check.return_value = "default via 192.168.1.1 dev eth0 proto dhcp\n"
        self.assertEqual(interface.get_default_interface(), "eth0")
        self.assertEqual(mock_check.call_args[0][0], ["ip", "route", "show", "default"])

    @patch("utils.interface.sys.platform", "linux")
    @patch("utils.interface.subprocess.check_output")
    def test_returns_none_on_no_default(self, mock_check):
        mock_check.return_value = ""
        self.assertIsNone(interface.get_default_interface())

    @patch("utils.interface.sys.platform", "linux")
    @patch("utils.interface.subprocess.check_output", side_effect=FileNotFoundError)
    def test_returns_none_when_ip_missing(self, _check):
        self.assertIsNone(interface.get_default_interface())

    @patch("utils.interface.sys.platform", "linux")
    @patch(
        "utils.interface.subprocess.check_output",
        side_effect=subprocess.CalledProcessError(1, "ip"),
    )
    def test_returns_none_on_failure(self, _check):
        self.assertIsNone(interface.get_default_interface())


class TestGetDefaultInterfaceMacos(unittest.TestCase):
    @patch("utils.interface.sys.platform", "darwin")
    @patch("utils.interface.subprocess.check_output")
    def test_parses_route_get(self, mock_check):
        mock_check.return_value = (
            "   route to: default\n"
            "destination: default\n"
            "    gateway: 192.168.1.1\n"
            "  interface: en0\n"
        )
        self.assertEqual(interface.get_default_interface(), "en0")
        self.assertEqual(mock_check.call_args[0][0], ["route", "get", "default"])


class TestGetActiveService(unittest.TestCase):
    """Regression: trước 5.8.7 crash trên Linux vì gọi `route get default`."""

    @patch("utils.interface.sys.platform", "linux")
    @patch("utils.interface.subprocess.check_output")
    def test_linux_uses_ip_route_not_route_get(self, mock_check):
        mock_check.return_value = "default via 10.0.0.1 dev eth0\n"
        result = interface.get_active_service()

        self.assertEqual(result, "eth0")
        for call in mock_check.call_args_list:
            cmd = call[0][0]
            self.assertNotEqual(cmd[:3], ["route", "get", "default"])
            self.assertNotEqual(cmd[:1], ["networksetup"])

    @patch("utils.interface.sys.platform", "linux")
    @patch("utils.interface.subprocess.check_output")
    def test_linux_never_calls_networksetup(self, mock_check):
        mock_check.return_value = "default via 10.0.0.1 dev eth0\n"
        interface.get_active_service()

        for call in mock_check.call_args_list:
            self.assertNotIn("networksetup", call[0][0])

    @patch("utils.interface.sys.platform", "darwin")
    @patch("utils.interface.subprocess.check_output")
    def test_macos_maps_device_to_service(self, mock_check):
        def fake(cmd, **kwargs):
            if cmd[0] == "route":
                return "  interface: en0\n"
            return (
                "Hardware Port: Wi-Fi\nDevice: en0\n\n"
                "Hardware Port: Ethernet\nDevice: en1\n"
            )

        mock_check.side_effect = fake
        self.assertEqual(interface.get_active_service(), "Wi-Fi")

    @patch("utils.interface.sys.platform", "darwin")
    @patch("utils.interface.subprocess.check_output")
    def test_macos_returns_none_for_unknown_device(self, mock_check):
        def fake(cmd, **kwargs):
            if cmd[0] == "route":
                return "  interface: en9\n"
            return "Hardware Port: Wi-Fi\nDevice: en0\n"

        mock_check.side_effect = fake
        self.assertIsNone(interface.get_active_service())

    @patch("utils.interface.sys.platform", "darwin")
    @patch("utils.interface.subprocess.check_output", side_effect=FileNotFoundError)
    def test_macos_without_networksetup(self, _check):
        self.assertIsNone(interface.get_active_service())


class TestCommands(unittest.TestCase):
    @patch("utils.interface.get_default_interface", return_value="eth0")
    def test_interface_default_prints(self, _get):
        with patch("builtins.print") as mock_print:
            interface.d_interface_default()
        mock_print.assert_called_once_with("eth0")

    @patch("utils.interface.get_active_service", return_value="Wi-Fi")
    @patch("utils.interface.sys.platform", "darwin")
    def test_interface_service_on_macos(self, _svc):
        with patch("builtins.print") as mock_print:
            interface.d_interface_service()
        mock_print.assert_called_once_with("Wi-Fi")

    @patch("utils.interface.get_default_interface", return_value="eth0")
    @patch("utils.interface.sys.platform", "linux")
    def test_interface_service_on_linux_falls_back(self, _default):
        with patch("builtins.print") as mock_print:
            interface.d_interface_service()
        mock_print.assert_called_once_with("eth0")


if __name__ == "__main__":
    unittest.main(verbosity=2)
