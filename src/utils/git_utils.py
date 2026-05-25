#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command


def _run_git(*args, check=True):
    try:
        result = subprocess.run(
            ["git"] + list(args),
            capture_output=True,
            text=True,
            check=check,
        )
        return result
    except subprocess.CalledProcessError as e:
        logging.error(f"Git error: {e.stderr}")
        return None


@register_command
def d_git_configure(args=None):
    """
    Cấu hình git cho dự án (user, email, hooks).
    Usage: ductn git:configure [--global]
    """
    is_global = args and "--global" in args

    flag = "--global" if is_global else "--local"

    # Setup user config
    name = os.getenv("GIT_AUTHOR_NAME", "")
    email = os.getenv("GIT_AUTHOR_EMAIL", "")

    if name:
        _run_git("config", flag, "user.name", name)
    if email:
        _run_git("config", flag, "user.email", email)

    # Setup default branch name
    _run_git("config", flag, "init.defaultBranch", "main")

    # Setup push default
    _run_git("config", flag, "push.default", "simple")

    logging.info("Git đã được cấu hình")


@register_command
def d_git_detrack(args=None):
    """
    Xóa file khỏi git tracking nhưng giữ lại trong filesystem.
    Usage: ductn git:detrack <file>
    """
    if not args:
        logging.error("Usage: ductn git:detrack <file>")
        return

    for filepath in args if isinstance(args, list) else [args]:
        result = _run_git("rm", "--cached", filepath)
        if result:
            logging.info(f"Đã detrack {filepath}")
        else:
            logging.error(f"Không thể detrack {filepath}")


@register_command
def d_git_untrack(args=None):
    """Alias của git:detrack."""
    d_git_detrack(args)


@register_command
def d_git_viewuntrack():
    """Hiển thị các file không được track."""
    result = _run_git("status", "--short")
    if result and result.stdout:
        for line in result.stdout.strip().split("\n"):
            if line.startswith("??"):
                print(line)


@register_command
def d_git_tag_cleanup(args=None):
    """
    Dọn dẹp git tags cũ.
    Usage: ductn git:tag:cleanup [pattern]
    """
    pattern = args[0] if args else "*"

    result = _run_git("tag", "-l", pattern)
    if result and result.stdout:
        tags = result.stdout.strip().split("\n")
        logging.info(f"Các tags phù hợp pattern '{pattern}': {len(tags)}")
        for tag in tags[:10]:  # Show first 10
            print(f"  {tag}")
        if len(tags) > 10:
            print(f"  ... và {len(tags) - 10} tags khác")
    else:
        logging.info("Không có tags nào phù hợp")
