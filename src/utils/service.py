import logging
import signal
import subprocess
import sys
import threading
import time

from .vm import d_vm_sync
from . import register_command

# --- Biến toàn cục để xử lý tín hiệu ---
shutdown_flag = False


# --- Hàm xử lý tín hiệu ---
def signal_handler(signum, frame):
    global shutdown_flag
    logging.info(f"[{signal.Signals(signum).name}] Bắt đầu quá trình kết thúc...")
    shutdown_flag = True
    # (Bạn có thể thêm logic giết tiến trình con ở đây nếu cần)


@register_command
def d_service():
    logging.info("Bắt đầu service.")

    # Đăng ký các hàm xử lý tín hiệu
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    processes = {}
    counter = 0

    while not shutdown_flag:
        # Kiểm tra và dọn dẹp các tiến trình đã hoàn thành
        for name, p in list(processes.items()):
            if not p.is_alive():
                # logging.info(f"Tác vụ '{name}' đã hoàn thành.")
                del processes[name]

        # Lên lịch tác vụ mới
        if counter % 10 == 0 and "vm_sync_thread" not in processes:
            # logging.info("Kích hoạt tác vụ 'vm_sync'.")
            thread = threading.Thread(target=d_vm_sync, name="vm_sync_thread")
            thread.daemon = True
            thread.start()
            processes["vm_sync_thread"] = thread

        # if counter % 5 == 0 and "route_check" not in processes:
        #     logging.info("Kích hoạt tác vụ 'route_check'.")
        #     processes["route_check"] = subprocess.Popen(
        #         [
        #             "python",
        #             "-c",
        #             "import time; print('Route Check running...'); time.sleep(3)",
        #         ]
        #     )

        # Ngủ 1 giây (hoặc có thể ngủ lâu hơn nếu không có gì làm)
        time.sleep(1)
        counter = (counter + 1) % 60  # Reset mỗi phút

    logging.info("Đang tắt service...")
    # Chờ các tiến trình con còn lại hoàn thành trước khi thoát hẳn
    for p in processes.values():
        p.wait()

    logging.info("Đã tắt service.")
