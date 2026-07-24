#!/usr/bin/env python3
"""Tests for the `ductn prompt` CLI helper."""
import os
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import prompt


class TestPrompt(unittest.TestCase):
    def test_opt_out_path_uses_xdg_config_home(self):
        with patch.dict(os.environ, {"XDG_CONFIG_HOME": "/custom/cfg"}):
            self.assertEqual(prompt._opt_out_path(), Path("/custom/cfg/ductn/no-prompt"))

    def test_opt_out_path_defaults_to_home_dotconfig(self):
        with patch.dict(os.environ, {}, clear=False):
            os.environ.pop("XDG_CONFIG_HOME", None)
            self.assertEqual(prompt._opt_out_path(), Path.home() / ".config" / "ductn" / "no-prompt")

    def test_conffile_exists_true(self):
        with patch.object(Path, "is_file", return_value=True):
            self.assertTrue(prompt._conffile_exists())

    def test_conffile_exists_false(self):
        with patch.object(Path, "is_file", return_value=False):
            self.assertFalse(prompt._conffile_exists())

    def test_status_enabled(self):
        with patch.object(prompt, "_conffile_exists", return_value=True), \
             patch.object(Path, "exists", return_value=False), \
             patch.dict(os.environ, {}, clear=False):
            os.environ.pop("DUCTN_PROMPT_DISABLE", None)
            # rc 0 means enabled
            self.assertEqual(0, prompt.d_prompt(["status"]))

    def test_status_disabled_by_optout(self):
        with patch.object(prompt, "_conffile_exists", return_value=True), \
             patch.object(Path, "exists", return_value=True), \
             patch.dict(os.environ, {}, clear=False):
            os.environ.pop("DUCTN_PROMPT_DISABLE", None)
            self.assertEqual(1, prompt.d_prompt(["status"]))

    def test_status_disabled_by_env(self):
        with patch.object(prompt, "_conffile_exists", return_value=True), \
             patch.object(Path, "exists", return_value=False), \
             patch.dict(os.environ, {"DUCTN_PROMPT_DISABLE": "1"}):
            self.assertEqual(1, prompt.d_prompt(["status"]))

    def test_status_disabled_when_conffile_missing(self):
        with patch.object(prompt, "_conffile_exists", return_value=False), \
             patch.object(Path, "exists", return_value=False), \
             patch.dict(os.environ, {}, clear=False):
            os.environ.pop("DUCTN_PROMPT_DISABLE", None)
            self.assertEqual(1, prompt.d_prompt(["status"]))

    def test_enable_removes_optout(self):
        with tempfile.TemporaryDirectory() as td:
            opt = Path(td) / "ductn" / "no-prompt"
            opt.parent.mkdir(parents=True, exist_ok=True)
            opt.write_text("")
            with patch.object(prompt, "_opt_out_path", return_value=opt):
                rc = prompt.d_prompt(["enable"])
            self.assertEqual(0, rc)
            self.assertFalse(opt.exists())

    def test_enable_no_op_when_missing(self):
        with tempfile.TemporaryDirectory() as td:
            opt = Path(td) / "ductn" / "no-prompt"
            with patch.object(prompt, "_opt_out_path", return_value=opt):
                rc = prompt.d_prompt(["enable"])
            self.assertEqual(0, rc)
            self.assertFalse(opt.exists())

    def test_disable_creates_optout(self):
        with tempfile.TemporaryDirectory() as td:
            opt = Path(td) / "ductn" / "no-prompt"
            self.assertFalse(opt.exists())
            with patch.object(prompt, "_opt_out_path", return_value=opt):
                rc = prompt.d_prompt(["disable"])
            self.assertEqual(0, rc)
            self.assertTrue(opt.exists())

    def test_unknown_subcommand_returns_2(self):
        with patch("sys.stderr") as fake_err:
            rc = prompt.d_prompt(["bogus"])
        self.assertEqual(2, rc)
        fake_err.write.assert_called()

    def test_help_subcommand(self):
        rc = prompt.d_prompt(["--help"])
        self.assertEqual(0, rc)

    def test_default_subcommand_is_status(self):
        with patch.object(prompt, "_print_status", return_value=0) as mock_status:
            rc = prompt.d_prompt([])
        self.assertEqual(0, rc)
        mock_status.assert_called_once_with()


if __name__ == "__main__":
    unittest.main()

class TestShellPromptScript(unittest.TestCase):
    """Validate /etc/profile.d/ductn-prompt.sh shell script.

    The script previously contained an inline sed substitution
    `sed "s/^/ (/;s/$/)/"` that BSD sed rejected with
    "unterminated `s' command" because the trailing `/` is missing
    before `;`. These tests pin the fix: the rendered PS1 must not contain
    any inline sed expression, must include the branch in `(branch)` form
    when a git repo is detected, and must omit the branch otherwise.
    """

    SCRIPT_PATH = os.path.join(
        os.path.dirname(__file__), "..", "..", "src", "ductn", "etc", "profile.d", "ductn-prompt.sh"
    )

    def _render_ps1(self, cwd, home, ps1=r"\s-\v\$ "):
        """Source the script in an interactive bash, then return rendered PS1.

        The script guards on `$-` containing `i`, so we run `bash -i` to
        satisfy that. We export PS1 to match one of the script's case
        arms, source the script, call __ductn_prompt_set, and read $PS1.
        """
        import subprocess
        script = (
            "set -e\n"
            "export PS1=" + repr(ps1) + "\n"
            "unset DUCTN_PROMPT_LOADED DUCTN_PROMPT_DISABLE\n"
            ". " + self.SCRIPT_PATH + "\n"
            "__ductn_prompt_set\n"
            'printf "%s" "$PS1"\n'
        )
        env = {
            "PATH": "/usr/bin:/bin:/usr/local/bin",
            "HOME": home,
            "XDG_CONFIG_HOME": home,
            "LANG": "C.UTF-8",
        }
        proc = subprocess.run(
            ["bash", "-i", "-c", script],
            capture_output=True, text=True, env=env, cwd=cwd,
        )
        return proc.returncode, proc.stdout, proc.stderr

    def test_no_inline_sed_in_prompt_set_body(self):
        """The fix removes the BSD-incompatible inline sed from the function body."""
        with open(self.SCRIPT_PATH, "r", encoding="utf-8") as fh:
            content = fh.read()
        m = re.search(
            r"__ductn_prompt_set\s*\(\)\s*\{(.*?)^\}",
            content, re.DOTALL | re.MULTILINE,
        )
        self.assertIsNotNone(m, "__ductn_prompt_set function not found")
        body = m.group(1)
        # Strip line comments to avoid matching the explanation block
        code_only = re.sub(r"#[^\n]*", "", body)
        self.assertNotIn('sed "s/', code_only)
        self.assertNotIn("sed 's/", code_only)

    def test_ps1_renders_branch_when_in_git_repo(self):
        """Inside a git repo, PS1 must include '(branch)' in yellow."""
        with tempfile.TemporaryDirectory() as td:
            subprocess.run(
                ["git", "init", "-q"], cwd=td, check=False, capture_output=True,
            )
            subprocess.run(
                ["git", "-c", "user.email=t@t", "-c", "user.name=t",
                 "commit", "-q", "--allow-empty", "-m", "init"],
                cwd=td, check=False, capture_output=True,
            )
            subprocess.run(
                ["git", "checkout", "-q", "-b", "fix/test-branch"],
                cwd=td, check=False, capture_output=True,
            )
            rc, out, err = self._render_ps1(cwd=td, home=td)
        self.assertEqual(rc, 0, msg=f"bash failed: stderr={err!r}")
        self.assertIn("(fix/test-branch)", out)
        # Yellow ANSI prefix: ESC[01;33m = [01;33m
        self.assertIn("\x1b[01;33m", out,
            "Branch must be wrapped in yellow ANSI sequence")

    def test_ps1_omits_branch_outside_git_repo(self):
        """Outside any git repo, PS1 must not include (branch)."""
        with tempfile.TemporaryDirectory() as td:
            rc, out, err = self._render_ps1(cwd=td, home=td)
        self.assertEqual(rc, 0, msg=f"bash failed: stderr={err!r}")
        self.assertNotIn("(branch)", out)
        # No sed substitution must remain in the rendered PS1 string
        self.assertNotIn('sed "s/', out)
        self.assertNotIn("sed 's/", out)

    def test_no_sed_unterminated_error_on_render(self):
        """Stderr must not contain the BSD sed unterminated error."""
        with tempfile.TemporaryDirectory() as td:
            subprocess.run(
                ["git", "init", "-q"], cwd=td, check=False, capture_output=True,
            )
            rc, out, err = self._render_ps1(cwd=td, home=td)
        self.assertEqual(rc, 0, msg=f"bash failed: stderr={err!r}")
        self.assertNotIn("unterminated", err)
        self.assertNotIn("unterminated", out)


class TestShellPromptDynamicUpdate(unittest.TestCase):
    """Validate /etc/profile.d/ductn-prompt.sh installs a PROMPT_COMMAND
    hook that rebuilds PS1 on each prompt. Without it the (branch) suffix
    stays frozen at the value captured when the shell started, so `cd`
    into or out of a git repo leaves the prompt misleading.
    """

    SCRIPT_PATH = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "..", "..", "src", "ductn", "etc",
        "profile.d", "ductn-prompt.sh"
    ))

    def _source_in(self, cwd, home, ps1, existing_prompt_command=""):
        """Source the script under bash, return (rc, stdout, stderr).

        We `export PROMPT_COMMAND` to a known prior value (when requested)
        so the script's prepend behaviour can be observed.
        """
        body_lines = [
            "set -e",
            "export PROMPT_COMMAND='%s'" % existing_prompt_command,
            "export PS1='%s'" % ps1,
            "unset DUCTN_PROMPT_LOADED DUCTN_PROMPT_DISABLE",
            ". %s" % self.SCRIPT_PATH,
            "echo \"PC=$PROMPT_COMMAND\"",
            "echo \"PS1=$PS1\""
        ]
        script = "\n".join(body_lines) + "\n"
        env = {
            "PATH": "/usr/bin:/bin:/usr/local/bin",
            "HOME": home,
            "XDG_CONFIG_HOME": home,
            "LANG": "C.UTF-8",
        }
        proc = subprocess.run(
            ["bash", "-i", "-c", script],
            capture_output=True, text=True, env=env, cwd=cwd,
        )
        return proc.returncode, proc.stdout, proc.stderr

    def test_prompt_command_installs_when_ps1_is_default(self):
        """Default-PS1 shells must install __ductn_prompt_command."""
        with tempfile.TemporaryDirectory() as td:
            rc, out, err = self._source_in(
                cwd=td, home=td, ps1=r"\s-\v\$ ",
            )
        self.assertEqual(rc, 0, msg=f"bash failed: stderr={err!r}")
        self.assertIn("PC=__ductn_prompt_command", out)

    def test_prompt_command_preserves_existing_chain(self):
        """Ubuntu/Debian sets PROMPT_COMMAND for window-title updates; that
        chain must be preserved AND our hook must run first."""
        with tempfile.TemporaryDirectory() as td:
            rc, out, err = self._source_in(
                cwd=td, home=td, ps1=r"\s-\v\$ ",
                existing_prompt_command="update_terminal_cwd",
            )
        self.assertEqual(rc, 0, msg=f"bash failed: stderr={err!r}")
        self.assertIn(
            "__ductn_prompt_command; update_terminal_cwd", out,
            "PROMPT_COMMAND must be chained, not replaced",
        )

    def test_prompt_command_rebuilds_ps1_after_cd_into_repo(self):
        """`cd` from non-repo into a git repo must update (branch) on the
        next prompt when PROMPT_COMMAND fires. The bug report shipped PS1
        that was frozen at shell-load; this test pins the dynamic fix."""
        with tempfile.TemporaryDirectory() as outside:
            inside = os.path.join(outside, "inner")
            os.makedirs(inside, exist_ok=True)
            subprocess.run(
                ["git", "init", "-q"], cwd=inside, check=False,
                capture_output=True,
            )
            subprocess.run(
                ["git", "-c", "user.email=t@t", "-c", "user.name=t",
                 "commit", "-q", "--allow-empty", "-m", "init"],
                cwd=inside, check=False, capture_output=True,
            )
            subprocess.run(
                ["git", "checkout", "-q", "-b", "release/dynamic-prompt"],
                cwd=inside, check=False, capture_output=True,
            )
            script_lines = [
                "set -e",
                r"export PS1='\s-\v\$ '",
                "unset DUCTN_PROMPT_LOADED DUCTN_PROMPT_DISABLE",
                ". %s" % self.SCRIPT_PATH,
                # Outside repo: PS1 has no (branch) suffix.
                "__ductn_prompt_set",
                'printf "BEFORE=%s\\n" "$PS1"',
                # Now switch cwd into the repo, then run our prompt hook.
                "cd %s" % inside,
                "__ductn_prompt_command",
                'printf "AFTER=%s\\n" "$PS1"',
            ]
            script = "\n".join(script_lines) + "\n"
            env = {
                "PATH": "/usr/bin:/bin:/usr/local/bin",
                "HOME": outside,
                "XDG_CONFIG_HOME": outside,
                "LANG": "C.UTF-8",
            }
            proc = subprocess.run(
                ["bash", "-i", "-c", script],
                capture_output=True, text=True, env=env, cwd=outside,
            )
            self.assertEqual(
                proc.returncode, 0,
                msg=f"bash failed: stderr={proc.stderr!r}",
            )
            before, after = "", ""
            for line in proc.stdout.splitlines():
                if line.startswith("BEFORE="):
                    before = line[len("BEFORE="):]
                elif line.startswith("AFTER="):
                    after = line[len("AFTER="):]
            self.assertNotIn(
                "(release/dynamic-prompt)", before,
                "PS1 outside repo must not contain the branch",
            )
            self.assertIn(
                "(release/dynamic-prompt)", after,
                "PROMPT_COMMAND must refresh PS1 to the current branch",
            )


if __name__ == "__main__":
    unittest.main()
