import os
import re
import subprocess

from .registry import COMMANDS, register_command

from . import PACKAGE_NAME
from . import Console
from . import Table
from .command import render_command_tree


def _print_grouped_help_plain():
    print("ductn - DiepXuan system utility CLI")
    print("")
    print("Usage:")
    print("  ductn <command> [args]")
    print("  ductn commands [--grouped]")
    print("")
    print("Commands:")
    print(render_command_tree(include_descriptions=True))
    print("")
    print("Options:")
    print("  -h, --help                  Show help and exit")
    print("  -v, --version               Show version and exit")


@register_command
def d_help():
    """Show grouped help information."""
    _print_grouped_help_plain()


def _version():
    import ductn  # import tại đây để tránh circular import khi utils load

    SRC_DIR = os.path.dirname(os.path.realpath(ductn.__file__))
    changelog_path = os.path.join(SRC_DIR, "debian", "changelog")

    if os.path.exists(changelog_path):
        try:
            with open(changelog_path, "r", encoding="utf-8") as f:
                first_line = f.readline()
                match = re.search(r"\((.*?)\)", first_line)
                if match:
                    version = match.group(1).strip()
                    if version:
                        return version
        except Exception:
            pass

        try:
            from shutil import which

            if which("dpkg-parsechangelog"):
                result = subprocess.run(
                    ["dpkg-parsechangelog", "-S", "Version", "-l", changelog_path],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.DEVNULL,
                    text=True,
                    check=True,
                )
                version = result.stdout.strip()
                if version:
                    return version
        except (ImportError, FileNotFoundError, subprocess.CalledProcessError):
            pass

    try:
        result = subprocess.run(
            ["apt", "show", PACKAGE_NAME],
            capture_output=True,
            text=True,
            check=True,
        )

        if result.returncode == 0:
            match = re.search(r"^Version:\s*([^\s]+)", result.stdout, re.MULTILINE)
            if match:
                version = match.group(1)
                if ":" in version:
                    version = version.split(":", 1)[1]
                return version
    except FileNotFoundError:
        pass
    except Exception:
        pass

    return "0.0.0"


@register_command
def d_version():
    """Show package version"""

    print(_version())


@register_command
def d_version_newrelease():
    """Get next release version"""
    version = _version()
    # Loại bỏ phần sau dấu + nếu có
    version = version.split("+", 1)[0]
    # Loại bỏ dấu chấm để dễ dàng tăng số
    numeric_version = version.replace(".", "")
    if numeric_version.isdigit():
        next_version_num = int(numeric_version) + 1
        # Đảm bảo định dạng x.y.z
        next_version_str = str(next_version_num).zfill(3)
        next_version = (
            f"{next_version_str[0]}.{next_version_str[1]}.{next_version_str[2]}"
        )
        print(next_version)
    else:
        print("0.0.0")
