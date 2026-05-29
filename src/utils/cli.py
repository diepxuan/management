"""Developer CLI helpers for launching agents."""

import os
import sys
from pathlib import Path

from .registry import register_command


SCRIPT_PATH = Path("/usr/bin/ductncli")


@register_command("cli")
def d_cli(args=None):
    """Launch Hermes/Codex workspace helper (delegates to ductncli script)."""
    if args is None:
        args = []

    if not SCRIPT_PATH.exists():
        print(f"ERROR: ductncli script not found: {SCRIPT_PATH}", file=sys.stderr)
        print("Install or reinstall the ductn package to enable `ductn cli`.", file=sys.stderr)
        return 1

    os.execv(str(SCRIPT_PATH), [str(SCRIPT_PATH), *args])

