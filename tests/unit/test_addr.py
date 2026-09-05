#!/usr/bin/env python3
"""Tests for addr.py IP detection helpers."""
import os
import subprocess
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import addr


SAMPLE_IP_OUTPUT = """\
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
    link/ether 02:42:0a:00:00:7a brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.122/24 brd 10.0.0.255 scope global eth0
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:ac:11:00:00 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
4: br-3c0e11008cab: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:45:24:5e:6b brd ff:ff:ff:ff:ff:ff
    inet 172.18.0.1/16 brd 172.18.255.255 scope global br-3c0e11008cab
5: br-custom: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:45:24:5e:6c brd ff:ff:ff:ff:ff:ff
    inet 172.24.0.1/16 brd 172.24.255.255 scope global br-custom
6: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 02:42:ac:12:00:00 brd ff:ff:ff:ff:ff:ff
7: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
    link/ether 02:42:ac:13:00:00 brd ff:ff:ff:ff:ff:ff
"""


class TestIpLocalsFilter(unittest.TestCase):
    """Pin behavior of `_ip_locals()` — must exclude loopback and Docker bridges."""

    @patch("utils.addr.subprocess.run")
    def test_ip_locals_excludes_loopback_and_docker_bridges(self, mock_run):
        mock_run.return_value = subprocess.CompletedProcess(
            args=["ip", "-4", "addr", "show"],
            returncode=0,
            stdout=SAMPLE_IP_OUTPUT,
            stderr="",
        )

        ips = addr._ip_locals()

        self.assertEqual(ips, ["10.0.0.122"])
        self.assertNotIn("127.0.0.1", ips)
        self.assertNotIn("172.17.0.1", ips)
        self.assertNotIn("172.18.0.1", ips)
        self.assertNotIn("172.24.0.1", ips)

    @patch("utils.addr.subprocess.run")
    def test_ip_locals_excludes_all_rfc1918_172_16_12(self, mock_run):
        """Every /16 inside 172.16.0.0/12 must be filtered."""
        output = SAMPLE_IP_OUTPUT + (
            "8: br-test: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP\n"
            "    link/ether 02:42:ac:1f:00:00 brd ff:ff:ff:ff:ff:ff\n"
            "    inet 172.31.0.1/16 brd 172.31.255.255 scope global br-test\n"
        )
        mock_run.return_value = subprocess.CompletedProcess(
            args=["ip", "-4", "addr", "show"],
            returncode=0,
            stdout=output,
            stderr="",
        )

        ips = addr._ip_locals()

        self.assertEqual(ips, ["10.0.0.122"])
        self.assertNotIn("172.31.0.1", ips)

    @patch("utils.addr.subprocess.run")
    def test_ip_locals_keeps_down_interfaces_excluded(self, mock_run):
        """DOWN interfaces must not contribute their IP (existing behavior)."""
        output = (
            "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN\n"
            "    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00\n"
            "    inet 127.0.0.1/8 scope host lo\n"
            "2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN\n"
            "    link/ether 02:42:0a:00:00:7a brd ff:ff:ff:ff:ff:ff\n"
            "    inet 10.0.0.99/24 brd 10.0.0.255 scope global eth0\n"
        )
        mock_run.return_value = subprocess.CompletedProcess(
            args=["ip", "-4", "addr", "show"],
            returncode=0,
            stdout=output,
            stderr="",
        )

        ips = addr._ip_locals()

        self.assertEqual(ips, [])

    @patch("utils.addr.subprocess.run")
    def test_ip_locals_dedupes_repeated_ip(self, mock_run):
        """If two interfaces share an IP, it appears once (existing behavior)."""
        output = (
            "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN\n"
            "    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00\n"
            "    inet 127.0.0.1/8 scope host lo\n"
            "2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP\n"
            "    link/ether 02:42:0a:00:00:7a brd ff:ff:ff:ff:ff:ff\n"
            "    inet 10.0.0.122/24 brd 10.0.0.255 scope global eth0\n"
            "3: eth0:0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP\n"
            "    link/ether 02:42:0a:00:00:7a brd ff:ff:ff:ff:ff:ff\n"
            "    inet 10.0.0.122/24 brd 10.0.0.255 scope global eth0:0\n"
        )
        mock_run.return_value = subprocess.CompletedProcess(
            args=["ip", "-4", "addr", "show"],
            returncode=0,
            stdout=output,
            stderr="",
        )

        ips = addr._ip_locals()

        self.assertEqual(ips, ["10.0.0.122"])

    @patch("utils.addr.subprocess.run")
    def test_ip_locals_returns_empty_on_subprocess_error(self, mock_run):
        mock_run.side_effect = FileNotFoundError("ip not found")

        ips = addr._ip_locals()

        self.assertEqual(ips, [])


if __name__ == "__main__":
    unittest.main(verbosity=2)
