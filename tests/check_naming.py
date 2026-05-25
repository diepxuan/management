#!/usr/bin/env python3
"""Check naming conventions for all command functions."""
import sys
import os

SRC_DIR = os.path.join(os.path.dirname(__file__), "..", "src")
sys.path.insert(0, SRC_DIR)

os.geteuid = lambda: 0

from utils.registry import COMMANDS

errors = []

# Check 1: All functions start with d_
for name, func in COMMANDS.items():
    if not func.__name__.startswith("d_"):
        errors.append(f"  {name:40s} func={func.__name__} (không bắt đầu bằng d_)")

# Check 2: All commands have docstrings
for name, func in COMMANDS.items():
    if not func.__doc__ or not func.__doc__.strip():
        errors.append(f"  {name:40s} (thiếu docstring)")

if errors:
    print(f"FAIL: {len(errors)} naming violations found:\n")
    for e in errors:
        print(e)
    sys.exit(1)

print(f"OK: {len(COMMANDS)} commands — tất cả đúng convention")
sys.exit(0)
