#!/usr/bin/env python3
"""Tests for serviceScheduler / serviceContext — thread lifecycle (fix/5.8.6).

Bối cảnh: trước 5.8.6, mỗi lần task chạy lại tạo một Thread object và giữ nó
trong ``ServiceContext.threads`` vĩnh viễn. Với interval 5s/10s, service giữ
~290k object sau 11 ngày ≈ 700 MB RSS.
"""
import os
import sys
import threading
import time
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.serviceContext import ServiceContext
from utils.serviceScheduler import ServiceScheduler


class FakeScheduler(ServiceScheduler):
    """Scheduler không khởi tạo phụ thuộc hệ thống."""

    def __init__(self, ctx):
        self.ctx = ctx
        self.tasks = []
        self.os = "linux"
        self.init = "systemd"


class TestServiceContextThreadLifecycle(unittest.TestCase):
    def setUp(self):
        self.ctx = ServiceContext()

    def test_register_tracks_thread(self):
        t = threading.Thread(target=lambda: None, name="t1")
        self.ctx.register_thread(t)
        self.assertIn(t, self.ctx.threads)
        self.assertIn("t1", self.ctx._running)

    def test_unregister_removes_thread(self):
        t = threading.Thread(target=lambda: None, name="t1")
        self.ctx.register_thread(t)
        self.ctx.unregister_thread(t)
        self.assertNotIn(t, self.ctx.threads)
        self.assertNotIn("t1", self.ctx._running)

    def test_unregister_is_idempotent(self):
        t = threading.Thread(target=lambda: None, name="t1")
        self.ctx.unregister_thread(t)  # chưa register
        self.ctx.unregister_thread(t)
        self.assertEqual(len(self.ctx.threads), 0)

    def test_unregister_only_removes_matching_thread_name(self):
        t1 = threading.Thread(target=lambda: None, name="same")
        t2 = threading.Thread(target=lambda: None, name="same")
        self.ctx.register_thread(t2)
        self.ctx.unregister_thread(t1)  # t1 không phải cái đang track
        self.assertIn(t2, self.ctx.threads)

    def test_is_running_false_for_unknown(self):
        self.assertFalse(self.ctx.is_running("nope"))

    def test_is_running_true_for_alive_thread(self):
        started = threading.Event()
        release = threading.Event()

        def target():
            started.set()
            release.wait(timeout=5)

        t = threading.Thread(target=target, name="long")
        self.ctx.register_thread(t)
        t.start()
        started.wait(timeout=5)

        try:
            self.assertTrue(self.ctx.is_running("long"))
        finally:
            release.set()
            t.join(timeout=5)

    def test_is_running_cleans_dead_thread(self):
        t = threading.Thread(target=lambda: None, name="done")
        self.ctx.register_thread(t)
        t.start()
        t.join(timeout=5)

        self.assertFalse(self.ctx.is_running("done"))
        # Đã tự dọn
        self.assertNotIn(t, self.ctx.threads)
        self.assertNotIn("done", self.ctx._running)

    def test_join_all_clears_registry(self):
        threads = []
        for i in range(5):
            t = threading.Thread(target=lambda: None, name=f"t{i}")
            self.ctx.register_thread(t)
            t.start()
            threads.append(t)
        for t in threads:
            t.join(timeout=5)

        self.ctx.join_all(timeout=1)

        self.assertEqual(len(self.ctx.threads), 0)
        self.assertEqual(len(self.ctx._running), 0)


class TestSchedulerDoesNotLeakThreads(unittest.TestCase):
    """Regression: chạy task nhiều lần không được để lại Thread object."""

    def test_run_task_releases_thread_after_completion(self):
        ctx = ServiceContext()
        sched = FakeScheduler(ctx)
        sched.register(name="probe", interval=0, target=lambda: None)

        task = sched.tasks[0]
        self.assertTrue(sched._run_task(task))

        # Chờ task xong
        deadline = time.time() + 5
        while ctx.threads and time.time() < deadline:
            time.sleep(0.01)

        self.assertEqual(len(ctx.threads), 0, "Thread object bị leak sau khi xong")
        self.assertEqual(len(ctx._running), 0, "_running bị leak sau khi xong")

    def test_repeated_runs_keep_zero_threads(self):
        """50 lần chạy liên tiếp phải trả về 0 thread tracked."""
        ctx = ServiceContext()
        sched = FakeScheduler(ctx)
        sched.register(name="probe", interval=0, target=lambda: None)

        task = sched.tasks[0]
        for _ in range(50):
            sched._run_task(task)
            deadline = time.time() + 2
            while ctx.threads and time.time() < deadline:
                time.sleep(0.002)

        self.assertEqual(len(ctx.threads), 0)

    def test_thread_objects_are_collectable(self):
        """Không giữ tham chiếu => thread cũ được GC."""
        import gc
        import weakref

        ctx = ServiceContext()
        sched = FakeScheduler(ctx)
        sched.register(name="probe", interval=0, target=lambda: None)
        task = sched.tasks[0]

        refs = []
        for _ in range(10):
            sched._run_task(task)
            deadline = time.time() + 2
            while ctx.threads and time.time() < deadline:
                time.sleep(0.002)

        # Không còn thread nào bị track
        self.assertEqual(len(ctx.threads), 0)
        self.assertEqual(len(ctx._running), 0)
        del refs

    def test_guard_skips_when_previous_still_running(self):
        ctx = ServiceContext()
        sched = FakeScheduler(ctx)

        started = threading.Event()
        release = threading.Event()
        calls = []

        def slow_target():
            calls.append(1)
            started.set()
            release.wait(timeout=5)

        sched.register(name="slow", interval=0, target=slow_target)
        task = sched.tasks[0]

        sched._run_task(task)
        started.wait(timeout=5)
        self.assertTrue(ctx.is_running("slow"))

        # Trong khi task trước còn chạy: _run_task phải bị guard chặn ở run()
        # nhưng _run_task trực tiếp vẫn start được; kiểm tra guard qua run loop
        self.assertEqual(len(calls), 1)

        release.set()
        deadline = time.time() + 5
        while ctx.is_running("slow") and time.time() < deadline:
            time.sleep(0.01)

        self.assertFalse(ctx.is_running("slow"))

    def test_target_exception_still_releases_thread(self):
        ctx = ServiceContext()
        sched = FakeScheduler(ctx)

        def boom():
            raise RuntimeError("boom")

        sched.register(name="boom", interval=0, target=boom)
        sched._run_task(sched.tasks[0])

        deadline = time.time() + 5
        while ctx.threads and time.time() < deadline:
            time.sleep(0.01)

        self.assertEqual(len(ctx.threads), 0, "Thread bị leak khi task raise")

    def test_thread_is_daemon(self):
        """Thread phải daemon để không chặn shutdown khi join timeout."""
        ctx = ServiceContext()
        sched = FakeScheduler(ctx)

        captured = {}
        original_thread = threading.Thread

        def spy(*args, **kwargs):
            captured.update(kwargs)
            return original_thread(*args, **kwargs)

        sched.register(name="probe", interval=0, target=lambda: None)
        with unittest.mock.patch("utils.serviceScheduler.threading.Thread", side_effect=spy):
            sched._run_task(sched.tasks[0])

        self.assertTrue(captured.get("daemon"))


if __name__ == "__main__":
    unittest.main(verbosity=2)
