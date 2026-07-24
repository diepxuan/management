#!/usr/bin/env python3
"""Tests for completion cache helpers."""

import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.completion import command_cache_content, write_command_cache
from utils.registry import COMMANDS


class TestCompletionCache(unittest.TestCase):
    def test_command_cache_content_contains_registered_command(self):
        content = command_cache_content()
        self.assertTrue(content.endswith("\n"))
        self.assertIn("completion:cache", content.split())
        self.assertIn("commands", content.split())

    def test_write_command_cache(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            target = Path(tmpdir) / "commands"
            result = write_command_cache(target)
            self.assertEqual(target, result)
            self.assertTrue(target.exists())
            self.assertEqual(command_cache_content(), target.read_text(encoding="utf-8"))

    def test_completion_cache_command_registered(self):
        self.assertIn("completion:cache", COMMANDS)


import subprocess

class TestDuctncliBashCompletion(unittest.TestCase):
    """Validate the bash completion script for `ductncli`.

    The completion must:
      * list agent names that `ductncli --list` reports as installed, AND
      * not list anything else. It must not be hard-coded to a fixed set.
    """

    COMPLETION_PATH = os.path.join(
        os.path.dirname(__file__), "..", "..",
        "src", "ductn", "usr", "share", "bash-completion",
        "completions", "ductncli",
    )

    def _stub_ductncli(self, names):
        """Write a stub `ductncli` that mimics `--list` output and put it
        at the head of PATH inside the subprocess."""
        td = tempfile.mkdtemp()
        stub = os.path.join(td, "ductncli")
        body_lines = ["#!/bin/sh", 'case "$1" in',
                      "  --list|--list-installed)"]
        for n in names:
            body_lines.append(f"    echo '{n}'")
        body_lines.append("    exit 0 ;;")
        body_lines.append("  esac")
        body_lines.append("  exit 0")
        with open(stub, "w") as fh:
            fh.write("\n".join(body_lines) + "\n")
        os.chmod(stub, 0o755)
        return td

    def _run_completion(self, stub_bin, words, cword):
        """Source the completion in bash, fire it with given COMP_* and
        return the contents of $COMPREPLY (one per line)."""
        quoted_words = " ".join(f'"{w}"' for w in words)
        script = (
            "set -e\n"
            f"COMP_WORDS=({quoted_words})\n"
            f"COMP_CWORD={cword}\n"
            'COMP_LINE="${COMP_WORDS[*]}"\n'
            f'COMP_POINT=${{#COMP_LINE}}\n'
            f'. {self.COMPLETION_PATH}\n'
            "_ductncli_completions\n"
            'printf "%s\\n" "${COMPREPLY[@]}"\n'
        )
        env = os.environ.copy()
        env["PATH"] = stub_bin + ":" + env.get("PATH", "/usr/bin:/bin")
        proc = subprocess.run(
            ["bash", "--noprofile", "--norc", "-c", script],
            capture_output=True, text=True, env=env,
        )
        return proc.returncode, proc.stdout, proc.stderr

    def test_completion_lists_only_installed_agents(self):
        """First-arg completion reflects `ductncli --list` and nothing else."""
        stub = self._stub_ductncli(["claude", "codex", "freebuff"])
        rc, out, err = self._run_completion(stub, ["ductncli", ""], 1)
        self.assertEqual(rc, 0, msg=f"bash failed: stderr={err!r}")
        lines = sorted(filter(None, out.splitlines()))
        self.assertIn("claude", lines)
        self.assertIn("codex", lines)
        self.assertIn("freebuff", lines)
        for absent in ("hermes", "openclaw", "gemini", "aider"):
            self.assertNotIn(absent, lines,
                f"{absent} should be hidden because stub does not list it")

    def test_completion_hides_all_uninstalled_agents(self):
        """When `ductncli --list` is empty, no agent names are synthesised."""
        stub = self._stub_ductncli([])
        rc, out, err = self._run_completion(stub, ["ductncli", ""], 1)
        self.assertEqual(rc, 0, msg=f"bash failed: stderr={err!r}")
        for known in ("claude", "codex", "hermes"):
            self.assertNotIn(known, out.splitlines())

    def test_completion_filters_by_prefix(self):
        """`ductncli cl<TAB>` only returns `claude`."""
        stub = self._stub_ductncli(["claude", "codex", "freebuff"])
        rc, out, err = self._run_completion(stub, ["ductncli", "cl"], 1)
        self.assertEqual(rc, 0, msg=f"bash failed: stderr={err!r}")
        self.assertIn("claude", out.splitlines())
        self.assertNotIn("codex", out.splitlines())
        self.assertNotIn("freebuff", out.splitlines())

    def test_completion_file_parses(self):
        """`bash -n` on the completion file must exit 0."""
        proc = subprocess.run(
            ["bash", "-n", self.COMPLETION_PATH],
            capture_output=True, text=True,
        )
        self.assertEqual(proc.returncode, 0, msg=f"bash -n failed: {proc.stderr}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
