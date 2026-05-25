#!/usr/bin/env python3

import logging
import urllib.request
import urllib.parse
import os
import http.cookiejar
import re

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
        logging.error(f"Loi GET {url}: {e}")


@register_command
def d_curl_gg(args=None):
    """
    Download file from Google Drive.
    Usage: ductn curl:gg <FILEID> <FILENAME>
    """
    if not args or len(args) < 2:
        logging.error("Usage: ductn curl:gg <FILEID> <FILENAME>")
        return

    file_id = args[0]
    filename = args[1]

    try:
        url = f"https://docs.google.com/uc?export=download&id={file_id}"
        req = urllib.request.Request(url)
        req.add_header("User-Agent", "Mozilla/5.0")

        cookie_jar = http.cookiejar.LWPCookieJar("/tmp/ductn_gdrive_cookies.txt")
        opener = urllib.request.build_opener(
            urllib.request.HTTPCookieProcessor(cookie_jar)
        )
        opener.addheaders = [("User-Agent", "Mozilla/5.0")]

        resp = opener.open(url, timeout=30)
        html = resp.read().decode()

        confirm = None
        match = re.search(r'confirm=([0-9A-Za-z_]+)', html)
        if match:
            confirm = match.group(1)

        if confirm:
            dl_url = f"https://docs.google.com/uc?export=download&confirm={confirm}&id={file_id}"
        else:
            dl_url = url

        req = urllib.request.Request(dl_url)
        req.add_header("User-Agent", "Mozilla/5.0")
        resp = opener.open(req, timeout=60)

        with open(filename, "wb") as f:
            while True:
                chunk = resp.read(8192)
                if not chunk:
                    break
                f.write(chunk)

        logging.info(f"Da tai: {filename}")

    except Exception as e:
        logging.error(f"Loi tai Google Drive: {e}")
    finally:
        try:
            os.remove("/tmp/ductn_gdrive_cookies.txt")
        except OSError:
            pass
