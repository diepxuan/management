#!/usr/bin/env python3

import subprocess
import logging
import urllib.request
import urllib.parse

from .registry import register_command


@register_command
def d_curl_get(args=None):
    """
    HTTP GET request.
    Usage: ductn curl:get <url>
    """
    if not args:
        logging.error("Usage: ductn curl:get <url>")
        return

    url = args[0] if isinstance(args, list) else args
    try:
        resp = urllib.request.urlopen(url, timeout=30)
        print(resp.read().decode())
    except Exception as e:
        logging.error(f"Lỗi GET {url}: {e}")


@register_command
def d_curl_gg(args=None):
    """
    Google search via curl.
    Usage: ductn curl:gg <query>
    """
    if not args:
        logging.error("Usage: ductn curl:gg <query>")
        return

    query = " ".join(args) if isinstance(args, list) else args
    search_url = f"https://www.google.com/search?q={urllib.parse.quote(query)}"
    try:
        req = urllib.request.Request(
            search_url,
            headers={"User-Agent": "Mozilla/5.0"}
        )
        resp = urllib.request.urlopen(req, timeout=30)
        print(resp.read().decode())
    except Exception as e:
        logging.error(f"Lỗi Google search: {e}")
