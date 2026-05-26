import datetime as dt
import unittest
from unittest.mock import patch

from utils import time as time_utils


class TimeUtilsTest(unittest.TestCase):
    def test_current_timezone_accepts_linux_timedatectl_value(self):
        completed = type("Completed", (), {"returncode": 0, "stdout": "Asia/Ho_Chi_Minh\n"})()
        with patch("utils.time.platform.system", return_value="Linux"), \
             patch("utils.time.shutil.which", return_value="/usr/bin/timedatectl"), \
             patch("utils.time.subprocess.run", return_value=completed):
            self.assertEqual(time_utils.current_timezone(), "Asia/Ho_Chi_Minh")

    def test_windows_timezone_maps_vietnam_to_windows_id(self):
        calls = []

        def fake_run(command):
            calls.append(command)
            return type("Completed", (), {"returncode": 0})()

        with patch("utils.time.platform.system", return_value="Windows"), \
             patch("utils.time.shutil.which", return_value="C:/Windows/System32/tzutil.exe"), \
             patch("utils.time._run", side_effect=fake_run):
            code = time_utils.set_timezone(time_utils.VIETNAM_TIMEZONE)

        self.assertEqual(code, 0)
        self.assertEqual(calls, [["tzutil", "/s", "SE Asia Standard Time"]])

    def test_get_ntp_time_parses_transmit_timestamp(self):
        expected = dt.datetime(2026, 5, 26, 1, 0, tzinfo=dt.timezone.utc)
        ntp_seconds = int(expected.timestamp()) + time_utils.NTP_DELTA_SECONDS
        packet = bytearray(48)
        packet[40:44] = ntp_seconds.to_bytes(4, "big")

        class FakeSocket:
            def __enter__(self):
                return self

            def __exit__(self, exc_type, exc, tb):
                return False

            def settimeout(self, timeout):
                self.timeout = timeout

            def sendto(self, packet_data, address):
                self.packet_data = packet_data
                self.address = address

            def recvfrom(self, size):
                return bytes(packet), ("127.0.0.1", 123)

        with patch("utils.time.socket.socket", return_value=FakeSocket()):
            self.assertEqual(time_utils.get_ntp_time("example.test"), expected)


if __name__ == "__main__":
    unittest.main()
