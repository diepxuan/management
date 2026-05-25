#!/usr/bin/env python3
"""Test curl_utils.py: curl:get and curl:gg validation."""
import sys
import os
import unittest
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.curl_utils import d_curl_get, d_curl_gg


class TestCurlGet(unittest.TestCase):
    """Tests cho curl:get command."""

    @patch("utils.curl_utils.logging.error")
    def test_no_args_shows_usage(self, mock_log):
        """Không có args → log error usage."""
        d_curl_get()
        mock_log.assert_called_once()
        self.assertIn("Usage", str(mock_log.call_args))

    @patch("utils.curl_utils.urllib.request.urlopen")
    def test_valid_url(self, mock_urlopen):
        """URL hợp lệ → in response."""
        mock_resp = MagicMock()
        mock_resp.read.return_value = b'{"status": "ok"}'
        mock_urlopen.return_value = mock_resp

        d_curl_get(["http://example.com"])
        mock_urlopen.assert_called_once()


class TestCurlGg(unittest.TestCase):
    """Tests cho curl:gg command (Google Drive download)."""

    @patch("utils.curl_utils.logging.error")
    def test_no_args_shows_usage(self, mock_log):
        """Không có args → log error usage."""
        d_curl_gg()
        mock_log.assert_called_once()

    @patch("utils.curl_utils.logging.error")
    def test_missing_filename_shows_usage(self, mock_log):
        """Thiếu FILENAME → log error usage."""
        d_curl_gg(["file_id_only"])
        mock_log.assert_called_once()

    @patch("utils.curl_utils.logging.error")
    def test_args_list(self, mock_log):
        """Args phải là list [FILEID, FILENAME]."""
        # Mock urllib để tránh network call
        with patch("utils.curl_utils.urllib.request.Request"), \
             patch("utils.curl_utils.urllib.request.build_opener") as mock_opener:
            mock_open = MagicMock()
            mock_open.open.return_value = MagicMock()
            mock_open.open.return_value.read.return_value = b""
            mock_opener.return_value = mock_open

            d_curl_gg(["1a2b3c", "output.txt"])
            # Should not show usage error
            usage_calls = [c for c in mock_log.call_args_list if "Usage" in str(c)]
            self.assertEqual(len(usage_calls), 0)


if __name__ == "__main__":
    unittest.main(verbosity=2)
