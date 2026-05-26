#!/usr/bin/env python3
"""Tests for vm.py DNS sync behavior."""
import os
import sys
import unittest
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.registry import COMMANDS
from utils.vm import _vm_sync, d_vm_sync


class FakeResponse:
    def __init__(self, payload=None, text="", content_type="application/json"):
        self.payload = payload
        self.text = text
        self.headers = {"content-type": content_type}

    def raise_for_status(self):
        return None

    def json(self):
        if self.payload is None:
            raise ValueError("not json")
        return self.payload


class FakeSession:
    def __init__(self, get_responses):
        self.headers = {}
        self.get_responses = list(get_responses)
        self.get_calls = []
        self.post_calls = []

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, tb):
        return False

    def get(self, url, **kwargs):
        self.get_calls.append((url, kwargs))
        if not self.get_responses:
            return FakeResponse({"status": "ok", "response": {"records": []}})
        response = self.get_responses.pop(0)
        if isinstance(response, Exception):
            raise response
        return response

    def post(self, url, **kwargs):
        self.post_calls.append((url, kwargs))
        return FakeResponse({"status": "ok"})


class TestVmSync(unittest.TestCase):
    def test_vm_sync_command_accepts_optional_domain_arg(self):
        self.assertIn("vm:sync", COMMANDS)
        with patch("utils.vm._vm_sync") as mock_sync:
            d_vm_sync(["custom.diepxuan.corp"])
        mock_sync.assert_called_once_with(["custom.diepxuan.corp"])

    @patch("utils.vm.addr._ip_locals", return_value=["10.0.0.122"])
    @patch("utils.vm.host._host_domain", return_value="diepxuan.corp")
    @patch("utils.vm.host._host_fullname", return_value="openclaw.diepxuan.corp")
    @patch("utils.vm.requests.Session")
    def test_vm_sync_uses_internal_dns_api_only(self, mock_session_factory, _host_fullname, _host_domain, _ip_locals):
        session = FakeSession([FakeResponse({"status": "ok", "response": {"records": []}})])
        mock_session_factory.return_value = session

        _vm_sync()

        self.assertEqual(len(session.get_calls), 1)
        self.assertIn("dns.diepxuan.corp", session.get_calls[0][0])
        self.assertNotIn("io.vn", session.get_calls[0][0])
        self.assertIs(session.get_calls[0][1]["verify"], False)
        self.assertEqual(len(session.post_calls), 1)
        self.assertIn("dns.diepxuan.corp", session.post_calls[0][0])
        self.assertIs(session.post_calls[0][1]["verify"], False)
        self.assertEqual(session.post_calls[0][1]["params"]["domain"], "openclaw.diepxuan.corp")
        self.assertEqual(session.post_calls[0][1]["params"]["ipAddress"], "10.0.0.122")

    @patch("utils.vm.addr._ip_locals", return_value=["10.0.0.122"])
    @patch("utils.vm.host._host_domain", return_value="diepxuan.corp")
    @patch("utils.vm.host._host_fullname", return_value="openclaw.diepxuan.corp")
    @patch("utils.vm.requests.Session")
    def test_vm_sync_uses_explicit_domain_arg_for_record_name(self, mock_session_factory, _host_fullname, _host_domain, _ip_locals):
        session = FakeSession([FakeResponse({"status": "ok", "response": {"records": []}})])
        mock_session_factory.return_value = session

        _vm_sync(["custom.diepxuan.corp"])

        self.assertEqual(session.get_calls[0][1]["params"]["domain"], "custom.diepxuan.corp")
        self.assertEqual(session.post_calls[0][1]["params"]["domain"], "custom.diepxuan.corp")


if __name__ == "__main__":
    unittest.main(verbosity=2)
