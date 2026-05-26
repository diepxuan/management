# Update 2026-05-26: vm:sync DNS API

## Mục đích

Sửa lỗi `ductn vm:sync` không đồng bộ DNS ổn định sau khi migrate Bash sang Python.

## Root cause

- `src/utils/vm.py` đang override API nội bộ bằng endpoint public cũ.
- Endpoint public cũ trả về trang HTML Cloudflare Access nên `res.json()` lỗi và `vm:sync` dừng sớm.
- Python command chưa giữ tương thích với Bash cũ: `d_vm:sync <fqdn>` có thể truyền hostname/FQDN đích, nhưng `d_vm_sync()` không nhận argument.

## Thay đổi

- Loại bỏ hoàn toàn endpoint public cũ khỏi `vm:sync`.
- `vm:sync` chỉ dùng DNS API nội bộ: `https://dns.diepxuan.corp:53443/api`.
- Bỏ TLS verify cho endpoint nội bộ để tránh lỗi certificate nội bộ hết hạn/tự ký làm sync fail.
- `d_vm_sync(args=None)` và `_vm_sync(args=None)` nhận optional FQDN đầu tiên, tương thích behavior Bash cũ.
- Thêm logging rõ ràng khi fetch/add/delete DNS record lỗi.
- Thêm unit tests cho:
  - command `vm:sync` nhận optional domain arg;
  - chỉ gọi DNS API nội bộ;
  - optional FQDN được dùng làm record name.

## Cách dùng

```bash
ductn vm:sync
# hoặc sync record cụ thể
ductn vm:sync custom.diepxuan.corp
```

## Verification

```bash
python3 -m unittest tests.unit.test_vm -v
python3 -m compileall -q src tests
git diff --check
```
