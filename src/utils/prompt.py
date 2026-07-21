#!/usr/bin/env python3
"""Manage the /etc/profile.d/ductn-prompt.sh conffile from `ductn prompt`.

Sub-commands:
  status   — show whether the conffile is installed and the user opt-out
  enable   — remove the user opt-out file (default behaviour on login)
  disable  — create the user opt-out file (turn prompt off)
"""

import os
import sys
from pathlib import Path

from .registry import register_command

CONFFILE = "/etc/profile.d/ductn-prompt.sh"


def _opt_out_path():
    cfg_root = os.environ.get("XDG_CONFIG_HOME") or str(Path.home() / ".config")
    return Path(cfg_root) / "ductn" / "no-prompt"


def _conffile_exists():
    try:
        return Path(CONFFILE).is_file()
    except OSError:
        return False


def _print_status():
    conffile = _conffile_exists()
    opt_out = _opt_out_path().exists()
    env_flag = bool(os.environ.get("DUCTN_PROMPT_DISABLE"))

    print(f"Conffile       : {CONFFILE}  ({'installed' if conffile else 'MISSING'})")
    print(f"User opt-out   : {_opt_out_path()}  ({'present' if opt_out else 'absent'})")
    print(f"Env override   : DUCTN_PROMPT_DISABLE={'1' if env_flag else '0'}")

    enabled = conffile and not opt_out and not env_flag
    print()
    print(f"Result         : {'ENABLED' if enabled else 'DISABLED'}")
    return 0 if enabled else 1


def _enable():
    target = _opt_out_path()
    if target.exists():
        target.unlink()
        print(f"Removed opt-out file: {target}")
    else:
        print(f"Already enabled (no opt-out at {target}).")
    return 0


def _disable():
    target = _opt_out_path()
    target.parent.mkdir(parents=True, exist_ok=True)
    target.touch()
    print(f"Created opt-out file: {target}")
    print("Open a new login shell to apply. Remove the file to re-enable.")
    return 0


@register_command
def d_prompt(args=None):
    """Manage the ductn shell prompt conffile (status|enable|disable)."""
    args = list(args or [])
    if not args:
        args = ["status"]

    sub = args[0]
    rest = args[1:]

    if sub in ("-h", "--help"):
        print(__doc__)
        return 0

    if sub == "status":
        return _print_status()
    if sub == "enable":
        return _enable()
    if sub == "disable":
        return _disable()

    print(f"Unknown sub-command: {sub!r}", file=sys.stderr)
    print("Usage: ductn prompt [status|enable|disable]", file=sys.stderr)
    return 2