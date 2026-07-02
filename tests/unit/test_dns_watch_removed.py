#!/usr/bin/env python3
"""Regression tests for the removed DNS watch feature."""
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


class TestDnsWatchRemoved(unittest.TestCase):
    """Đảm bảo DNS watch không còn trong code thực thi."""

    def test_dns_watch_implementation_removed(self):
        dns_source = (ROOT / "src" / "utils" / "dns.py").read_text()

        self.assertNotIn("d_dns_watch", dns_source)
        self.assertNotIn("10.0.0.103", dns_source)

    def test_dns_watch_scheduler_removed(self):
        service_source = (ROOT / "src" / "utils" / "service.py").read_text()

        self.assertNotIn("dns_watch", service_source)


if __name__ == "__main__":
    unittest.main(verbosity=2)
