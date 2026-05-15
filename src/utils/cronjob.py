#!/usr/bin/env python3

import subprocess
import logging

from .registry import register_command


@register_command
def d_cron_min():
    """Thêm cron job chạy mỗi phút (service validation)."""
    try:
        from . import system_service
        system_service._call_init_action("status")
        logging.info("Cron min: service validation OK")
    except Exception as e:
        logging.warning(f"Cron min: service validation failed: {e}")


@register_command
def d_cron_5min():
    """Thêm cron job chạy mỗi 5 phút."""
    # Placeholder cho cloudflare sync (chưa implement)
    pass


@register_command
def d_cron_hour():
    """Thêm cron job chạy mỗi giờ (service validation + env sync)."""
    try:
        from . import system_service
        system_service._call_init_action("status")
    except Exception:
        pass

    try:
        from . import env_config
        env_config._sys_env_sync()
    except Exception:
        pass


@register_command
def d_cron_month():
    """Thêm cron job chạy mỗi tháng."""
    pass
