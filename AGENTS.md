# AGENTS.md - ductnd Workspace Protocol

---

## 1. Boot Sequence

Mỗi session phải:

1. Đọc `SOUL.md` — nguyên tắc nền tảng
2. Đọc `USER.md` — thông tin Sếp
3. Đọc `IDENTITY.md` — vai trò cụ thể
4. Đọc memory hôm nay & hôm qua (`memory/YYYY-MM-DD.md`)
5. Nếu MAIN SESSION: đọc `MEMORY.md` (root workspace)

Không hỏi permission. Tự động làm.

---

## 2. Memory System

### Daily notes
- Path: `memory/YYYY-MM-DD.md`
- Ghi log raw: task đã làm, decisions, issues
- Dùng để resume context khi session restart

### Long-term memory
- File: `MEMORY.md` (root workspace)
- **CHỈ load trong main session**
- Chứa curated memories: decisions, lessons learned
- Định kỳ review daily notes → cập nhật MEMORY.md

### Rule: Text > Brain
- Không lưu "mental notes" — viết vào file ngay
- Mắc sai lầm → document để không lặp lại

---

## 3. Git Discipline

- Không tự ý push / tạo PR / merge
- Mỗi task = 1 branch = 1 PR
- Commit message: `type(scope): description`
- Chờ Sếp review trước khi merge

### Branch strategy
```
main (protected)
  ├── feature/xxx
  ├── bugfix/xxx
  └── hotfix/xxx
```

---

## 4. Documentation

### Bắt buộc

| File | Nội dung |
|------|----------|
| `README.md` | Mục đích, installation, usage, commands |
| `src/*/README.md` | Module-specific docs |
| `CHANGELOG.md` | Version history (nếu có release) |

### Nội dung tối thiểu
- Mục đích, cách sử dụng, cấu trúc file
- Dependencies, troubleshooting
- Quyết định thiết kế, trade-offs

---

## 5. Sub-Agents

- Gọi là **đệ**
- Giao task rõ ràng: mục tiêu, input, output, giới hạn
- Đệ không được push/PR trực tiếp

---

Không bỏ qua boot sequence. Không hành động khi chưa nắm đủ context.
