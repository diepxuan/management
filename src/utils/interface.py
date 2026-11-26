import re
import subprocess
import sys

from . import register_command


@register_command
def d_interface_default():
    """In interface mạng mặc định (mặc định của hệ thống)."""
    print(get_default_interface())


def get_default_interface():
    """Trả về interface mạng mặc định, hoặc None nếu không xác định được."""
    try:
        if sys.platform == "darwin":
            out = subprocess.check_output(
                ["route", "get", "default"], stderr=subprocess.DEVNULL, text=True
            )
            m = re.search(r"interface:\s+(\S+)", out)
        else:  # Linux
            out = subprocess.check_output(
                ["ip", "route", "show", "default"], stderr=subprocess.DEVNULL, text=True
            )
            m = re.search(r"dev\s+(\S+)", out)
    except (FileNotFoundError, subprocess.CalledProcessError):
        return None

    return m.group(1) if m else None


@register_command
def d_interface_service():
    """
    In tên network service đang dùng (macOS).

    macOS tách "network service" (Wi-Fi, Ethernet...) khỏi "interface"
    (en0, en1...). Các lệnh `networksetup` cần tên service, không phải
    interface — nên phải map ngược lại qua `-listallhardwareports`.
    """
    if sys.platform != "darwin":
        print(get_default_interface())
        return

    print(get_active_service())


def get_active_service():
    """Map interface mặc định sang tên network service (chỉ macOS)."""
    if sys.platform != "darwin":
        return get_default_interface()

    iface = get_default_interface()
    if not iface:
        return None

    try:
        services = subprocess.check_output(
            ["networksetup", "-listallhardwareports"],
            stderr=subprocess.DEVNULL,
            text=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        return None

    current_service = None
    for line in services.splitlines():
        if line.startswith("Hardware Port:"):
            current_service = line.split(":", 1)[1].strip()
        elif line.startswith("Device:"):
            if line.split(":", 1)[1].strip() == iface:
                return current_service

    return None
