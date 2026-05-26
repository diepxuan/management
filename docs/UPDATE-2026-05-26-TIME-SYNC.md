# UPDATE-2026-05-26 — Add timezone and NTP sync commands

## Tóm tắt

Đã thêm module Python `src/utils/time.py` để quản lý timezone Việt Nam và đồng bộ giờ hệ thống qua NTP.

Command mới:

- `time:timezone`
- `timezone:vietnam`
- `time:vietnam`
- `time:sync`
- `time:init`

## Behavior

- `time:timezone current`: in timezone hiện tại nếu detect được.
- `time:timezone`: kiểm tra timezone hiện tại và set về `Asia/Ho_Chi_Minh` nếu chưa đúng.
- `timezone:vietnam` / `time:vietnam`: alias để set timezone Việt Nam.
- `time:sync [server]`: lấy thời gian UTC từ NTP server rồi set đồng hồ hệ thống.
- `time:init [server]`: set timezone Việt Nam trước, sau đó sync giờ qua NTP.

NTP server mặc định là `vn.pool.ntp.org`.

## Platform support

| Platform | Timezone | Set time |
|----------|----------|----------|
| Linux | `timedatectl`, fallback `/etc/localtime` | `timedatectl set-time`, fallback `date -s` |
| macOS | `systemsetup -settimezone` | `date` |
| Windows | `tzutil` với `SE Asia Standard Time` cho Việt Nam | PowerShell `Set-Date` |

## Packaging impact

`src/debian/postinst` cố gọi:

```bash
ductn time:timezone
```

trong bước `configure` nếu binary `ductn` tồn tại. Lệnh được chạy best-effort và không làm fail package install nếu lỗi.

## Quyền và rủi ro vận hành

- Các thao tác set timezone/set giờ thường cần root/admin hoặc `sudo`.
- `time:sync` cần outbound UDP port 123 tới NTP server.
- Trên Linux dùng `timedatectl`, command sẽ kiểm tra trạng thái NTP trước khi set giờ. Nếu NTP đang bật, command tắt tạm thời để set giờ thủ công rồi bật lại sau đó, tránh để host mất đồng bộ NTP lâu dài.
- Nếu NTP đang tắt từ trước, command không tự bật NTP sau khi set giờ.
- Môi trường container/sandbox có thể không cho phép đổi timezone/giờ dù command tồn tại.

## Test coverage

Đã thêm `tests/test_time_utils.py` để kiểm tra:

- detect timezone Linux qua `timedatectl show`;
- map timezone Việt Nam sang Windows ID `SE Asia Standard Time`;
- parse NTP transmit timestamp;
- restore NTP after Linux manual set-time when NTP was previously enabled;
- keep NTP disabled when it was already disabled before Linux manual set-time.

## Hướng dẫn cho agent/dev sau

- Khi dev test CLI, ưu tiên chạy qua wrapper `./ductn <command>` ở root repo thay vì gọi trực tiếp `PYTHONPATH=src python3 src/ductn.py <command>`. Wrapper này dùng `src/ductn.sh`, tự xử lý `src/venv`/`uv` nếu có và gần với runtime package hơn.
- Không gọi trực tiếp helper private trong `src/utils/time.py` từ module khác nếu chưa cần; dùng command public hoặc helper public `current_timezone`, `set_timezone`, `sync_time`.
- Khi test logic set system time, luôn mock `_run`, `subprocess.run`, socket hoặc platform API; không đổi giờ thật trong test.
- Nếu cần thêm OS mapping khác, bổ sung test trước khi mở rộng behavior.
