# UPDATE-2026-05-26 — Remove unused `bash/.bash_aliases`

## Tóm tắt

Đã xóa file legacy `bash/.bash_aliases` khỏi source chính.

## Review evidence

- File chỉ chứa helper SSH agent (`start_agent`, `_do_no_thing`) nhưng không tự gọi helper nào khi được source.
- Không có package install mapping nào trong `src/debian/*.install` đưa file này vào binary package.
- Không có reference active tới `bash/.bash_aliases` ngoài legacy cleanup/config code trong `src/var/lib/user.sh` và `src/var/lib/sys.sh`.
- Logic cấu hình alias hiện hành trong `src/var/lib/user.sh` tự ghi block `DUCTN Aliases` trực tiếp vào `/home/<user>/.bash_aliases`, không đọc từ `bash/.bash_aliases`.

## Ảnh hưởng

- Không còn thư mục top-level `bash/` nếu không có file khác được thêm lại.
- Không ảnh hưởng Python CLI trong `src/ductn.py` hoặc legacy Bash command library trong `src/var/lib/`.
- Không ảnh hưởng Debian package vì file này không được install.

## Hướng dẫn thay thế

- Alias/runtime shell config nên tiếp tục được quản lý qua command/user config hiện hành trong `src/var/lib/user.sh` hoặc module Python tương ứng khi được migrate.
- Nếu cần SSH agent autostart trong tương lai, tạo implementation mới rõ ràng, có entrypoint gọi thực tế và documentation/test đi kèm.
