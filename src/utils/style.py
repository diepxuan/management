#!/usr/bin/env python3
"""Terminal styling + status glyphs (salvaged from environment.color.sh / environment.text.sh).

The legacy bash files defined ~50 ANSI colour variables (``Green``, ``BRed``,
``On_IWhite``, …) and three status glyphs (``TXTtrue`` / ``TXTfalse`` /
``TXTinfo``). They were never migrated; the Python CLI printed plain text and
the reports lost the ✓/✗ markers.

This module keeps the useful subset: the 16 base colours, bold/underline/
background variants, and the three status glyphs. The 24-bit and 8-bit tables
from ``environment.color.sh`` were pure documentation comments and are not
carried over.

Colour output is suppressed automatically when stdout is not a TTY or when
``NO_COLOR`` is set, so logs and pipes stay clean.
"""

import os
import sys

# --- Reset -------------------------------------------------------------
RESET = "\033[0m"
NC = RESET  # bash alias

# --- Regular -----------------------------------------------------------
BLACK = "\033[0;30m"
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
BLUE = "\033[0;34m"
PURPLE = "\033[0;35m"
CYAN = "\033[0;36m"
WHITE = "\033[0;37m"

# --- Bold --------------------------------------------------------------
B_BLACK = "\033[1;30m"
B_RED = "\033[1;31m"
B_GREEN = "\033[1;32m"
B_YELLOW = "\033[1;33m"
B_BLUE = "\033[1;34m"
B_PURPLE = "\033[1;35m"
B_CYAN = "\033[1;36m"
B_WHITE = "\033[1;37m"

# --- Underline ---------------------------------------------------------
U_BLACK = "\033[4;30m"
U_RED = "\033[4;31m"
U_GREEN = "\033[4;32m"
U_YELLOW = "\033[4;33m"
U_BLUE = "\033[4;34m"
U_PURPLE = "\033[4;35m"
U_CYAN = "\033[4;36m"
U_WHITE = "\033[4;37m"

# --- Background --------------------------------------------------------
ON_BLACK = "\033[40m"
ON_RED = "\033[41m"
ON_GREEN = "\033[42m"
ON_YELLOW = "\033[43m"
ON_BLUE = "\033[44m"
ON_PURPLE = "\033[45m"
ON_CYAN = "\033[46m"
ON_WHITE = "\033[47m"

# --- Status glyphs (bash: TXTtrue / TXTfalse / TXTinfo) ----------------
GLYPH_TRUE = "\u2713"  # ✓
GLYPH_FALSE = "\u2717"  # ✗
GLYPH_INFO = "i"

# bash used $TXTtrue / $TXTfalse / $TXTinfo as pre-composed strings.
TXT_TRUE = f"[{GREEN}{GLYPH_TRUE}{RESET}]"
TXT_FALSE = f"[{RED}{GLYPH_FALSE}{RESET}]"
TXT_INFO = f"[{YELLOW}{GLYPH_INFO}{RESET}]"


def color_enabled():
    """True when ANSI colour should be emitted."""
    if os.environ.get("NO_COLOR"):
        return False
    if os.environ.get("DUCTN_NO_COLOR"):
        return False
    try:
        return sys.stdout.isatty()
    except (AttributeError, ValueError):
        return False


def c(text, code):
    """Wrap ``text`` in an ANSI code, or return it unchanged when colour is off."""
    if not color_enabled():
        return text
    return f"{code}{text}{RESET}"


def ok(text):
    """``[✓] text`` — success line (bash: ``[$Green✓$NC]``)."""
    return f"{TXT_TRUE if color_enabled() else '[v]'} {text}"


def fail(text):
    """``[✗] text`` — failure line (bash: ``[$Red✗$NC]``)."""
    return f"{TXT_FALSE if color_enabled() else '[x]'} {text}"


def info(text):
    """``[i] text`` — informational line (bash: ``[$Yellow i $NC]``)."""
    return f"{TXT_INFO if color_enabled() else '[i]'} {text}"


# Legacy GLYPH names used by the bash scripts that referenced $TXTtrue.
TXTtrue = TXT_TRUE
TXTfalse = TXT_FALSE
TXTinfo = TXT_INFO
