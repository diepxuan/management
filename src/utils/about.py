import os
import re
import subprocess
import ductn

from .registry import COMMANDS, register_command

from . import PACKAGE_NAME, SERVICE_NAME
from . import Console
from . import Table


@register_command
def d_help():
    """Show help information"""
    console = Console()
    console.print(f"\n[bold cyan]Cách sử dụng:[/bold cyan] ductn <lệnh> [tham số]")
    table = Table(
        # title="\n[bold yellow]Các lệnh có sẵn[/bold yellow]",
        show_header=False,  # <-- TẮT tiêu đề cột
        box=None,  # <-- TẮT tất cả các đường viền
        padding=(
            0,
            2,
            0,
            0,
        ),  # <-- (top, right, bottom, left) - Chỉ thêm padding bên phải cột lệnh
    )
    for command_name in sorted(COMMANDS.keys()):
        command_func = COMMANDS[command_name]

        doc = command_func.__doc__
        # description = doc.strip().split("\n")[0] if doc else "Không có mô tả."
        description = doc.strip().split("\n")[0] if doc else ""

        table.add_row(f"[green]{command_name}[/green]", description)

    table.add_row()
    table.add_row(f"\n[bold cyan]Optional arguments")
    table.add_row(f"[green]-h, --help[/green]", "Show this help message and exit")
    table.add_row(f"[green]-v, --version[/green]", "Show version and exit")

    # In bảng ra console
    console.print(table)


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
