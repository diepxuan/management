#!/usr/bin/env python3
"""Test registry: @register_command decorator, COMMANDS dict, aliases."""
import sys
import os
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.registry import COMMANDS, register_command


class TestRegistry(unittest.TestCase):
    """Tests for command registry system."""

    def test_commands_not_empty(self):
        """COMMANDS dict phải có ít nhất 1 command."""
        self.assertGreater(len(COMMANDS), 0)

    def test_commands_are_callable(self):
        """Tất cả commands phải là callable."""
        for name, func in COMMANDS.items():
            self.assertTrue(callable(func), f"'{name}' không phải callable")

    def test_commands_have_docstring(self):
        """Tất cả commands phải có docstring."""
        missing = [name for name, func in COMMANDS.items() if not func.__doc__]
        if missing:
            self.fail(f"Commands thiếu docstring: {', '.join(missing)}")

    def test_register_command_decorator(self):
        """Decorator @register_command tự động register command."""
        @register_command
        def d_test_temp():
            """Temporary test command."""
            pass

        self.assertIn("test:temp", COMMANDS)
        del COMMANDS["test:temp"]

    def test_register_command_with_alias(self):
        """Decorator @register_command('alias1', 'alias2') tạo aliases."""
        @register_command("alias_temp1", "alias_temp2")
        def d_test_temp_alias():
            """Temporary test command with alias."""
            pass

        self.assertIn("test:temp:alias", COMMANDS)
        self.assertIn("alias_temp1", COMMANDS)
        self.assertIn("alias_temp2", COMMANDS)
        del COMMANDS["test:temp:alias"]
        del COMMANDS["alias_temp1"]
        del COMMANDS["alias_temp2"]

    def test_register_command_custom_name(self):
        """Decorator @register_command('custom:name') thêm custom name bên cạnh default."""
        @register_command("custom:command:name")
        def d_test_custom():
            """Custom named command."""
            pass

        self.assertIn("custom:command:name", COMMANDS)
        # Default name cũng được register
        self.assertIn("test:custom", COMMANDS)
        del COMMANDS["custom:command:name"]
        del COMMANDS["test:custom"]

    def test_command_run_expands_multiple_args(self):
        """command_run phải truyền từng arg cho command có nhiều tham số."""
        from utils.command import command_run

        captured = []

        def d_test_multi(first, second):
            """Temporary multi-arg command."""
            captured.extend([first, second])

        command_run(d_test_multi, ["one", "two"])
        self.assertEqual(["one", "two"], captured)


class TestCommandNaming(unittest.TestCase):
    """Tests cho quy ước đặt tên command."""

    def test_all_functions_start_with_d_prefix(self):
        """Tất cả function trong COMMANDS phải bắt đầu bằng d_."""
        non_conforming = [
            f"{name} (func: {func.__name__})"
            for name, func in COMMANDS.items()
            if not func.__name__.startswith("d_")
        ]
        if non_conforming:
            self.fail(f"Functions không theo quy ước d_: {', '.join(non_conforming)}")

    def test_no_duplicate_command_names(self):
        """Không có command name nào bị trùng."""
        names = list(COMMANDS.keys())
        self.assertEqual(len(names), len(set(names)), "Có command name bị trùng")

    def test_command_naming_consistency(self):
        """Command names dùng dấu : thay vì _ (trừ các alias legacy)."""
        # Cho phép các alias legacy dùng _
        legacy_aliases = {
            "user:is_sudoer",
        }
        inconsistent = [
            name for name in COMMANDS.keys()
            if "_" in name and name not in legacy_aliases
        ]
        if inconsistent:
            self.fail(f"Commands dùng _ thay vì :: {', '.join(inconsistent)}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
