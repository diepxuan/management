#!/usr/bin/env python3
"""Bash completion cache maintenance commands."""

from pathlib import Path

from .command import _commands
from .registry import register_command

DEFAULT_COMMAND_CACHE = Path("/usr/share/ductn/commands")


def command_cache_content():
    """Return the command cache content as one shell-friendly line."""
    return " ".join(_commands()) + "\n"


def write_command_cache(path=DEFAULT_COMMAND_CACHE):
    """Write ductn command cache and return the target path."""
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(command_cache_content(), encoding="utf-8")
    return target


def _print_help():
    print("ductn completion:cache <action> [path]")
    print("")
    print("Actions:")
    print("  show [path]      Print command cache content or generated command list.")
    print("  refresh [path]   Regenerate command cache. Default: /usr/share/ductn/commands")
    print("  path             Print default command cache path.")


@register_command
def d_completion_cache(args=None):
    """Inspect or refresh ductn bash completion command cache. Usage: ductn completion:cache <show|refresh|path> [path]"""
    args = args or []
    action = args[0] if args else "show"
    path = Path(args[1]) if len(args) > 1 else DEFAULT_COMMAND_CACHE

    if action in ("-h", "--help", "help"):
        _print_help()
        return

    if action == "path":
        print(DEFAULT_COMMAND_CACHE)
        return

    if action == "show":
        if path.exists():
            print(path.read_text(encoding="utf-8").strip())
        else:
            print(command_cache_content().strip())
        return

    if action == "refresh":
        target = write_command_cache(path)
        print(f"Wrote command cache: {target}")
        return

    print(f"Unknown completion cache action: {action}")
    _print_help()
    raise SystemExit(2)
