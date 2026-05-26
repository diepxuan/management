#!/usr/bin/env python3

import sys
from . import system_os
from . import addr
from . import host
from . import Console
from . import Table
from . import system_metrics
from .registry import register_command
import logging
from typing import List, Optional

import requests
import psutil
import urllib3
from urllib3.exceptions import InsecureRequestWarning

TOKEN = "3ccbb8eb47507c42a3dfd2a70fe8e617509f8a9e4af713164e0088c715d24c83"
API_BASES = [
    "https://dns.diepxuan.corp:53443/api",
]


def _vm_info():
    """Display VM Information"""
    console = Console()
    table = Table(
        # title="\n[bold yellow]Các lệnh có sẵn[/bold yellow]",
        show_header=False,  # <-- TẮT tiêu đề cột
        # box=None,  # <-- TẮT tất cả các đường viền
        padding=(
            0,
            2,
            0,
            0,
        ),  # <-- (top, right, bottom, left) - Chỉ thêm padding bên phải cột lệnh
    )
    table.add_row("Hostname", host._host_fullname())
    table.add_row("IP Address", addr._ip_local())
    table.add_row("DISTRIB", system_os._os_distro())
    table.add_row("OS", system_os._os_codename())
    table.add_row("RELEASE", system_os._os_release())
    table.add_row("ARCHITECTURE", system_os._os_architecture())
    table.add_row("")
    mem = system_metrics.memory_usage()
    memKB = mem / 1024
    memMB = mem / 1024
    table.add_row("memory_usage", f"{memKB:.2f} MB")

    # In bảng ra console
    console.print(table)


@register_command
def d_vm_info():
    """Display VM Information"""

    _vm_info()


def _request_verify(api_base: str) -> bool:
    """Use system CA for public API, skip verification for legacy internal DNS API."""
    verify = "diepxuan.corp" not in api_base
    if not verify:
        urllib3.disable_warnings(category=InsecureRequestWarning)
    return verify


def _response_json(response):
    """Parse response JSON and reject captive/Cloudflare Access HTML pages."""
    content_type = response.headers.get("content-type", "")
    if "json" not in content_type.lower() and response.text.lstrip().startswith("<"):
        raise ValueError("DNS API returned non-JSON response")
    return response.json()


def _vm_sync(args: Optional[List[str]] = None):
    """
    Đồng bộ các bản ghi DNS type 'A' cho hostname với các IP cục bộ hiện tại.
    """
    headers = {
        "Cache-Control": "no-cache, no-store, must-revalidate",
        "Pragma": "no-cache",
        "Expires": "0",
    }
    values = list(args or [])
    record_name = values[0] if values else host._host_fullname()
    params = {
        "token": TOKEN,
        "domain": record_name,
        "zone": host._host_domain(),
    }

    new_ips = set(addr._ip_locals())
    if not new_ips:
        logging.warning("VM sync skipped: no local IPs found")
        return

    with requests.Session() as requestsSession:
        requestsSession.headers.update(headers)

        data = None
        api_base_used = None
        for api_base in API_BASES:
            try:
                res = requestsSession.get(
                    f"{api_base}/zones/records/get",
                    params={**params, "listZone": "true"},
                    timeout=10,
                    verify=_request_verify(api_base),
                )
                res.raise_for_status()
                data = _response_json(res)
                api_base_used = api_base
                break
            except Exception as e:
                logging.warning("DNS fetch failed via %s: %s", api_base, e)

        if data is None or api_base_used is None:
            return

        url_add = f"{api_base_used}/zones/records/add"
        url_del = f"{api_base_used}/zones/records/delete"
        old_ips = {
            rec["rData"]["ipAddress"]
            for rec in data.get("response", {}).get("records", [])
            if rec.get("type") == "A" and rec.get("name") == record_name
        }

        for ip in old_ips - new_ips:
            try:
                requestsSession.get(
                    url_del,
                    params={**params, "type": "A", "ipAddress": ip},
                    headers=headers,
                    timeout=5,
                    verify=_request_verify(api_base_used),
                )
            except Exception as e:
                logging.warning("DNS delete failed for %s: %s", ip, e)

        for ip in new_ips - old_ips:
            try:
                requestsSession.post(
                    url_add,
                    params={
                        **params,
                        "type": "A",
                        "ipAddress": ip,
                        "ptr": "true",
                        "createPtrZone": "true",
                    },
                    headers=headers,
                    timeout=5,
                    verify=_request_verify(api_base_used),
                )
            except Exception as e:
                logging.warning("DNS add failed for %s: %s", ip, e)


@register_command
def d_vm_sync(args: Optional[List[str]] = None):
    """
    Đồng bộ các bản ghi DNS type 'A' cho hostname với các IP cục bộ hiện tại.
    """
    _vm_sync(args)
