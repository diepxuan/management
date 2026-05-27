#!/usr/bin/env python3
"""APT package management utilities."""

import re
import subprocess
import sys

from .registry import register_command
from .system import _is_root

_PACKAGE_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9+._:-]*$")


def _run_argv(argv):
    """Run command without shell expansion."""
    try:
        result = subprocess.run(
            argv,
            check=False,
            capture_output=True,
            text=True,
        )
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return 1, "", str(e)


def _with_sudo(argv):
    """Prefix sudo when current process is not root."""
    if _is_root():
        return argv
    return ["sudo"] + argv


def _normalize_args(args):
    if args is None:
        return []
    if isinstance(args, str):
        return args.split()
    return list(args)


def _validate_package_name(package):
    if not package or not _PACKAGE_RE.match(package):
        print(f"Invalid package name: {package}", file=sys.stderr)
        sys.exit(2)


def _validate_packages(packages):
    if not packages:
        print("Error: package name required", file=sys.stderr)
        sys.exit(1)
    for package in packages:
        _validate_package_name(package)


def _is_installed(package):
    code, stdout, _stderr = _run_argv([
        "dpkg-query",
        "-W",
        "-f=${Status}",
        package,
    ])
    return code == 0 and "install ok installed" in stdout


@register_command
def d_apt_fix(args=None):
    """Repair interrupted APT/dpkg state. Usage: ductn apt:fix [--force]

    Non-force recommendation:
      - Do not kill apt/dpkg processes.
      - Do not delete lock files manually.
      - Run dpkg --configure -a and apt-get -f install -y.

    Proposed --force behavior (not implemented yet):
      - Detect lock holders first.
      - Only after explicit --force, stop stale apt/dpkg processes and remove stale locks.
    """
    args = _normalize_args(args)
    if "--help" in args:
        print("Usage: ductn apt:fix [--force]")
        print("Without --force: safe repair only, no kill, no lock deletion.")
        print("With --force: proposed future mode for stale lock/process cleanup.")
        return

    if "--force" in args:
        print(
            "apt:fix --force is not implemented yet. "
            "Review lock holder detection before enabling destructive cleanup.",
            file=sys.stderr,
        )
        sys.exit(2)

    print("Repairing APT/dpkg state safely...")
    for cmd in (["dpkg", "--configure", "-a"], ["apt-get", "-f", "install", "-y"]):
        code, _stdout, stderr = _run_argv(_with_sudo(cmd))
        if code != 0:
            print(f"Error running {' '.join(cmd)}: {stderr}", file=sys.stderr)
            sys.exit(1)
    print("APT/dpkg repair completed.")


@register_command
def d_apt_check(args=None):
    """Check if package is installed. Usage: ductn apt:check <package>"""
    args = _normalize_args(args)
    if "--help" in args:
        print("Usage: ductn apt:check <package>")
        return
    _validate_packages(args[:1])
    print("1" if _is_installed(args[0]) else "0")


@register_command
def d_apt_install(args=None):
    """Install package(s). Usage: ductn apt:install <package1> [package2 ...]"""
    args = _normalize_args(args)
    if "--help" in args:
        print("Usage: ductn apt:install <package1> [package2 ...]")
        return
    _validate_packages(args)

    missing = [package for package in args if not _is_installed(package)]
    if not missing:
        print("All packages are already installed.")
        return

    print(f"Installing: {' '.join(missing)}")
    code, _stdout, stderr = _run_argv(_with_sudo(["apt-get", "install", "-y"] + missing))
    if code != 0:
        print(f"Error installing packages: {stderr}", file=sys.stderr)
        sys.exit(1)
    print(f"Installed: {' '.join(missing)}")


@register_command
def d_apt_remove(args=None):
    """Purge package(s) and autoremove dependencies. Usage: ductn apt:remove <package1> [package2 ...]"""
    args = _normalize_args(args)
    if "--help" in args:
        print("Usage: ductn apt:remove <package1> [package2 ...]")
        return
    _validate_packages(args)

    print(f"Purging: {' '.join(args)}")
    code, _stdout, stderr = _run_argv(_with_sudo(["apt-get", "purge", "-y"] + args))
    if code != 0:
        print(f"Error purging packages: {stderr}", file=sys.stderr)
        sys.exit(1)

    code, _stdout, stderr = _run_argv(_with_sudo(["apt-get", "autoremove", "-y", "--purge"]))
    if code != 0:
        print(f"Error running autoremove: {stderr}", file=sys.stderr)
        sys.exit(1)
    print(f"Removed: {' '.join(args)}")


@register_command
def d_apt_uninstall(args=None):
    """Alias for apt:remove. Usage: ductn apt:uninstall <package1> [package2 ...]"""
    d_apt_remove(args)
