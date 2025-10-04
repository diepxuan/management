#!/usr/bin/env python3

import var.lib.os as d_os
import var.lib.ip as d_ip
import var.lib.host as d_host
from var.lib.registry import register_command
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
    table.add_row("Hostname", d_host.host_fullname())
    table.add_row("IP Address", d_ip._ip_local())
    table.add_row("DISTRIB", d_os._os_distro())
    table.add_row("OS", d_os._os_codename())
    table.add_row("RELEASE", d_os._os_release())
    table.add_row("ARCHITECTURE", d_os._os_architecture())

    # In bảng ra console
    console.print(table)
