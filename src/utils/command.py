#!/usr/bin/env python3
from .registry import COMMANDS, register_command


def _commands():
    """Return sorted command names."""
    return sorted(COMMANDS.keys())


def _command_group(command_name):
    """Return display group for a command name."""
    if command_name.startswith("zfs:disk:"):
        return "zfs"
    if ":" in command_name:
        return command_name.split(":", 1)[0]
    return "core"


def _commands_by_group():
    """Return commands grouped by first namespace."""
    grouped = {}
    for command_name in _commands():
        grouped.setdefault(_command_group(command_name), []).append(command_name)
    return dict(sorted(grouped.items()))


def _command_description(command_name):
    """Return first-line docstring for a command."""
    func = COMMANDS.get(command_name)
    if not func or not func.__doc__:
        return ""
    return func.__doc__.strip().split("\n", 1)[0]


def render_command_tree(include_descriptions=False):
    """Render commands as a readable tree grouped by namespace."""
    lines = []
    grouped = _commands_by_group()
    group_items = list(grouped.items())

    for group_index, (group, commands) in enumerate(group_items):
        group_is_last = group_index == len(group_items) - 1
        group_branch = "└──" if group_is_last else "├──"
        child_prefix = "    " if group_is_last else "│   "
        lines.append(f"{group_branch} {group}")

        for command_index, command_name in enumerate(commands):
            command_is_last = command_index == len(commands) - 1
            command_branch = "└──" if command_is_last else "├──"
            line = f"{child_prefix}{command_branch} {command_name}"
            if include_descriptions:
                description = _command_description(command_name)
                if description:
                    line = f"{line:<36} {description}"
            lines.append(line)

    return "\n".join(lines)


def print_command_list(grouped=False):
    """Print commands, optionally grouped by namespace."""
    if not grouped:
        print(" ".join(_commands()))
        return

    print(render_command_tree())


@register_command
def d_commands(args=None):
    """List available commands."""
    args = args or []
    if isinstance(args, str):
        args = args.split()
    print_command_list(grouped="--grouped" in args or "-g" in args)


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
