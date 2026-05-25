import logging
import threading


class ServiceContext:
    def __init__(self):
        self.shutdown_event = threading.Event()
        self.threads = set()

    def stop(self):
        logging.info("ServiceContext: shutdown requested")
        self.shutdown_event.set()

    def register_thread(self, t: threading.Thread):
        self.threads.add(t)

    def join_all(self, timeout=10):
        alive = []
        for t in self.threads:
            if t.is_alive():
                t.join(timeout=timeout)
                if t.is_alive():
                    alive.append(t)
        self.threads = set(alive)
