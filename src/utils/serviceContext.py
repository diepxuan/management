import logging
import threading


class ServiceContext:
    """
    Trạng thái runtime dùng chung cho scheduler và các task.

    Quản lý vòng đời thread:
      - Thread đang chạy được track theo tên task (``_running``) để guard
        chống chạy chồng khi task trước chưa xong.
      - Thread đã kết thúc được gỡ khỏi tập theo dõi ngay khi join, KHÔNG
        giữ tham chiếu vĩnh viễn.

    Trước 5.8.6, ``register_thread()`` chỉ ``add`` vào ``set`` mà không bao
    giờ remove. Với interval 5s/10s, sau 11 ngày service giữ ~290k object
    ``Thread`` (~700 MB RSS). Xem fix/5.8.6-host-domain-vm-sync.
    """

    def __init__(self):
        self.shutdown_event = threading.Event()
        self.threads = set()
        # task name -> Thread đang chạy (dùng cho guard chống chồng).
        self._running = {}
        self._lock = threading.Lock()

    def stop(self):
        logging.info("ServiceContext: shutdown requested")
        self.shutdown_event.set()

    def is_running(self, name: str) -> bool:
        """True nếu task ``name`` vẫn còn thread sống."""
        with self._lock:
            t = self._running.get(name)
            if t is None:
                return False
            if t.is_alive():
                return True
            # Thread đã xong nhưng chưa được dọn — dọn luôn.
            self._running.pop(name, None)
            self.threads.discard(t)
            return False

    def register_thread(self, t: threading.Thread):
        """Track thread theo tên task và trong tập chung (để join lúc shutdown)."""
        with self._lock:
            self.threads.add(t)
            self._running[t.name] = t

    def unregister_thread(self, t: threading.Thread):
        """
        Gỡ thread khỏi mọi tập theo dõi.

        PHẢI gọi khi thread kết thúc, nếu không ``threads`` và ``_running``
        phình vô hạn (nguyên nhân leak RAM của 5.8.5 trở về trước).
        """
        with self._lock:
            self.threads.discard(t)
            if self._running.get(t.name) is t:
                self._running.pop(t.name, None)

    def join_all(self, timeout=10):
        """Join các thread còn sống lúc shutdown, sau đó dọn sạch tập."""
        with self._lock:
            pending = list(self.threads)

        for t in pending:
            if t.is_alive():
                t.join(timeout=timeout)
                if t.is_alive():
                    logging.warning(
                        "Thread %s vẫn sống sau %ss timeout", t.name, timeout
                    )

        with self._lock:
            self.threads.clear()
            self._running.clear()
