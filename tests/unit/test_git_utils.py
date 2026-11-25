#!/usr/bin/env python3
"""Tests for git_utils.py — bash parity fixes (detrack/untrack/tag:cleanup)."""
import os
import sys
import unittest
from unittest.mock import MagicMock, mock_open, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import git_utils


def _git_result(stdout=""):
    return MagicMock(returncode=0, stdout=stdout, stderr="")


class TestDetrackSemantics(unittest.TestCase):
    """5.8.7 sửa: bash dùng update-index, Python cũ dùng `git rm --cached`."""

    @patch("utils.git_utils._run_git")
    def test_detrack_uses_no_assume_unchanged(self, mock_git):
        mock_git.return_value = _git_result()
        git_utils.d_git_detrack(["file.txt"])
        mock_git.assert_called_once_with(
            "update-index", "--no-assume-unchanged", "file.txt"
        )

    @patch("utils.git_utils._run_git")
    def test_detrack_does_not_remove_from_index(self, mock_git):
        """Regression: `git rm --cached` xoá file khỏi index — sai ngữ nghĩa."""
        mock_git.return_value = _git_result()
        git_utils.d_git_detrack(["file.txt"])
        for call in mock_git.call_args_list:
            self.assertNotIn("rm", call[0])

    @patch("utils.git_utils._run_git")
    def test_untrack_uses_assume_unchanged(self, mock_git):
        mock_git.return_value = _git_result()
        git_utils.d_git_untrack(["file.txt"])
        mock_git.assert_called_once_with(
            "update-index", "--assume-unchanged", "file.txt"
        )

    @patch("utils.git_utils.logging.error")
    def test_detrack_requires_arg(self, mock_error):
        git_utils.d_git_detrack()
        mock_error.assert_called_once()

    @patch("utils.git_utils._run_git")
    def test_detrack_multiple_files(self, mock_git):
        mock_git.return_value = _git_result()
        git_utils.d_git_detrack(["a.txt", "b.txt"])
        self.assertEqual(mock_git.call_count, 2)


class TestViewUntrack(unittest.TestCase):
    @patch("utils.git_utils._run_git")
    def test_prints_lowercase_entries(self, mock_git):
        """Bash: `git ls-files -v | grep "^[[:lower:]]"`."""
        mock_git.return_value = _git_result("h file_normal\ntracked.txt\nS skip.txt\n")
        with patch("builtins.print") as mock_print:
            git_utils.d_git_viewuntrack()
        mock_print.assert_called_once_with("file_normal")
    @patch("utils.git_utils._run_git")
    def test_empty_output_prints_nothing(self, mock_git):
        mock_git.return_value = _git_result("")
        with patch("builtins.print") as mock_print:
            git_utils.d_git_viewuntrack()
        mock_print.assert_not_called()


class TestTagCleanup(unittest.TestCase):
    """5.8.7 sửa: bash xoá tag cũ trên origin, Python cũ chỉ in ra."""

    @patch("utils.git_utils._run_git")
    def test_deletes_tags_beyond_keep_count(self, mock_git):
        mock_git.return_value = _git_result("v1\nv2\nv3\nv4\nv5\nv6\nv7\n")

        git_utils.d_git_tag_cleanup(["5"])

        deleted = [
            c[0][3] for c in mock_git.call_args_list if c[0][:3] == ("push", "--delete", "origin")
        ]
        self.assertEqual(deleted, ["v6", "v7"])

    @patch("utils.git_utils._run_git")
    def test_fetches_tags_after_delete(self, mock_git):
        mock_git.return_value = _git_result("v1\nv2\nv3\nv4\nv5\nv6\n")
        git_utils.d_git_tag_cleanup(["5"])
        calls = [c[0] for c in mock_git.call_args_list]
        self.assertTrue(any(c[0] == "fetch" for c in calls))

    @patch("utils.git_utils._run_git")
    def test_nothing_to_delete(self, mock_git):
        mock_git.return_value = _git_result("v1\nv2\n")
        with patch("utils.git_utils.logging.info") as mock_info:
            git_utils.d_git_tag_cleanup(["5"])
        mock_info.assert_called()
        self.assertEqual(mock_git.call_count, 1)  # chỉ lệnh `git tag`

    @patch("utils.git_utils._run_git")
    def test_invalid_count_rejected(self, mock_git):
        with patch("utils.git_utils.logging.error") as mock_error:
            git_utils.d_git_tag_cleanup(["abc"])
        mock_error.assert_called_once()
        mock_git.assert_not_called()


class TestConfigureGlobal(unittest.TestCase):
    """5.8.7: --global bổ sung các setting từ bash git.sh."""

    @patch("utils.git_utils._write_global_gitignore")
    @patch("utils.git_utils._run_git")
    def test_global_sets_filemode_and_eol(self, mock_git, _gitignore):
        mock_git.return_value = _git_result()
        git_utils.d_git_configure(["--global"])

        configured = {c[0][2] for c in mock_git.call_args_list if len(c[0]) > 2}
        self.assertIn("core.fileMode", configured)
        self.assertIn("core.autocrlf", configured)
        self.assertIn("core.eol", configured)
        self.assertIn("gc.auto", configured)
        self.assertIn("receive.denyCurrentBranch", configured)

    @patch("utils.git_utils._write_global_gitignore")
    @patch("utils.git_utils._run_git")
    def test_global_writes_gitignore(self, mock_git, mock_gitignore):
        mock_git.return_value = _git_result()
        git_utils.d_git_configure(["--global"])
        mock_gitignore.assert_called_once()

    @patch("utils.git_utils._write_global_gitignore")
    @patch("utils.git_utils._run_git")
    def test_local_does_not_write_gitignore(self, mock_git, mock_gitignore):
        mock_git.return_value = _git_result()
        git_utils.d_git_configure([])
        mock_gitignore.assert_not_called()


class TestGitignoreTemplate(unittest.TestCase):
    def test_template_has_expected_entries(self):
        for entry in ("node_modules", "*.log", "vendor/", "*.epub", ".idea"):
            self.assertIn(entry, git_utils.GITIGNORE_TEMPLATE)

    @patch("utils.git_utils.os.chmod")
    @patch("utils.git_utils._run_git")
    @patch("utils.git_utils.Path.home")
    def test_write_sets_excludesfile(self, mock_home, mock_git, _chmod):
        from pathlib import Path

        mock_home.return_value = Path("/home/test")
        with patch("pathlib.Path.write_text") as mock_write:
            git_utils._write_global_gitignore()
        mock_write.assert_called_once()
        mock_git.assert_called_once_with(
            "config", "--global", "core.excludesfile", "/home/test/.gitignore"
        )

    @patch("utils.git_utils._run_git")
    @patch("utils.git_utils.Path.home")
    def test_write_failure_returns_none(self, mock_home, mock_git):
        from pathlib import Path

        mock_home.return_value = Path("/home/test")
        with patch("pathlib.Path.write_text", side_effect=OSError("denied")):
            self.assertIsNone(git_utils._write_global_gitignore())
        mock_git.assert_not_called()


if __name__ == "__main__":
    unittest.main(verbosity=2)
