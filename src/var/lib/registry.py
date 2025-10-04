# Đây là nơi tập trung, được import bởi tất cả các module khác
import importlib
import os
import sys


COMMANDS = {}


def register_command(func):
    """Decorator để tự động đăng ký một hàm lệnh."""
    if callable(func) and func.__name__.startswith("d_"):
        # 1. Lấy tên hàm gốc (ví dụ: "d_vm_list")
        original_name = func.__name__

        # 2. Bỏ tiền tố "d_" (ví dụ: "vm_list")
        base_name = original_name[2:]

        # 3. Chuyển đổi tất cả dấu '_' thành ':' (ví dụ: "vm:list")
        command_name = base_name.replace("_", ":")

        # 4. Đăng ký lệnh với tên đã được chuyển đổi
        COMMANDS[command_name] = func
    return func


def load_plugins(base_path: str):
    """
    Tự động tìm và import tất cả các file .py trong `base_path` và các thư mục con.
    """
    base_path = os.path.abspath(base_path)
    if not os.path.isdir(base_path):
        print(f"Cảnh báo: Thư mục plugin không tồn tại: {base_path}", file=sys.stderr)
        return

    # os.walk sẽ duyệt qua tất cả các thư mục con một cách đệ quy
    for root, dirs, files in os.walk(base_path):
        for filename in files:
            if filename.endswith(".py") and filename != "__init__.py":
                file_path = os.path.join(root, filename)

                # Tạo một tên module duy nhất dựa trên đường dẫn file
                # Ví dụ: /var/lib/ductn/vm.py -> plugins.vm
                # Ví dụ: /var/lib/ductn/linux/net.py -> plugins.linux.net
                relative_path = os.path.relpath(file_path, base_path)
                module_name = "plugins." + relative_path.replace(os.sep, ".")[:-3]

                if module_name in sys.modules:
                    # Nếu đã tồn tại, bỏ qua và chuyển sang file tiếp theo
                    continue

                try:
                    # Nạp module động
                    spec = importlib.util.spec_from_file_location(
                        module_name, file_path
                    )
                    if spec and spec.loader:
                        module = importlib.util.module_from_spec(spec)
                        # Thêm module vào sys.modules trước khi thực thi để tránh các vấn đề import vòng lặp
                        sys.modules[module_name] = module
                        spec.loader.exec_module(module)
                        # print(f"Đã nạp thành công plugin: {module_name}")
                except Exception as e:
                    print(f"Lỗi khi nạp plugin '{file_path}': {e}", file=sys.stderr)
