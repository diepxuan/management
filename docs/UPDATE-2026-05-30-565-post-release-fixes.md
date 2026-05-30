# Update 2026-05-30: 5.6.5 Post-Release Fixes

**Date:** 2026-05-30
**Version:** 5.6.5+ppa~1
**Type:** Post-release bug fix + verification

---

## Issue 1: sys:sysctl không apply khi cài package

### Problem
- Command `ductn sys:sysctl` được thêm vào `src/utils/system.py` ✅
- File `/etc/sysctl.d/99-ductn.conf` được cài vào hệ thống ✅
- **NHƯNG** `src/debian/postinst` không gọi `ductn sys:sysctl` sau khi cài ❌
- Kết quả: sysctl rules KHÔNG được apply cho đến khi user reboot hoặc chạy tay

### Fix
Thêm vào `src/debian/postinst` section `configure`:
```bash
if command -v ductn >/dev/null 2>&1; then
    ductn time:timezone >/dev/null 2>&1 || true
    ductn sys:sysctl >/dev/null 2>&1 || true    # ← THÊM DÒNG NÀY
fi
```

### Impact
- Package cài xong → rules sysctl áp dụng ngay
- Không cần reboot
- Không cần user chạy tay

---

## Issue 2: Laravel parity verification

### Problem
- Task 3.2 đánh dấu COMPLETED nhưng không có parity check giữa bash và Python

### Verification Result
- Bash `php.lar.sh`: 23 lines, 1 function chính `_laravel` → `php artisan $@`
- Python `laravel.py`: `d_php_lar()` forward `artisan` command + thêm composer, cache commands
- **Kết luận:** Python có đủ parity + mở rộng hơn bash. Migration hợp lệ.

---

## Issue 3: m2 package isolation (đã fix trước đó qua PR #36, #38)

### Problem
- Ban đầu `src/debian/ductn.install` có dòng install `m2` vào ductn package
- m2 là package riêng (`src/m2/usr/bin/m2`)

### Fix
- PR #36: Remove m2 wrapper logic từ ductn
- PR #38: Remove dòng thừa từ `ductn.install`

---

## Files Changed

| File | Change |
|------|--------|
| `src/debian/postinst` | Thêm `ductn sys:sysctl` call |
| `src/debian/changelog` | Thêm 3 bullet: postinst fix, m2 fix, Laravel verify |
| `TASKS.md` | Thêm validation steps cho Task 2.1 |

---

**Definition of Done:**
- [x] postinst fix implemented
- [x] Laravel parity verified
- [x] Changelog updated
- [x] TASKS.md updated
- [x] Validation: `bash -n src/debian/postinst` OK
