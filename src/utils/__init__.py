import sys
import distro  # pyright: ignore[reportMissingImports]
import logging
import os
from logging.handlers import RotatingFileHandler

# Encoding Windows
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding="utf-8")

# --- Thiết lập Logging ---
PACKAGE_NAME = "ductn"
SERVICE_NAME = "ductnd"
LOGDIR = "/var/log/ductnd"

# Nếu chạy bằng Python < 3.11, chèn future import vào compile hook
if sys.version_info < (3, 10):
    import builtins

    builtins.__annotations__ = True

from .system import _is_root

def _setup_logging():
    """Thiết lập logging, fallback stdout nếu không ghi được /var/log/ductnd."""
    if _is_root():
        try:
            os.makedirs(LOGDIR, exist_ok=True)
            handlers = [
                RotatingFileHandler(
                    f"{LOGDIR}/{SERVICE_NAME}.log",
                    maxBytes=20 * 1024 * 1024,
                    backupCount=5,
                ),
                logging.StreamHandler(sys.stdout),
            ]
        except OSError:
            handlers = [logging.StreamHandler(sys.stdout)]

        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s %(levelname)s %(name)s: %(message)s",
            handlers=handlers,
        )
    else:
        # Ghi log ra stdout/stderr, systemd sẽ tự động bắt và chuyển vào journald
        logging.basicConfig(
            level=logging.INFO,
            format=f"%(asctime)s %(levelname)s %(name)s: %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
            stream=sys.stdout,
        )


_setup_logging()

from . import registry
from .registry import COMMANDS
from .registry import register_command
from .system import _is_root

from rich.console import Console  # pyright: ignore[reportMissingImports]
from rich.table import Table  # pyright: ignore[reportMissingImports]

from . import command
from . import about
from . import interface
from . import vm
from . import addr
from . import host
from . import dns
from . import route
from . import service
from . import system
from . import system_os
from . import system_info
from . import system_service
from . import file
from . import system_metrics
from . import time
from . import apt
from . import ssl
from . import ssh
from . import cli
from . import log
from . import cronjob
from . import port
from . import user
from . import disk
from . import git_utils
from . import php_utils
from . import laravel
from . import magento2
from . import gpg
from . import curl_utils
from . import server
from . import helpers
