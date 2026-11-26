#!/usr/bin/env python3
"""Fleet inventory over SSH (salvaged from src/var/lib/main.sh).

``main.sh`` ran ``_main()``: for every domain in the old Proxmox environment it
resolved the address, SSH'd in to read the FQDN and the installed ``ductn``
version, and printed a status table flagging hosts that were behind. It also
checked WireGuard key/config presence and pushed ``wg set`` peer entries.

Only the *inventory* half is salvaged here. The WireGuard provisioning half is
deliberately dropped: it hardcoded ``10.8.x.x`` addressing, wrote config over
SSH with ``sudo tee``, and depended on ``--host:serial`` (the Proxmox VMID) —
all of which belonged to the environment that ``env.sh`` was deprecated with.

The domain list comes from an explicit argument or ``DUCTN_FLEET_DOMAINS``
(comma-separated) instead of the removed ``sys:env:domains``.
"""

import logging
import os
import subprocess

from .registry import register_command


def _ssh_command(host, command, timeout=10):
    """Run ``command`` on ``host`` over SSH; return stdout or None."""
    try:
        result = subprocess.run(
            ["ssh", "-T", "-o", "BatchMode=yes", "-o", f"ConnectTimeout={timeout}",
             host, command],
            capture_output=True,
            text=True,
            timeout=timeout + 5,
            check=False,
        )
        if result.returncode != 0:
            return None
        return result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
        return None


def _parse_version(text):
    """Turn ``5.8.6+ppa~1`` into a comparable tuple of ints."""
    if not text:
        return None
    base = text.split("+", 1)[0]
    parts = []
    for chunk in base.split("."):
        digits = "".join(ch for ch in chunk if ch.isdigit())
        if not digits:
            return None
        parts.append(int(digits))
    return tuple(parts) if parts else None


def _fleet_domains(args):
    """Resolve the domain list from args or the environment."""
    if args:
        raw = args if isinstance(args, list) else args.split()
        if raw:
            return [d.strip() for d in raw if d.strip()]

    env = os.environ.get("DUCTN_FLEET_DOMAINS", "")
    return [d.strip() for d in env.split(",") if d.strip()]


@register_command
def d_fleet_status(args=None):
    """
    Kiểm tra phiên bản ductn trên từng host trong fleet qua SSH.
    Usage: ductn fleet:status <domain> [domain...]
           DUCTN_FLEET_DOMAINS=a.corp,b.corp ductn fleet:status

    Với mỗi domain: đọc FQDN và phiên bản ductn đã cài, so với bản local.
    In bảng trạng thái, đánh dấu host cũ hơn bằng dấu ✗.

    Port từ `main.sh:_main()` (phần inventory). Phần WireGuard
    provisioning trong bash gốc không port — xem docstring module.
    """
    from .about import _version

    domains = _fleet_domains(args)
    if not domains:
        logging.error(
            "Chưa có domain nào. Dùng: ductn fleet:status <domain> ... "
            "hoặc set DUCTN_FLEET_DOMAINS"
        )
        return

    local_raw = _version()
    local_ver = _parse_version(local_raw)

    print(f"ductn local: {local_raw}")
    print("")
    print(f"{'DOMAIN':<32} {'VERSION':<16} HOSTNAME")
    print("-" * 78)

    stale = []
    for domain in domains:
        version = _ssh_command(domain, "ductn version")
        hostname = _ssh_command(domain, "ductn host:fullname")

        if version is None:
            print(f"{domain:<32} {'(unreachable)':<16} -")
            stale.append((domain, "unreachable"))
            continue

        remote_ver = _parse_version(version)
        behind = (
            local_ver is not None
            and remote_ver is not None
            and remote_ver < local_ver
        )

        marker = " !" if behind else ""
        print(f"{domain:<32} {version:<16} {hostname or '-'}{marker}")
        if behind:
            stale.append((domain, version))

    print("-" * 78)
    if stale:
        logging.warning("%d host cần cập nhật: %s", len(stale),
                        ", ".join(f"{d} ({v})" for d, v in stale))
    else:
        logging.info("Tất cả host đã ở bản mới nhất")
