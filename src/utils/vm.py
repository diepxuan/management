#!/usr/bin/env python3

from . import dOs
from . import dIp
from . import dHost
from .registry import register_command
from rich.console import Console
from rich.table import Table


@register_command
def d_vm_info():
    """Display VM Information"""

    print("VM Information:")
    console = Console()
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
    table.add_row("Hostname", dHost._host_fullname())
    table.add_row("IP Address", dIp._ip_local())
    table.add_row("DISTRIB", dOs._os_distro())
    table.add_row("OS", dOs._os_codename())
    table.add_row("RELEASE", dOs._os_release())
    table.add_row("ARCHITECTURE", dOs._os_architecture())

    # In bảng ra console
    console.print(table)
