#!/usr/bin/env python3
"""Test file.py: Vietnamese diacritic removal and path cleaning."""
import sys
import os
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.file import filename_clean, remove_vietnamese_diacritics


class TestVietnameseDiacritics(unittest.TestCase):
    """Tests cho hàm remove_vietnamese_diacritics."""

    def test_basic_vietnamese(self):
        """Bỏ dấu tiếng Việt cơ bản."""
        self.assertEqual(remove_vietnamese_diacritics("tiếng việt"), "tieng viet")

    def test_special_d(self):
        """Đ/đ chuyển thành D/d."""
        self.assertEqual(remove_vietnamese_diacritics("Đường"), "Duong")
        self.assertEqual(remove_vietnamese_diacritics("đường"), "duong")

    def test_no_diacritics(self):
        """String không có dấu không thay đổi."""
        self.assertEqual(remove_vietnamese_diacritics("hello"), "hello")

    def test_empty_string(self):
        """Empty string trả về empty."""
        self.assertEqual(remove_vietnamese_diacritics(""), "")


class TestFilenameClean(unittest.TestCase):
    """Tests cho hàm filename_clean."""

    def test_vietnamese_to_ascii(self):
        """Chuyển tiếng Việt sang ASCII."""
        result = filename_clean("tài liệu quan trọng")
        self.assertEqual(result, "tai_lieu_quan_trong")

    def test_spaces_to_underscores(self):
        """Thay khoảng trắng bằng underscore."""
        self.assertEqual(filename_clean("hello world"), "hello_world")

    def test_multiple_spaces(self):
        """Nhiều khoảng trắng → 1 underscore."""
        self.assertEqual(filename_clean("hello   world"), "hello_world")

    def test_backslash_to_space(self):
        """Backslash chuyển thành underscore (qua space)."""
        result = filename_clean("hello\\world")
        self.assertIn("hello", result)
        self.assertIn("world", result)

    def test_strip_underscores(self):
        """Loại bỏ underscore đầu/cuối."""
        self.assertEqual(filename_clean("  hello  "), "hello")

    def test_complex_filename(self):
        """Filename phức tạp với tiếng Việt, space, ký tự đặc biệt."""
        filename = "TÀI LIỆU  quan trọng  ĐÂY"
        result = filename_clean(filename)
        self.assertEqual(result, "TAI_LIEU_quan_trong_DAY")


if __name__ == "__main__":
    unittest.main(verbosity=2)
