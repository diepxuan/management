#!/usr/bin/env python3

import argparse
import inspect
import sys

from utils import *


def main():
    argcomplete = None
    files_completer = None
    try:
        import argcomplete
        from argcomplete.completers import FilesCompleter
        files_completer = FilesCompleter
    except ImportError:
        pass

    parser = argparse.ArgumentParser(
        prog="ductn",
        description="DiepXuan Corp",
    )

    parser.add_argument(
        "-v", "--version", action="store_true", help="Show version and exit"
    )

    subparsers = parser.add_subparsers(dest="command")

    # Tự động sinh subcommand từ COMMANDS
    for cmd_name, func in COMMANDS.items():
        description = func.__doc__.strip().split("\n")[0] if func.__doc__ else ""
        sub = subparsers.add_parser(cmd_name, help=description or "No description")
        sub.set_defaults(func=func)

        # Nếu hàm có tham số -> cho phép nhận args động
        sig = inspect.signature(func)
        if len(sig.parameters) > 0:
            extra_arg = sub.add_argument(
                "extra_args",
                nargs=argparse.REMAINDER,
                help="Extra arguments for this command",
            )
            if argcomplete and files_completer:
                setattr(extra_arg, "completer", files_completer())

    if argcomplete:
        argcomplete.autocomplete(parser)

    # Nếu không có subcommand → hiển thị help
    args = parser.parse_args()

    if args.version:
        print(about._version())
        sys.exit(0)

    if not args.command:
        parser.print_help()
        sys.exit(1)

    func = getattr(args, "func", None)
    if not func:
        parser.print_help()
        return

    extra_args = getattr(args, "extra_args", [])
    command.command_run(func, extra_args)


if __name__ == "__main__":
    main()
