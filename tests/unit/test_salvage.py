#!/usr/bin/env python3
"""Tests for salvaged pieces: file:chmod*, fleet:status, completion:path."""
import os
import sys
import unittest
from unittest.mock import MagicMock, mock_open, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import completion_paths, file as file_mod, fleet


class TestFileChmod(unittest.TestCase):
    """`file:chmod` — salvage từ deprecated/file.sh."""

    @patch("utils.file._stat_mode", return_value="644")
    def test_prints_mode(self, _mode):
        with patch("builtins.print") as mock_print:
            file_mod.d_file_chmod(["somefile"])
        mock_print.assert_called_once_with("644")

    @patch("utils.file._stat_mode", return_value="")
    def test_prints_nothing_when_unreadable(self, _mode):
        with patch("builtins.print") as mock_print:
            file_mod.d_file_chmod(["missing"])
        mock_print.assert_not_called()

    def test_requires_arg(self):
        with patch("logging.error") as mock_error:
            file_mod.d_file_chmod()
        mock_error.assert_called_once()

    @patch("utils.file.os.stat")
    def test_stat_mode_returns_octal(self, mock_stat):
        mock_stat.return_value = MagicMock(st_mode=0o100644)
        self.assertEqual(file_mod._stat_mode("/x"), "644")

    @patch("utils.file.os.stat", side_effect=OSError)
    def test_stat_mode_handles_error(self, _stat):
        self.assertEqual(file_mod._stat_mode("/missing"), "")


class TestFileChmodRecursive(unittest.TestCase):
    @patch("utils.file.os.chmod")
    @patch("utils.file.os.path.isdir", return_value=True)
    @patch("utils.file.os.walk")
    def test_chmod_files_only(self, mock_walk, _isdir, mock_chmod):
        mock_walk.return_value = [
            ("/d", ["sub"], ["a.txt", "b.txt"]),
            ("/d/sub", [], ["c.txt"]),
        ]
        with patch("utils.file.logging.info"):
            file_mod._chmod_recursive("644", "/d", "f")

        paths = [c[0][0] for c in mock_chmod.call_args_list]
        self.assertEqual(sorted(paths), ["/d/a.txt", "/d/b.txt", "/d/sub/c.txt"])
        self.assertTrue(all(c[0][1] == 0o644 for c in mock_chmod.call_args_list))

    @patch("utils.file.os.chmod")
    @patch("utils.file.os.path.isdir", return_value=True)
    @patch("utils.file.os.walk")
    def test_chmod_dirs_only_includes_root(self, mock_walk, _isdir, mock_chmod):
        mock_walk.return_value = [("/d", ["sub"], ["a.txt"])]
        with patch("utils.file.logging.info"):
            file_mod._chmod_recursive("755", "/d", "d")

        paths = [c[0][0] for c in mock_chmod.call_args_list]
        self.assertIn("/d/sub", paths)
        self.assertIn("/d", paths)  # thư mục gốc cũng phải đổi
        self.assertNotIn("/d/a.txt", paths)

    @patch("utils.file.os.chmod")
    @patch("utils.file.os.path.isdir", return_value=True)
    @patch("utils.file.os.walk", return_value=[])
    def test_invalid_mode_rejected(self, _walk, _isdir, mock_chmod):
        with patch("utils.file.logging.error") as mock_error:
            file_mod._chmod_recursive("999", "/d", "f")
        mock_error.assert_called_once()
        mock_chmod.assert_not_called()

    @patch("utils.file.logging.error")
    @patch("utils.file.os.path.isdir", return_value=False)
    def test_not_a_directory(self, _isdir, mock_error):
        file_mod._chmod_recursive("644", "/nope", "f")
        mock_error.assert_called_once()

    @patch("utils.file.os.chmod", side_effect=OSError("denied"))
    @patch("utils.file.os.path.isdir", return_value=True)
    @patch("utils.file.os.walk")
    def test_permission_error_is_not_fatal(self, mock_walk, _isdir, _chmod):
        mock_walk.return_value = [("/d", [], ["a.txt"])]
        with patch("utils.file.logging.warning") as mock_warn, patch(
            "utils.file.logging.info"
        ):
            file_mod._chmod_recursive("644", "/d", "f")
        mock_warn.assert_called()

    def test_commands_require_two_args(self):
        for func in (file_mod.d_file_chmod_files, file_mod.d_file_chmod_dirs):
            with patch("logging.error") as mock_error:
                func(["644"])
            mock_error.assert_called_once()


class TestCompletionPaths(unittest.TestCase):
    @patch("utils.completion_paths.os.path.expanduser", return_value="/home/u/.completion")
    @patch("utils.completion_paths.Path.is_file")
    def test_finds_in_system_dir_first(self, mock_is_file, _expand):
        mock_is_file.return_value = True
        path = completion_paths._find_completion("magerun2")
        self.assertEqual(str(path), "/var/www/base/bash/completion/magerun2.sh")

    @patch("utils.completion_paths.os.path.expanduser", return_value="/home/u/.completion")
    def test_returns_none_when_absent(self, _expand):
        with patch("utils.completion_paths.Path.is_file", return_value=False):
            self.assertIsNone(completion_paths._find_completion("unknown"))

    @patch("utils.completion_paths.os.path.expanduser", return_value="/home/u/.completion")
    def test_angular_maps_to_angular2(self, _expand):
        """Bash quirk: tên tool `angular` nhưng file là angular2.sh."""
        from pathlib import Path

        seen = []

        def record(self):
            seen.append(str(self))
            return False

        with patch.object(Path, "is_file", record):
            self.assertIsNone(completion_paths._find_completion("angular"))

        names = [os.path.basename(p) for p in seen]
        self.assertIn("angular2.sh", names)
        self.assertNotIn("angular.sh", names)

    def test_known_tools_list(self):
        for tool in ("ductn", "magerun", "magerun2", "wp", "angular"):
            self.assertIn(tool, completion_paths.KNOWN_TOOLS)

    @patch("utils.completion_paths._find_completion", return_value="/some/path.sh")
    def test_command_prints_path(self, _find):
        with patch("builtins.print") as mock_print:
            completion_paths.d_completion_path(["wp"])
        mock_print.assert_called_once_with("/some/path.sh")

    @patch("utils.completion_paths._find_completion", return_value=None)
    def test_command_exits_nonzero_when_missing(self, _find):
        with patch("utils.completion_paths.logging.error"):
            with self.assertRaises(SystemExit) as ctx:
                completion_paths.d_completion_path(["nope"])
        self.assertEqual(ctx.exception.code, 1)

    @patch("utils.completion_paths._tool_exists", return_value=True)
    def test_exists_prints_one(self, _exists):
        with patch("builtins.print") as mock_print:
            completion_paths.d_completion_exists(["git"])
        mock_print.assert_called_once_with(1)

    @patch("utils.completion_paths._tool_exists", return_value=False)
    def test_exists_prints_zero(self, _exists):
        with patch("builtins.print") as mock_print:
            completion_paths.d_completion_exists(["nope"])
        mock_print.assert_called_once_with(0)


class TestParseVersion(unittest.TestCase):
    def test_simple(self):
        self.assertEqual(fleet._parse_version("5.8.6"), (5, 8, 6))

    def test_strips_ppa_suffix(self):
        self.assertEqual(fleet._parse_version("5.8.6+ppa~1"), (5, 8, 6))

    def test_handles_debian_revision(self):
        self.assertEqual(fleet._parse_version("5.8.4+debian~13"), (5, 8, 4))

    def test_none_for_empty(self):
        self.assertIsNone(fleet._parse_version(""))
        self.assertIsNone(fleet._parse_version(None))

    def test_none_for_garbage(self):
        self.assertIsNone(fleet._parse_version("abc"))

    def test_comparison(self):
        self.assertLess(
            fleet._parse_version("5.8.4"), fleet._parse_version("5.8.6")
        )


class TestFleetDomains(unittest.TestCase):
    def test_from_args(self):
        self.assertEqual(fleet._fleet_domains(["a.corp", "b.corp"]), ["a.corp", "b.corp"])

    def test_from_string_args(self):
        self.assertEqual(fleet._fleet_domains("a.corp b.corp"), ["a.corp", "b.corp"])

    @patch.dict(os.environ, {"DUCTN_FLEET_DOMAINS": "x.corp, y.corp "}, clear=False)
    def test_from_env(self):
        self.assertEqual(fleet._fleet_domains(None), ["x.corp", "y.corp"])

    @patch.dict(os.environ, {}, clear=True)
    def test_empty(self):
        self.assertEqual(fleet._fleet_domains(None), [])

    @patch.dict(os.environ, {"DUCTN_FLEET_DOMAINS": "env.corp"}, clear=False)
    def test_args_win_over_env(self):
        self.assertEqual(fleet._fleet_domains(["arg.corp"]), ["arg.corp"])


class TestFleetStatus(unittest.TestCase):
    def test_requires_domains(self):
        with patch.dict(os.environ, {}, clear=True), patch(
            "utils.fleet.logging.error"
        ) as mock_error:
            fleet.d_fleet_status(None)
        mock_error.assert_called_once()

    @patch("utils.fleet._ssh_command")
    def test_reports_outdated_host(self, mock_ssh):
        from utils.about import _version

        def ssh(host, cmd):
            if "version" in cmd:
                return "5.8.1+ppa~1" if host == "old.corp" else _version()
            return "host.example"

        mock_ssh.side_effect = ssh

        with patch("builtins.print") as mock_print:
            fleet.d_fleet_status(["old.corp"])

        output = " ".join(str(c) for c in mock_print.call_args_list)
        self.assertIn("old.corp", output)
        self.assertIn("5.8.1", output)

    @patch("utils.fleet._ssh_command", return_value=None)
    def test_handles_unreachable(self, _ssh):
        with patch("builtins.print") as mock_print, patch("utils.fleet.logging.warning"):
            fleet.d_fleet_status(["down.corp"])
        output = " ".join(str(c) for c in mock_print.call_args_list)
        self.assertIn("unreachable", output)


if __name__ == "__main__":
    unittest.main(verbosity=2)
