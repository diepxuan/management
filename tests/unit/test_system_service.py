#!/usr/bin/env python3
"""Tests for service management commands."""
import os
import sys
import unittest
from unittest.mock import Mock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import system_service


class TestServiceStatus(unittest.TestCase):
    """Đảm bảo service:status giữ nguyên output chi tiết của init system."""

    @patch.object(system_service, "_is_root", return_value=True)
    @patch.object(system_service, "_call_init_action")
    def test_status_action_is_called(self, call_init_action, _is_root):
        system_service.d_service_status()
        call_init_action.assert_called_once_with("status")

    @patch.object(system_service.subprocess, "run")
    def test_systemd_status_preserves_command_output(self, run):
        run.return_value = Mock(returncode=3)

        result = system_service._systemd_status()

        run.assert_called_once_with(["systemctl", "status", "ductnd"])
        self.assertEqual(3, result)

    @patch.object(system_service.subprocess, "run")
    def test_launchd_status_prints_system_service_details(self, run):
        run.return_value = Mock(returncode=0)

        result = system_service._launchd_status()

        run.assert_called_once_with(
            ["launchctl", "print", "system/com.diepxuan.ductnd"]
        )
        self.assertEqual(0, result)


if __name__ == "__main__":
    unittest.main(verbosity=2)
