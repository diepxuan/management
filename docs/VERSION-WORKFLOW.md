# Version Workflow

**Project:** ductn / ductnd
**Purpose:** Quy trình chuẩn để làm việc theo từng version, từng task, từng branch.
**Applies to:** mọi task code, migration, packaging, documentation, release trong repository này.

---

## 1. Nguyên tắc nền tảng

1. Mỗi version có phạm vi rõ ràng.
2. Mỗi task thuộc đúng một version.
3. Mỗi task dùng một branch riêng.
4. Không làm trực tiếp trên `main`.
5. Không tự ý push, tạo PR, merge, tag, release nếu chưa có lệnh của Sếp.
6. Code thay đổi phải đi kèm documentation và validation.
7. Nếu đang làm trên release version hiện tại, cập nhật chung entry version đó trong `src/debian/changelog`; không tự tạo version mới.

---

## 2. Cấu trúc quản lý version

Mỗi version phải có đủ thông tin sau trong `TASKS.md` hoặc tài liệu tương ứng:

```md
## Version X.Y.Z

### Scope
- Mục tiêu chính của version.
- Nhóm module/package bị ảnh hưởng.
- Giới hạn không làm trong version này.

### Rules
- Mỗi task = một branch riêng.
- Mỗi branch = một PR riêng khi được phép.
- Mọi task cập nhật chung changelog entry `X.Y.Z`.
- Không xóa legacy code nếu chưa có bản thay thế đã test đủ.

### Task Board
| ID | Task | Branch | Status | Docs | Validation |
|----|------|--------|--------|------|------------|
| X.Y.Z-001 | Tên task | feat/X.Y.Z-task-name | Pending | Pending | Pending |
```

---

## 3. Vòng đời một task

Flow bắt buộc:

```text
Nhận task
  ↓
Xác định version
  ↓
Kiểm tra TASKS.md / docs liên quan
  ↓
Tạo branch riêng từ main
  ↓
Phân tích source hiện tại
  ↓
Thực hiện thay đổi
  ↓
Cập nhật tài liệu
  ↓
Cập nhật changelog version hiện tại
  ↓
Chạy validation
  ↓
Commit local
  ↓
Báo cáo Sếp
  ↓
Chờ lệnh push / PR / merge
```

---

## 4. Branch strategy

Tên branch chuẩn:

```text
feat/<version>-<short-task>
fix/<version>-<short-task>
docs/<version>-<short-task>
refactor/<version>-<short-task>
test/<version>-<short-task>
chore/<version>-<short-task>
```

Ví dụ:

```text
feat/5.6.1-ssh-management
fix/5.6.1-cli-shpool-install
docs/5.6.1-version-workflow
```

Lệnh tạo branch:

```bash
git checkout main
git pull --ff-only
git checkout -b feat/5.6.1-ssh-management
```

Nếu không được phép pull hoặc remote có rủi ro, chỉ kiểm tra local và hỏi Sếp.

---

## 5. Commit convention

Format:

```text
type(scope): description
```

Types:

| Type | Khi dùng |
|------|----------|
| `feat` | Thêm command/tính năng mới |
| `fix` | Sửa lỗi behavior |
| `docs` | Tài liệu/quy trình |
| `refactor` | Đổi cấu trúc không đổi behavior |
| `test` | Thêm/sửa test |
| `chore` | Tooling, build, packaging |

Ví dụ:

```bash
git commit -m "feat(ssh): migrate ssh management commands to python"
git commit -m "docs(workflow): add version task workflow"
```

---

## 6. Documentation requirements

Mỗi task phải kiểm tra các file sau:

| File | Khi nào cập nhật |
|------|------------------|
| `README.md` | Command mới, behavior mới, usage mới |
| `TASKS.md` | Trạng thái task, scope version, checklist |
| `src/debian/changelog` | Mọi thay đổi thuộc package/version |
| `docs/UPDATE-YYYY-MM-DD-<topic>.md` | Thay đổi quan trọng về behavior/config/package |
| Module README nếu có | Khi module có tài liệu riêng |

Nội dung tối thiểu của tài liệu:

- Mục đích thay đổi
- Cách dùng
- File liên quan
- Dependencies
- Ví dụ command
- Validation đã chạy
- Troubleshooting
- Breaking changes nếu có

---

## 7. Changelog rules

Với version đang mở, cập nhật đúng entry version đó trong `src/debian/changelog`.

Quy tắc:

1. Không tự tạo version mới nếu Sếp chưa yêu cầu.
2. Không sửa entry cũ nếu không cần fix format.
3. Mỗi task thêm bullet ngắn, rõ.
4. Nếu task chỉ là docs nhưng ảnh hưởng workflow package, vẫn ghi changelog.

Ví dụ:

```text
diepxuan (5.6.1+ppa~1) noble; urgency=medium

  * Add version-based task workflow documentation.
  * Document task checklist and validation requirements for 5.6.1 work.

 -- Tran Ngoc Duc <ductn@diepxuan.com>  Wed, 27 May 2026 10:00:00 +0700
```

---

## 8. Validation checklist

Tùy loại thay đổi, chọn validation phù hợp.

Python module:

```bash
python3 -m py_compile src/utils/<module>.py
python3 -m compileall src
```

Shell/Debian maintainer scripts:

```bash
bash -n src/debian/postinst
bash -n src/debian/prerm
bash -n src/debian/postrm
```

CLI smoke test:

```bash
cd src
./ductn commands
./ductn <command>
```

Git hygiene:

```bash
git diff --check
git status --short
```

Unit tests nếu có:

```bash
python3 -m unittest discover -s tests -v
```

Build package nếu task ảnh hưởng packaging/release:

```bash
cd src
./build.sh
```

---

## 9. Definition of Done cho mỗi task

Một task chỉ được xem là xong local khi đủ:

```text
[ ] Đúng version
[ ] Đúng branch riêng
[ ] Không làm trực tiếp trên main
[ ] Code/config/docs đã hoàn thành
[ ] README/TASKS/changelog cập nhật nếu cần
[ ] docs/UPDATE-* tạo nếu thay đổi quan trọng
[ ] Validation đã chạy và ghi lại kết quả
[ ] Không có secrets/.env trong commit
[ ] Không có debug/temp files
[ ] Commit local theo chuẩn
[ ] Báo cáo Sếp rõ ràng
[ ] Chưa push/PR/merge nếu chưa được phép
```

---

## 10. Quy trình migrate Bash sang Python

Áp dụng cho các task migrate từ `src/var/lib/*.sh` sang `src/utils/*.py`.

1. Đọc Bash script gốc.
2. Liệt kê public commands cần giữ.
3. Kiểm tra command registry hiện tại.
4. Tạo/cập nhật Python module trong `src/utils/`.
5. Đăng ký command bằng `@register_command`.
6. Import module trong `src/utils/__init__.py`.
7. Test command hoặc py_compile nếu môi trường không đủ quyền chạy thật.
8. Cập nhật `README.md`, `TASKS.md`, `src/debian/changelog`.
9. Tạo `docs/UPDATE-YYYY-MM-DD-<topic>.md` nếu behavior/package thay đổi.
10. Chỉ chuyển Bash script sang `deprecated/` khi Python đã ổn và được xác nhận.

Không được:

- Xóa Bash script khi Python chưa có parity.
- Đổi tên command nếu không có lý do rõ.
- Đổi production config không được yêu cầu.
- Sửa `src/debian/control`, `.github/workflows/*`, `src/etc/ductn.conf` nếu không có yêu cầu rõ.

---

## 11. Mẫu task chuẩn trong TASKS.md

Dùng mẫu này cho task mới:

```md
### ⏳ Task <id>: <Task Name>
- **Version:** X.Y.Z
- **Status:** ⏳ PENDING
- **Branch:** `feat/X.Y.Z-task-name`
- **Scope:** <mô tả ngắn>
- **Source:** `<file gốc nếu có>`
- **Target:** `<file đích nếu có>`
- **Commands:**
  | Command | Description | Status |
  |---------|-------------|--------|
  | `<command>` | <mô tả> | Pending |
- **Documentation:**
  - [ ] `README.md`
  - [ ] `TASKS.md`
  - [ ] `src/debian/changelog`
  - [ ] `docs/UPDATE-YYYY-MM-DD-<topic>.md` nếu cần
- **Validation:**
  - [ ] `python3 -m py_compile <file>`
  - [ ] `python3 -m compileall src`
  - [ ] `git diff --check`
  - [ ] CLI smoke test nếu chạy được
- **Definition of Done:**
  - [ ] Code hoàn thành
  - [ ] Docs hoàn thành
  - [ ] Changelog cập nhật đúng version
  - [ ] Validation OK
  - [ ] Commit local
  - [ ] Báo cáo Sếp
```

---

## 12. Báo cáo hoàn thành task

Mẫu báo cáo:

```text
Sếp, task đã xong local.

Version: X.Y.Z
Branch: <branch>
Commit: <short-sha>

Đã làm:
- ...

Docs đã cập nhật:
- ...

Validation:
- ... OK

Chưa làm:
- Chưa push
- Chưa tạo PR
- Chưa merge

Cần Sếp duyệt bước tiếp theo.
```

---

## 13. Release checklist

Chỉ thực hiện khi Sếp yêu cầu.

```text
[ ] Tất cả task version đã Completed hoặc Deferred có lý do
[ ] `TASKS.md` sạch trạng thái
[ ] `README.md` cập nhật
[ ] `docs/UPDATE-*` đầy đủ
[ ] `src/debian/changelog` đúng version
[ ] Validation tổng OK
[ ] Build package OK nếu cần
[ ] Không secrets/debug/temp files
[ ] Sếp duyệt release branch/tag/publish
```

Release branch:

```text
release/X.Y.Z
```

Tag:

```text
vX.Y.Z
```

Không tự tạo release branch/tag nếu chưa có lệnh.
