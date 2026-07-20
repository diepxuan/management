#!/usr/bin/env python3
"""Tests for the developer agent launcher."""
import os
import sys
import tempfile
import unittest
from pathlib import Path
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

    # -------- 5.7.2: extended registry --------

    def test_default_registry_includes_freebuff(self):
        names = list(cli.list_default_agent_names())
        self.assertIn("freebuff", names)
        self.assertIn("claude", names)
        self.assertIn("gemini", names)

    def test_resolve_agents_returns_merged_default(self):
        entries = cli._resolve_agents({})
        names = [e["name"] for e in entries]
        self.assertEqual(names[0], "hermes")
        self.assertIn("codex", names)
        self.assertIn("openclaw", names)

    def test_resolve_agents_overrides_existing_args(self):
        cfg = {"agents": [
            {"name": "codex", "args": ["--profile", "custom"], "description": "Custom codex"},
        ]}
        entries = cli._resolve_agents(cfg)
        codex = next(e for e in entries if e["name"] == "codex")
        self.assertEqual(codex["args"], ["--profile", "custom"])
        self.assertEqual(codex["description"], "Custom codex")

    def test_resolve_agents_adds_new_agent(self):
        cfg = {"agents": [
            {"name": "mybot", "args": ["--foo"], "description": "Custom agent"},
        ]}
        names = [e["name"] for e in cli._resolve_agents(cfg)]
        self.assertIn("mybot", names)

    def test_resolve_agents_disables_default_agent(self):
        cfg = {"agents": [{"name": "gemini", "enabled": False}]}
        gemini = next(e for e in cli._resolve_agents(cfg) if e["name"] == "gemini")
        self.assertFalse(gemini["enabled"])

    @patch.dict(os.environ, {"DuctnCLI_AGENT_ARGS_CODEX": "--profile envOverride"})
    def test_env_var_overrides_args(self):
        entries = cli._resolve_agents({})
        codex = next(e for e in entries if e["name"] == "codex")
        self.assertEqual(codex["args"], ["--profile", "envOverride"])

    def test_yaml_loader_parses_agents_list(self):
        with tempfile.TemporaryDirectory() as tmp:
            cfg = Path(tmp) / "config.yml"
            cfg.write_text(
                "agents:\n"
                "  - name: codex\n"
                "    args:\n"
                "      - --profile\n"
                "      - alt\n"
                "    description: Alt codex\n"
                "  - name: freebuff\n"
                "    enabled: false\n"
                "  - name: mybot\n"
                "    args:\n"
                "      - --foo\n"
                "      - bar\n",
                encoding="utf-8",
            )
            data = cli._load_yaml_config(cfg)
        self.assertIn("agents", data)
        self.assertEqual(len(data["agents"]), 3)
        codex = data["agents"][0]
        self.assertEqual(codex["name"], "codex")
        self.assertEqual(codex["args"], ["--profile", "alt"])
        self.assertEqual(codex["description"], "Alt codex")
        self.assertEqual(data["agents"][1], {"name": "freebuff", "enabled": False})
        self.assertEqual(data["agents"][2]["args"], ["--foo", "bar"])

    def test_yaml_loader_strips_comments_and_quotes(self):
        with tempfile.TemporaryDirectory() as tmp:
            cfg = Path(tmp) / "config.yml"
            cfg.write_text(
                '# top-level comment\n'
                'agents:\n'
                '  - name: codex # inline comment\n'
                '    description: "Quoted desc" # trailing comment\n',
                encoding="utf-8",
            )
            data = cli._load_yaml_config(cfg)
        self.assertEqual(data["agents"][0]["name"], "codex")
        self.assertEqual(data["agents"][0]["description"], "Quoted desc")

    def test_yaml_loader_handles_bool_int_null(self):
        with tempfile.TemporaryDirectory() as tmp:
            cfg = Path(tmp) / "config.yml"
            cfg.write_text(
                "flag: yes\n"
                "off: no\n"
                "n: 42\n"
                "f: 3.14\n"
                "z: null\n",
                encoding="utf-8",
            )
            data = cli._load_yaml_config(cfg)
        self.assertIs(data["flag"], True)
        self.assertIs(data["off"], False)
        self.assertEqual(data["n"], 42)
        self.assertEqual(data["f"], 3.14)
        self.assertIsNone(data["z"])

    def test_yaml_loader_returns_empty_for_missing_file(self):
        self.assertEqual({}, cli._load_yaml_config(Path("/nonexistent.yml")))

    @patch.object(cli, "_resolve_agent_binary")
    def test_available_agents_filters_uninstalled(self, resolve_bin):
        # Only codex and freebuff are installed on the host fixture.
        def fake_resolve(name):
            return "/usr/bin/" + name if name in ("codex", "freebuff") else None
        resolve_bin.side_effect = fake_resolve

        names = cli._available_agent_names()
        self.assertIn("codex", names)
        self.assertIn("freebuff", names)
        self.assertNotIn("claude", names)
        self.assertNotIn("gemini", names)

    @patch.object(cli, "_resolve_agent_binary")
    @patch.object(cli, "_resolve_workspace_dir", return_value="/data/portal")
    @patch.object(cli, "_confirm_start")
    @patch.object(cli, "_start_agent")
    def test_freebuff_agent_starts_when_installed(
        self, start_agent, confirm_start, resolve_workspace, resolve_bin,
    ):
        resolve_bin.return_value = "/usr/local/bin/freebuff"

        cli.d_cli(["freebuff", "portal"])

        confirm_start.assert_called_once_with("freebuff", "/data/portal")
        start_agent.assert_called_once_with("freebuff", "/data/portal")

    @patch.object(cli, "_resolve_agent_binary", return_value=None)
    def test_uninstalled_agent_is_rejected(self, _resolve_bin):
        with self.assertRaises(SystemExit):
            cli.d_cli(["claude"])

    @patch.object(cli, "_resolve_agent_binary")
    def test_unknown_agent_is_rejected(self, resolve_bin):
        resolve_bin.return_value = "/usr/bin/codex"
        with self.assertRaises(SystemExit):
            cli.d_cli(["does-not-exist"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
