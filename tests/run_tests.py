#!/usr/bin/env python3
"""Test runner — dùng unittest standard library, không cần pip install."""
import unittest
import sys
import os
import unittest.mock
from unittest.mock import patch, MagicMock

SRC_DIR = os.path.join(os.path.dirname(__file__), "..", "src")
sys.path.insert(0, SRC_DIR)

# ---------- Mock logging trước khi import ----------
with unittest.mock.patch("logging.basicConfig"):
    with unittest.mock.patch("logging.handlers.RotatingFileHandler"):
        from utils.registry import COMMANDS, register_command


def _func_to_cmd(name):
    """Convert function name to command name."""
    cmd = name
    if cmd.startswith("d_"):
        cmd = cmd[2:]
    return cmd.replace("_", ":")


# ============================================================
# Test: Registry
# ============================================================
class TestRegistry(unittest.TestCase):
    def test_commands_not_empty(self):
        self.assertGreater(len(COMMANDS), 0)

    def test_commands_are_callable(self):
        for name, func in COMMANDS.items():
            self.assertTrue(callable(func), f"'{name}' không phải callable")

    def test_commands_have_docstring(self):
        missing = []
        for name, func in COMMANDS.items():
            if not func.__doc__:
                missing.append(name)
        if missing:
            self.fail(f"Commands thiếu docstring: {', '.join(missing)}")

    def test_register_command_decorator(self):
        @register_command
        def d_test_temp():
            """Temporary test command."""
            pass

        cmd_name = _func_to_cmd("d_test_temp")
        self.assertIn(cmd_name, COMMANDS)
        del COMMANDS[cmd_name]

    def test_register_command_with_alias(self):
        @register_command("d_alias_temp1", "d_alias_temp2")
        def d_test_temp_alias():
            """Temporary test command with alias."""
            pass

        cmd_name = _func_to_cmd("d_test_temp_alias")
        self.assertIn(cmd_name, COMMANDS)
        self.assertIn("d_alias_temp1", COMMANDS)
        self.assertIn("d_alias_temp2", COMMANDS)
        del COMMANDS[cmd_name]
        del COMMANDS["d_alias_temp1"]
        del COMMANDS["d_alias_temp2"]


# ============================================================
# Test: SSL module
# ============================================================
class TestSslHelpers(unittest.TestCase):
    def test_ssl_constants(self):
        from utils.ssl import CLFR_ACCESS, LE_BASE, CERTBOT_EMAIL
        self.assertEqual(CLFR_ACCESS, "/etc/ductn/cloudflare")
        self.assertEqual(LE_BASE, "/etc/letsencrypt/live")
        self.assertEqual(CERTBOT_EMAIL, "caothu91@gmail.com")

    @patch("utils.ssl.shutil.which")
    def test_certbot_installed_true(self, mock_which):
        from utils.ssl import _certbot_installed
        mock_which.return_value = "/usr/bin/certbot"
        self.assertTrue(_certbot_installed())

    @patch("utils.ssl.shutil.which")
    def test_certbot_installed_false(self, mock_which):
        from utils.ssl import _certbot_installed
        mock_which.return_value = None
        self.assertFalse(_certbot_installed())

    @patch("utils.ssl.os.path.exists")
    def test_check_cloudflare_credentials_exists(self, mock_exists):
        from utils.ssl import _check_cloudflare_credentials
        mock_exists.return_value = True
        self.assertTrue(_check_cloudflare_credentials())

    @patch("utils.ssl.os.path.exists")
    @patch("utils.ssl.logging.error")
    def test_check_cloudflare_credentials_missing(self, mock_log, mock_exists):
        from utils.ssl import _check_cloudflare_credentials
        mock_exists.return_value = False
        self.assertFalse(_check_cloudflare_credentials())
        mock_log.assert_called_once()

    def test_ssl_commands_registered(self):
        ssl_cmds = [
            "ssl:install", "ssl:setup", "ssl:configure",
            "ssl:certbot", "ssl:pull", "ssl:push", "ssl:upload"
        ]
        for cmd in ssl_cmds:
            self.assertIn(cmd, COMMANDS, f"Command '{cmd}' không có trong COMMANDS")


# ============================================================
# Test: SSH module
# ============================================================
class TestSshHelpers(unittest.TestCase):
    @patch("utils.ssh.os.path.exists")
    def test_fix_ssh_permissions_creates_dir(self, mock_exists):
        from utils.ssh import _fix_ssh_permissions
        import tempfile
        # Test với thư mục thật
        with tempfile.TemporaryDirectory() as tmpdir:
            ssh_dir = os.path.join(tmpdir, ".ssh")
            with patch("utils.ssh.os.path.expanduser", return_value=ssh_dir):
                _fix_ssh_permissions()
                self.assertTrue(os.path.exists(ssh_dir))
                self.assertEqual(oct(os.stat(ssh_dir).st_mode)[-3:], "700")

    def test_ssh_commands_registered(self):
        ssh_cmds = ["ssh:cleanup", "ssh:install", "ssh:copy"]
        for cmd in ssh_cmds:
            self.assertIn(cmd, COMMANDS, f"Command '{cmd}' không có trong COMMANDS")



# ============================================================
# Test: Log module
# ============================================================
class TestLogHelpers(unittest.TestCase):
    def test_log_commands_registered(self):
        log_cmds = ["log", "log:watch", "log:cleanup", "log:config"]
        for cmd in log_cmds:
            self.assertIn(cmd, COMMANDS, f"Command '{cmd}' không có trong COMMANDS")


# ============================================================
# Test: Cronjob module
# ============================================================
class TestCronjobHelpers(unittest.TestCase):
    def test_cronjob_commands_registered(self):
        cron_cmds = ["cron:min", "cron:5min", "cron:hour", "cron:month"]
        for cmd in cron_cmds:
            self.assertIn(cmd, COMMANDS, f"Command '{cmd}' không có trong COMMANDS")


# ============================================================
# Test: Swap module
# ============================================================
class TestSwapHelpers(unittest.TestCase):
    def test_swap_constants(self):
        from utils.swap import SWAPFILE
        self.assertEqual(SWAPFILE, "/swapfile")

    def test_swap_commands_registered(self):
        swap_cmds = ["swap:remove", "swap:install"]
        for cmd in swap_cmds:
            self.assertIn(cmd, COMMANDS, f"Command '{cmd}' không có trong COMMANDS")


# ============================================================
# Test: Port module
# ============================================================
class TestPortHelpers(unittest.TestCase):
    def test_port_commands_registered(self):
        self.assertIn("port:open", COMMANDS)


# ============================================================
# Test: Command naming convention
# ============================================================
class TestCommandNaming(unittest.TestCase):
    def test_all_python_functions_start_with_d_(self):
        """Kiểm tra tất cả function Python trong COMMANDS đều bắt đầu bằng d_."""
        non_conforming = []
        for name, func in COMMANDS.items():
            if not func.__name__.startswith("d_"):
                non_conforming.append(f"{name} (func: {func.__name__})")
        if non_conforming:
            self.fail(
                f"Functions không theo quy ước d_: {', '.join(non_conforming)}"
            )


# ============================================================
# Test: Module imports
# ============================================================
class TestModuleImports(unittest.TestCase):
    def test_utils_init_imports(self):
        """Kiểm tra các module đã import trong __init__.py đều tồn tại."""
        expected_modules = [
            "command", "alias", "about", "interface", "vm", "addr",
            "host", "dns", "route", "service", "system", "system_os",
            "system_info", "system_service", "file", "env_detect",
            "system_metrics", "apt", "ssl", "ssh", "log",
            "cronjob", "swap", "port",
        ]
        import importlib
        for mod_name in expected_modules:
            full_name = f"utils.{mod_name}"
            try:
                importlib.import_module(full_name)
            except ImportError as e:
                self.fail(f"Không import được {full_name}: {e}")


if __name__ == "__main__":
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    # Thêm tất cả test classes
    suite.addTests(loader.loadTestsFromTestCase(TestRegistry))
    suite.addTests(loader.loadTestsFromTestCase(TestSslHelpers))
    suite.addTests(loader.loadTestsFromTestCase(TestSshHelpers))
    suite.addTests(loader.loadTestsFromTestCase(TestVpnHelpers))
    suite.addTests(loader.loadTestsFromTestCase(TestLogHelpers))
    suite.addTests(loader.loadTestsFromTestCase(TestCronjobHelpers))
    suite.addTests(loader.loadTestsFromTestCase(TestSwapHelpers))
    suite.addTests(loader.loadTestsFromTestCase(TestPortHelpers))
    suite.addTests(loader.loadTestsFromTestCase(TestCommandNaming))
    suite.addTests(loader.loadTestsFromTestCase(TestModuleImports))

    # Chạy với verbose
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    # Exit code
    sys.exit(0 if result.wasSuccessful() else 1)
