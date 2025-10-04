#!/usr/bin/env python3

import requests
import socket
from urllib import request
from .registry import register_command


def _ip_local():
    """
    Lấy địa chỉ IP nội bộ của máy.
    """
    s = None
    try:
        # Tạo một socket UDP. AF_INET là cho IPv4, SOCK_DGRAM là cho UDP.
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

        # Không cần gửi dữ liệu, chỉ cần "kết nối" để hệ điều hành chọn interface.
        # Địa chỉ IP không cần phải tồn tại hoặc đến được.
        s.connect(("8.8.8.8", 80))

        # getsockname() trả về một tuple (ip, port)
        ip_address = s.getsockname()[0]
        return ip_address
    except Exception:
        # Nếu có lỗi (ví dụ: không có kết nối mạng), trả về IP loopback
        return "127.0.0.1"
    finally:
        # Luôn luôn đóng socket sau khi dùng xong
        if s:
            s.close()


@register_command
def d_ip_local():
    """In địa chỉ IP nội bộ (Local IP)"""
    print(_ip_local())


def _ip_wan():
    """
    Lấy địa chỉ IP WAN (Public IP) bằng cách gọi một dịch vụ API bên ngoài.
    Trả về None nếu không lấy được IP.
    """
    api_services = [
        "https://api.ipify.org",
        "https://ipinfo.io/ip",
        "https://checkip.amazonaws.com",
        "https://icanhazip.com",
    ]

    for url in api_services:
        # try:
        #     # Gửi một request GET đến API, đặt timeout để tránh chờ quá lâu
        #     response = requests.get(url, timeout=5)
        #     # Gây ra lỗi nếu request không thành công (vd: lỗi 4xx, 5xx)
        #     response.raise_for_status()

        #     # .text.strip() để lấy nội dung và xóa các khoảng trắng/dòng mới thừa
        #     return response.text.strip()
        # except requests.exceptions.RequestException as e:
        #     # Nếu có lỗi (timeout, không kết nối được...), thử dịch vụ tiếp theo
        #     # print(f"Lỗi khi truy cập {url}: {e}. Đang thử dịch vụ khác...")
        #     continue

        try:
            # ipify trả về text thuần, dễ xử lý nhất
            with request.urlopen(url, timeout=5) as response:
                return response.read().decode("utf-8").strip()
        except Exception as e:
            # print(f"Không thể lấy IP WAN: {e}")
            # return None
            continue

    # Nếu tất cả các dịch vụ đều thất bại
    return "0.0.0.0"


@register_command
def d_ip_wan():
    """In địa chỉ IP WAN (Public IP)"""
    print(_ip_wan())
