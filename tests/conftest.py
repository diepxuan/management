"""Shared test fixtures and configuration."""
import os
import sys
import unittest.mock

SRC_DIR = os.path.join(os.path.dirname(__file__), "..", "src")
sys.path.insert(0, SRC_DIR)

# Mock logging file handler before any import
os.geteuid = lambda: 0


def mock_all_subprocess():
    """Return a patcher that mocks all subprocess calls."""
    return unittest.mock.patch("subprocess.run", return_value=unittest.mock.Mock(returncode=0, stdout="", stderr=""))


def mock_subprocess_check_call():
    """Return a patcher that mocks subprocess.check_call."""
    return unittest.mock.patch("subprocess.check_call", return_value=0)


def mock_urlopen(response_text=""):
    """Return a patcher that mocks urllib.request.urlopen."""
    mock_resp = unittest.mock.Mock()
    mock_resp.read.return_value = response_text.encode()
    mock_resp.__enter__ = unittest.mock.Mock(return_value=mock_resp)
    mock_resp.__exit__ = unittest.mock.Mock(return_value=False)
    return unittest.mock.patch("urllib.request.urlopen", return_value=mock_resp)
