#!/usr/bin/env python3

import argparse
import inspect
import sys

PACKAGE_NAME = "ductn"
SERVICE_NAME = "ductnd"

import utils


COMMON_COMMANDS = [
    "help",
    "commands",
    "version",
    "sys:info",
    "apt:check",
    "apt:fix",
    "ssh:cleanup",
    "service:status",
    "log:watch",
]


class DuctnParser(argparse.ArgumentParser):
    """ArgumentParser that avoids argparse's huge choices blob."""

    def error(self, message):
        print(f"Error: {message}", file=sys.stderr)
        print("Run `ductn help` to see available commands.", file=sys.stderr)
        raise SystemExit(2)


def _load_argcomplete():
    try:
        import argcomplete
        from argcomplete.completers import FilesCompleter
        return argcomplete, FilesCompleter
    except ImportError:
        return None, None


def _print_main_help():
    version = utils.about._version()
    grouped = utils.command._commands_by_group()

    print(f"ductn {version}")
    print("DiepXuan system utility CLI")
    print("")
    print("Usage:")
    print("  ductn <command> [args]")
    print("  ductn help")
    print("  ductn commands [--grouped]")
    print("")
    print("Common commands:")
    for command_name in COMMON_COMMANDS:
        if command_name not in utils.COMMANDS:
            continue
        description = utils.command._command_description(command_name)
        print(f"  {command_name:<22} {description}")
    print("")
    print("Command groups:")
    for group, commands in grouped.items():
        print(f"  {group:<12} {len(commands):>2} command(s)")
    print("")
    print("Run `ductn help` for full command list.")
    print("Run `ductn <command> --help` for command-specific help.")


def _print_unknown_command(command_name):
    print(f"Unknown command: {command_name}", file=sys.stderr)
    print("Run `ductn commands` to list available commands.", file=sys.stderr)
    print("Run `ductn help` for grouped help.", file=sys.stderr)


def _build_parser():
    parser = DuctnParser(
        prog="ductn",
        description="DiepXuan system utility CLI",
        add_help=False,
    )
    parser.add_argument("-h", "--help", action="store_true", help="Show help and exit")
    parser.add_argument("-v", "--version", action="store_true", help="Show version and exit")
    parser.add_argument("command", nargs="?", help="Command to run")
    parser.add_argument("extra_args", nargs=argparse.REMAINDER, help="Command arguments")
    return parser


def main():
    argcomplete, _files_completer = _load_argcomplete()
    parser = _build_parser()

    if argcomplete:
        argcomplete.autocomplete(parser)

    args = parser.parse_args()

    if args.version:
        print(utils.about._version())
        raise SystemExit(0)

    if args.help or not args.command:
        _print_main_help()
        raise SystemExit(0)

    command_name = args.command
    func = utils.COMMANDS.get(command_name)
    if not func:
        _print_unknown_command(command_name)
        raise SystemExit(2)

    extra_args = getattr(args, "extra_args", [])
    utils.command.command_run(func, extra_args)


if __name__ == "__main__":
    main()
