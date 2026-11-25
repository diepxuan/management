import time
import threading
import logging
import sys
from .serviceContext import ServiceContext
from .system_os import _os_distro, _init_system


def _get_os():
    if sys.platform.startswith("linux"):
        return "linux"
    if sys.platform == "darwin":
        return "macos"
    return "unknown"


class ServiceScheduler:
    def __init__(self, ctx: ServiceContext):
        self.ctx = ctx
        self.tasks = []
        self.os = _os_distro()
        self.init = _init_system()

    def register(
        self,
        name,
        interval,
        target,
        os=None,
        init=None,
        next_run=time.time(),
    ):
        self.tasks.append(
            {
                "name": name,
                "interval": interval,
                "target": target,
                "os": os,  # ["linux", "darwin", "debian", "ubuntu"]
                "init": init,  # ["systemd", "launchd"]
                "next_run": next_run,
            }
        )

    def run(self):
        logging.info("Scheduler started")

        while not self.ctx.shutdown_event.is_set():
            now = time.time()

            for task in self.tasks:
                if not self._should_run(task):
                    continue

                if now >= task["next_run"]:
                    # Guard: task trước chưa xong thì bỏ tick này. Tránh
                    # chồng chất thread khi interval < thời gian chạy
                    # (ví dụ vm_sync retry DNS ~20s nhưng interval 10s).
                    if self.ctx.is_running(task["name"]):
                        logging.debug(
                            "Skip %s: previous run still active", task["name"]
                        )
                        continue

                    if self._run_task(task):
                        task["next_run"] = now + task["interval"]

            # Event-driven wait (KHÔNG busy loop)
            self.ctx.shutdown_event.wait(timeout=1)

        logging.info("Scheduler stopped")

    def _should_run(self, task):
        if task["os"] and self.os not in task["os"]:
            return False
        if task["init"] and self.init not in task["init"]:
            return False
        return True

    def _run_task(self, task):
        """
        Chạy task trong thread riêng, tự dọn dẹp khi xong.

        Trả về True nếu đã start thread, False nếu start thất bại.
        """
        name = task["name"]
        ctx = self.ctx

        def wrapper():
            try:
                task["target"]()
            except Exception as e:
                logging.error("Task %s error: %s", name, e)
            finally:
                # QUAN TRỌNG: gỡ thread khỏi ctx để không leak object.
                # Trước 5.8.6 không có bước này nên mỗi lần chạy giữ lại
                # một Thread object vĩnh viễn (~2.5 KB) => ~700 MB sau
                # 11 ngày với interval 5s/10s.
                ctx.unregister_thread(threading.current_thread())

        t = threading.Thread(target=wrapper, name=name, daemon=True)
        try:
            ctx.register_thread(t)
            t.start()
        except Exception as e:
            ctx.unregister_thread(t)
            logging.error("Task %s start failed: %s", name, e)
            return False
        return True
