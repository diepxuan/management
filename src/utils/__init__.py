import argparse
import argcomplete
import sys
import distro  # pyright: ignore[reportMissingImports]
import logging

# --- Thiết lập Logging ---
from ductn import PACKAGE_NAME, SERVICE_NAME

# Ghi log ra stdout/stderr, systemd sẽ tự động bắt và chuyển vào journald
logging.basicConfig(
    level=logging.INFO,
    format=f"%(asctime)s {PACKAGE_NAME} {SERVICE_NAME}: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    stream=sys.stdout,
)

from . import registry
from .registry import COMMANDS
from .registry import register_command
from .system import _is_root

from rich.console import Console  # pyright: ignore[reportMissingImports]
from rich.table import Table  # pyright: ignore[reportMissingImports]

from . import commands
from . import alias
from . import about
from . import vm
from . import addr
from . import host
from . import route
from . import service
from . import system
from . import system_info


parser = argparse.ArgumentParser(
    prog="ductn",
    # description="DiepXuan Corp",
)
subparsers = parser.add_subparsers(dest="command", required=True)

# Tự động sinh subcommand từ COMMANDS
for cmd_name, func in COMMANDS.items():
    sub = subparsers.add_parser(cmd_name, help=func.__doc__ or "No description")
    # if "start" in cmd_name or "stop" in cmd_name:
    #     sub.add_argument("name", help="Tên VM")
    sub.set_defaults(func=func)

# Kích hoạt autocomplete nếu chạy CLI trực tiếp
if sys.argv[0].endswith(("ductn", "ductn.py", "ductn.sh")):
    argcomplete.autocomplete(parser)
