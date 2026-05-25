#!/usr/bin/env python3

import logging

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
