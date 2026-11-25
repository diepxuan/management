import logging
import os
import re
import stat
import unicodedata

from . import register_command


def remove_vietnamese_diacritics(text):
    # Xử lý đặc biệt cho Đ/đ
    text = text.replace("Đ", "D").replace("đ", "d")
    # Chuẩn hóa Unicode
    nfkd_form = unicodedata.normalize("NFKD", text)
    # Loại bỏ dấu
    no_diacritics = "".join([c for c in nfkd_form if not unicodedata.combining(c)])
    return no_diacritics


def filename_clean(ascii_text):
    # Chuyển không dấu
    ascii_text = remove_vietnamese_diacritics(ascii_text)
    # Thay \ bằng khoảng trắng (tùy chọn)
    ascii_text = ascii_text.replace("\\", " ")
    # Loại bỏ khoảng trắng dư thừa
    ascii_text = re.sub(r"\s+", " ", ascii_text)
    # Loại bỏ khoảng trắng đầu cuối
    ascii_text = ascii_text.strip()
    # Loại bỏ khoảng trắng và _ ngay sau |
    ascii_text = re.sub(r"(\|)[\s_]+", r"\1", ascii_text)
    # Chuyển khoảng trắng thành dấu _
    ascii_text = ascii_text.replace(" ", "_")
    # Rút gọn chuỗi nhiều _ liên tiếp
    ascii_text = re.sub(r"_+", "_", ascii_text).strip("_")
    return ascii_text


@register_command
def d_file_cleanpath(paths):
    """
    Đổi tên file:
    - Chuyển không dấu
    - Thay khoảng trắng bằng dấu gạch dưới
    - Giữ nguyên các thư mục
    """
    from pathlib import Path

    for path in paths:
        p = Path(path)
        new_name = filename_clean(p.name)
        new_path = p.with_name(new_name)

        try:
            p.rename(new_path)
            return str(new_path)
        except FileNotFoundError:
            print(f"File '{p}' không tồn tại!")
        except Exception as e:
            print(f"Lỗi: {e}")
            print(filename_clean(path))


# Ví dụ
# filename = r"TA\ TẬN\ THẾ\ NUÔI\ NỮ\ THẦN｜\ PHẦN\ FULL\ END\ 89\ TIẾNG\ [K5x9R_3wZeQ]2.mp3"
# new_filename = clean_filename(filename)
# print(new_filename)


# --- Salvage từ deprecated/src/var/lib/file.sh (xoá ở 5.8.7) --------------
# Ba command dưới đây chưa từng có bản Python:
#   file:chmod        -> stat -c "%a" <path>
#   file:chmod:files  -> find <dir> -type f -exec chmod <mode> {} \;
#   file:chmod:dirs   -> find <dir> -type d -exec chmod <mode> {} \;


def _stat_mode(path):
    """Trả về quyền dạng bát phân (vd '644'), rỗng nếu không đọc được."""
    try:
        return oct(stat.S_IMODE(os.stat(path).st_mode))[2:]
    except OSError:
        return ""


@register_command
def d_file_chmod(args=None):
    """
    In quyền của file/thư mục (dạng bát phân).
    Usage: ductn file:chmod <path>

    Tương đương bash `stat -c "%a" $1`.
    """
    if not args:
        logging.error("Usage: ductn file:chmod <path>")
        return

    path = args[0] if isinstance(args, list) else args
    mode = _stat_mode(path)
    if mode:
        print(mode)


def _chmod_recursive(mode, directory, kind):
    """
    Đổi quyền đệ quy cho file (kind='f') hoặc thư mục (kind='d').

    Dùng os.walk thay cho `find ... -exec chmod`, tránh spawn process cho
    từng entry và xử lý được tên file có ký tự đặc biệt.
    """
    try:
        parsed = int(str(mode), 8)
    except (TypeError, ValueError):
        logging.error("Mode không hợp lệ: %s (ví dụ: 644, 755)", mode)
        return

    if not os.path.isdir(directory):
        logging.error("Không phải thư mục: %s", directory)
        return

    count = 0
    for root, dirs, files in os.walk(directory):
        targets = dirs if kind == "d" else files
        for name in targets:
            target = os.path.join(root, name)
            try:
                os.chmod(target, parsed)
                count += 1
            except OSError as e:
                logging.warning("Không đổi được quyền %s: %s", target, e)

    # os.walk không trả về chính thư mục gốc trong dirs.
    if kind == "d":
        try:
            os.chmod(directory, parsed)
            count += 1
        except OSError as e:
            logging.warning("Không đổi được quyền %s: %s", directory, e)

    logging.info("Đã chmod %s cho %d %s trong %s", mode, count, "file" if kind == "f" else "thư mục", directory)


@register_command
def d_file_chmod_files(args=None):
    """
    chmod đệ quy cho toàn bộ FILE trong thư mục.
    Usage: ductn file:chmod:files <mode> <dir>
    Ví dụ: ductn file:chmod:files 644 /var/www/html
    """
    if not args or len(args) < 2:
        logging.error("Usage: ductn file:chmod:files <mode> <dir>")
        return

    _chmod_recursive(args[0], args[1], "f")


@register_command
def d_file_chmod_dirs(args=None):
    """
    chmod đệ quy cho toàn bộ THƯ MỤC trong thư mục.
    Usage: ductn file:chmod:dirs <mode> <dir>
    Ví dụ: ductn file:chmod:dirs 755 /var/www/html
    """
    if not args or len(args) < 2:
        logging.error("Usage: ductn file:chmod:dirs <mode> <dir>")
        return

    _chmod_recursive(args[0], args[1], "d")
