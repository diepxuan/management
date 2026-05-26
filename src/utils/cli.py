"""Developer CLI helpers for launching agents in tmux."""

import os
import shutil
import subprocess
import sys
from pathlib import Path

from .registry import register_command


SCRIPT_PATH = Path("/usr/bin/ductncli")
TMUX_CONFIG_SOURCE = Path("/etc/ductn/tmux.conf")
TMUX_CONFIG_TARGET = Path.home() / ".tmux.conf"


@register_command("cli")
def d_cli(args=None):
    """Launch Hermes/Codex tmux workspace helper."""
    if args is None:
        args = []

    if not SCRIPT_PATH.exists():
        print(f"ERROR: ductncli script not found: {SCRIPT_PATH}", file=sys.stderr)
        print("Install or reinstall the ductn package to enable `ductn cli`.", file=sys.stderr)
        return 1

    os.execv(str(SCRIPT_PATH), [str(SCRIPT_PATH), *args])


@register_command("cli:tmux:install")
def d_cli_tmux_install(args=None):
    """Install ductn tmux config to ~/.tmux.conf."""
    source = TMUX_CONFIG_SOURCE
    target = TMUX_CONFIG_TARGET

    if args:
        target = Path(args[0]).expanduser()

    if not source.exists():
        print(f"ERROR: tmux config source not found: {source}", file=sys.stderr)
        return 1

    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(source.read_bytes())
    print(f"Installed tmux config: {target}")
    return 0


@register_command("cli:tmux:reload")
def d_cli_tmux_reload(args=None):
    """Reload ~/.tmux.conf for current tmux server."""
    target = TMUX_CONFIG_TARGET
    if args:
        target = Path(args[0]).expanduser()

    if not target.exists():
        print(f"ERROR: tmux config not found: {target}", file=sys.stderr)
        return 1

    if not shutil.which("tmux"):
        print("ERROR: tmux command not found", file=sys.stderr)
        return 1

    subprocess.run(["tmux", "source-file", str(target)], check=True)
    print(f"Reloaded tmux config: {target}")
    return 0
