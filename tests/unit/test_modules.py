#!/usr/bin/env python3
"""Test module imports: verify all modules in __init__.py import successfully."""
import sys
import os
import unittest
import importlib

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

# List of modules expected to be in utils/
EXPECTED_MODULES = [
    "about",
    "addr",
    "apt",
    "command",
    "cronjob",
    "curl_utils",
    "dhcpd",
    "disk",
    "dns",
    "dns_technitium",
    "env_detect",
    "file",
    "git_utils",
    "gpg",
    "helpers",
    "host",
    "httpd",
    "init_action",
    "interface",
    "laravel",
    "log",
    "magento2",
    "php_utils",
    "port",
    "registry",
    "route",
    "server",
    "service",
    "serviceContext",
    "serviceScheduler",
    "ssh",
    "ssl",
    "swap",
    "system",
    "system_info",
    "system_os",
    "system_service",
    "ufw",
    "user",
    "vm",
]


class TestModuleImports(unittest.TestCase):
    """Tests cho việc import tất cả modules."""

    def test_all_modules_import(self):
        """Tất cả modules phải import được không lỗi."""
        failed = []
        for mod_name in EXPECTED_MODULES:
            full_name = f"utils.{mod_name}"
            try:
                importlib.import_module(full_name)
            except Exception as e:
                failed.append(f"{full_name}: {e}")
        if failed:
            self.fail(f"Không import được modules:\n" + "\n".join(failed))

    def test_no_removed_modules(self):
        """Các module đã xóa không được import nữa."""
        removed_modules = ["alias", "env_config", "wg", "vpn", "mysql_utils", "ddns", "helpers"]  # helpers kept but reduced
        for mod_name in removed_modules:
            if mod_name == "helpers":
                continue  # still exists, just reduced
            full_name = f"utils.{mod_name}"
            try:
                importlib.import_module(full_name)
                self.fail(f"Module đã xóa '{full_name}' vẫn còn tồn tại")
            except ModuleNotFoundError:
                pass  # Expected


if __name__ == "__main__":
    unittest.main(verbosity=2)
