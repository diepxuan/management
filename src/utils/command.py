#!/usr/bin/env python3
from . import COMMANDS
from . import register_command


def _commands():
    """Hiển thị danh sách commands"""
    return sorted(list(COMMANDS.keys()))


@register_command
def d_commands():
    """Hiển thị danh sách commands"""
    print(" ".join(_commands()))


# -------------------------------
# Chạy lệnh với args nếu cần
# -------------------------------
def command_run(func, args=None):
    """Tự động truyền args nếu hàm có tham số."""
    import inspect

    sig = inspect.signature(func)
    parameters = list(sig.parameters.values())

    if not parameters:
        func()
    elif len(parameters) == 1:
        func(args)
    else:
        func(*(args or []))
