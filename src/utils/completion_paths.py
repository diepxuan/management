#!/usr/bin/env python3
"""Discover third-party bash completion scripts (salvaged from completion.sh).

``completion.sh`` had six lookup functions (``sys:completion:base|magerun|
magerun2|wp|angular``) that each searched two locations and printed the first
existing path:

    /var/www/base/bash/completion/<name>.sh
    $HOME/.completion/<name>.sh

``src/utils/completion.py`` only manages the ductn command cache — the
third-party discovery was never migrated, so ``ductn`` could not tell a shell
where the magerun2/wp completion lived.

This module keeps that lookup as a single command with a ``<tool>`` argument
instead of five near-identical functions.
"""

import logging
import os
from pathlib import Path

from .registry import register_command

# Tools the bash version supported.
KNOWN_TOOLS = ("ductn", "magerun", "magerun2", "wp", "angular")

# bash mapped `angular` to angular2.sh — keep that quirk for compatibility.
FILE_ALIASES = {"angular": "angular2"}

SYSTEM_DIR = Path("/var/www/base/bash/completion")
USER_DIR = Path("~/.completion")


def _candidate_dirs():
    """Ordered lookup dirs: system first, then per-user (same as bash)."""
    return [SYSTEM_DIR, Path(os.path.expanduser(str(USER_DIR)))]


def _find_completion(tool):
    """Return the first existing completion path for ``tool``, else None."""
    stem = FILE_ALIASES.get(tool, tool)
    for directory in _candidate_dirs():
        candidate = directory / f"{stem}.sh"
        try:
            if candidate.is_file():
                return candidate
        except OSError:
            continue
    return None


def _tool_exists(tool):
    """bash ``sys:completion:exists`` — ``command -v`` equivalent."""
    from shutil import which

    return which(tool) is not None


@register_command
def d_completion_path(args=None):
    """
    In đường dẫn file bash completion của tool bên thứ ba.
    Usage: ductn completion:path <tool>

    Tool hỗ trợ: ductn, magerun, magerun2, wp, angular.
    Tìm trong /var/www/base/bash/completion/ rồi ~/.completion/.
    Exit code 0 nếu tìm thấy, 1 nếu không.
    """
    if not args:
        logging.error("Usage: ductn completion:path <%s>", "|".join(KNOWN_TOOLS))
        raise SystemExit(1)

    tool = args[0] if isinstance(args, list) else args
    path = _find_completion(tool)

    if path is None:
        logging.error(
            "Không tìm thấy completion cho '%s' (đã tìm: %s)",
            tool,
            ", ".join(str(d) for d in _candidate_dirs()),
        )
        raise SystemExit(1)

    print(path)
    return 0


@register_command
def d_completion_exists(args=None):
    """
    Kiểm tra một tool có trong PATH hay không.
    Usage: ductn completion:exists <tool>
    In 1 nếu có, 0 nếu không (giữ đúng hành vi bash cũ).
    """
    if not args:
        logging.error("Usage: ductn completion:exists <tool>")
        return

    tool = args[0] if isinstance(args, list) else args
    print(1 if _tool_exists(tool) else 0)
