#!/usr/bin/env python3
"""Tests for the developer agent launcher."""
import os
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import cli


class TestCli(unittest.TestCase):
    @patch.object(cli.os.path, "isdir")
    def test_resolve_data_project_shortcut(self, isdir):
        isdir.side_effect = lambda path: path == "/data/portal"

        self.assertEqual("/data/portal", cli._resolve_workspace_dir("portal"))

    @patch.object(cli, "_resolve_agent_binary", return_value="/usr/local/bin/openclaw")
    @patch.object(cli, "_resolve_workspace_dir", return_value="/data/portal")
    @patch.object(cli, "_confirm_start")
    @patch.object(cli, "_start_agent")
    def test_openclaw_agent_is_accepted(
        self, start_agent, confirm_start, resolve_workspace, _which
    ):
        cli.d_cli(["openclaw", "portal"])

        resolve_workspace.assert_called_once_with("portal")
        confirm_start.assert_called_once_with("openclaw", "/data/portal")
        start_agent.assert_called_once_with("openclaw", "/data/portal")

    @patch.object(cli, "_resolve_agent_binary", return_value="/usr/local/bin/openclaw")
    @patch.object(cli.os, "chdir")
    @patch.object(cli.os, "open", side_effect=OSError)
    @patch.object(cli.os, "execv")
    def test_openclaw_starts_tui(self, execv, _open, chdir, _which):
        cli._start_agent("openclaw", "/data/portal")

        chdir.assert_called_once_with("/data/portal")
        execv.assert_called_once_with(
            "/usr/local/bin/openclaw", ["/usr/local/bin/openclaw", "tui"]
        )

    @patch.object(cli.shutil, "which", return_value="/root/.local/share/pnpm/openclaw")
    def test_resolver_returns_real_path_from_path(self, which):
        with patch.object(cli.os.path, "realpath", return_value="/pnpm/store/openclaw"):
            self.assertEqual("/pnpm/store/openclaw", cli._resolve_agent_binary("openclaw"))
        which.assert_called_once_with("openclaw")

    @patch.object(cli.shutil, "which", return_value=None)
    @patch.object(cli.Path, "home", return_value=cli.Path("/root"))
    @patch.object(cli.os, "access")
    @patch.object(cli.os.path, "isfile")
    def test_resolver_supports_pnpm_layout(self, isfile, access, _home, _which):
        expected = "/root/.local/share/pnpm/bin/codex"
        isfile.side_effect = lambda path: path == expected
        access.side_effect = lambda path, mode: path == expected and mode == os.X_OK

        self.assertEqual(expected, cli._resolve_agent_binary("codex"))

    @patch.object(cli.shutil, "which", return_value=None)
    @patch.object(cli.os, "access")
    @patch.object(cli.os.path, "isfile")
    def test_resolver_supports_apt_and_global_npm_bin(self, isfile, access, _which):
        expected = "/usr/bin/openclaw"
        isfile.side_effect = lambda path: path == expected
        access.side_effect = lambda path, mode: path == expected and mode == os.X_OK

        self.assertEqual(expected, cli._resolve_agent_binary("openclaw"))


if __name__ == "__main__":
    unittest.main(verbosity=2)
