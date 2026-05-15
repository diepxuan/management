#!/usr/bin/env python3

import hashlib
import logging
import sys

from .registry import register_command


def _logger(message, level="info"):
    if level == "error":
        logging.error(message)
    elif level == "warning":
        logging.warning(message)
    else:
        logging.info(message)


@register_command
def d_echo(args=None):
    """Echo message (debug command)."""
    if args:
        print(" ".join(args) if isinstance(args, list) else args)


def _hash_md5(text):
    return hashlib.md5(text.encode()).hexdigest()


@register_command
def d_hash_md5(args=None):
    """Tính MD5 hash."""
    if not args:
        logging.error("Usage: ductn hash:md5 <text>")
        return

    text = " ".join(args) if isinstance(args, list) else args
    print(_hash_md5(text))
