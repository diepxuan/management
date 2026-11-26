# TASKS.md - Bash to Python Migration

**Project:** ductn (DiepXuan Personal Package)
**Created:** 2026-04-18
**Updated:** 2026-07-20 (rev)
**Goal:** Migrate all bash scripts from `src/var/lib/` to Python modules in `src/utils/`

---

## Migration Status

| Status | Count | Description |
|--------|-------|-------------|
| ✅ Completed | 37 | Migrated to Python + bash removed |
| 🔄 In Progress | 0 | Currently being migrated |
| ⏳ Pending | 0 | Nothing left to migrate |
| 🔀 Partial | 0 | — |
| 🚫 Deprecated | 6 | Command group intentionally dropped |

**Cập nhật 2026-11-25 (5.8.7):** `src/var/lib/` đã rỗng hoàn toàn. 17 file bash
còn lại được xử lý: 13 file là code chết (đã có Python thay thế) → xoá; 4 file còn
tính năng chưa port → salvage sang Python rồi xoá. Xem
`docs/MIGRATION-STATUS-2026-11-25.md` và `docs/SALVAGE-5.8.7.md`.

---


## Version 5.6.4 Working Baseline

**Version:** `5.6.4+ppa~1`
**Branch:** `5.6.4`
**Scope:** Deprecate legacy user/system setup commands; keep update path only.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** tasks in this version update the shared `5.6.4+ppa~1` entry in `src/debian/changelog`.

### ✅ Task 5.6.4-001: Deprecate user commands and trim legacy sys.sh
- **Branch:** `5.6.4`
- **Base:** `main`
- **Scope:** Remove active `user:*` commands from Python registry and keep legacy `sys.sh` update-only.
- **Status:** ✅ COMPLETED
- **Deprecated commands:**
  - `user:new`
  - `user:config`
  - `user:config:bash`
  - `user:config:chmod`
  - `user:config:admin`
  - `user:is_sudoer`
  - `sys:init`
  - `sys:sysctl`
  - `sys:clean`
  - `isenabled`
- **Kept commands:**
  - `update`
  - `__selfupdate`
  - `__self-update`
  - `sys:upgrade`
- **Files:**
  - `src/utils/user.py` -> `deprecated/src/utils/user.py`
  - `src/utils/__init__.py`
  - `src/var/lib/sys.sh`
  - `tests/unit/test_registry.py`
  - `docs/UPDATE-2026-05-29-user-sys-deprecation.md`
- **Validation:**
  - [x] `bash -n src/var/lib/sys.sh`
  - [x] `python3 -m unittest tests.unit.test_registry -v`
  - [x] active command surface has no `user:*`
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version`
  - [x] `git diff --check`

---

## Version 5.6.7 Working Baseline

**Version:** `5.6.7+ppa~1`
**Branch:** `fix/5.6.7-ductncli-tty-restore`
**Scope:** Fix-only — restore /dev/tty before execv so ductncli works with hermes/codex interactive mode.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** tasks in this version update the shared `5.6.7+ppa~1` entry in `src/debian/changelog`.

### ✅ Task 5.6.7-001: Fix ductncli TTY restoration before execv
- **Branch:** `fix/5.6.7-ductncli-tty-restore`
- **Base:** `main`
- **Scope:** Restore /dev/tty (fd 0/1/2) after _confirm_start() input() so hermes/codex receive a clean TTY for interactive mode.
- **Status:** ✅ COMPLETED
- **Files:**
  - `src/utils/cli.py` — dup2 /dev/tty to stdin/stdout/stderr before execv
  - `src/debian/changelog` — bump to 5.6.7+ppa~1
- **PR:** #43
- **Validation:**
  - [x] `python3 -m py_compile src/utils/cli.py`
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version` → 5.6.7+ppa~1
  - [x] `git diff --check`

### ✅ Task 5.6.7-002: Fix ductncli OSC 11 background color query leak
- **Branch:** `fix/5.6.7-ductncli-osc11-env`
- **Base:** `main`
- **Scope:** Set `HERMES_TUI_THEME=dark` env var before execv to skip Hermes OSC 11 BG color query, prevent terminal response `]11;rgb:...` from leaking into agent stdin and corrupting the first prompt.
- **Status:** ✅ COMPLETED
- **Commit:** `f6efbb6 fix(cli): set HERMES_TUI_THEME=dark to skip OSC 11 BG color query`
- **Validation:**
  - [x] `python3 -m py_compile src/utils/cli.py`
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version` → 5.6.7+ppa~1
  - [x] `git diff --check`

---

## Version 5.7.1 Working Baseline

**Version:** `5.7.1+ppa~1`
**Branch:** `refactor/5.7.1-split-subpackages`
**Scope:** Tách các CLI wrapper khỏi source package `diepxuan` để quản lý version độc lập.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`

### ✅ Task 5.7.1-001: Split wrapper packages

| Package | CLI | Version | Status |
|---|---|---:|---|
| `ductn-ll` | `ll` | `1:1.0.0+ppa~1` | Completed |
| `ductn-m2` | `m2` | `1.0.0+ppa~1` | Completed |
| `ductn-lar` | `lar` | `1.0.0+ppa~1` | Completed |

- **Status:** ✅ COMPLETED
- **Validation:** Debian metadata, shell syntax, wrapper behavior và orchestration trong `src/build.sh`.
- **Publish rule:** PR chỉ build validation; push `main`, release và dispatch được phép `dput`.
- **Failure rule:** lỗi `dput` tạo warning nhưng không fail CI; lỗi build/artifact vẫn fail.
- **Upgrade rule:** epoch cho `ductn-ll`; transitional `m2`/`lar` kéo package mới.
- **Release:** `5.7.1` — 2026-07-05.

---

## Version 5.7.2 Working Baseline

**Version:** `5.7.2+ppa~1`
**Branch:** `feature/5.7.2-cli-extend`
**Scope:** Mở rộng `ductncli` để hỗ trợ thêm các AI agent CLI thông dụng, cho phép ghi đè registry mặc định qua YAML file và biến môi trường; chỉ hiển thị agent đã cài.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`

### ✅ Task 5.7.2-001: Extend ductncli agent registry

| Layer | Source | Mục đích |
|---|---|---|
| 1 | `AGENTS_DEFAULT` (in-code) | Danh sách biết trước: `hermes, codex, openclaw, freebuff, claude, gemini, aider, llm, aichat, cursor, windsurf, continue, goose, qwen, chatgpt, sgpt, mod`. |
| 2 | `~/.config/ductn/config.yml` | Override per user: thêm/sửa `args`, `description`, `enabled`. |
| 3 | `DuctnCLI_AGENT_ARGS_<NAME>` env | Override `args` cuối cùng (cao nhất). |

- **Status:** ✅ COMPLETED (chờ review PR, bổ sung commit follow-up cùng branch).
- **Validation:** `python3 -m unittest tests.unit.test_cli -v` (27/27 pass), `bash -n src/build.sh`, `bash -n packages/ductn-{ll,m2,lar}/usr/bin/{ll,m2,lar}`.
- **Scope rule:** wrapper packages `ductn-ll`, `ductn-m2`, `ductn-lar` không đổi version (giữ `1:1.0.0+ppa~1`).
- **Dependency rule:** không thêm dependency Python mới; YAML loader viết tay (~180 dòng, hỗ trợ cả flow style `[a, b]`).
- **Default-config rule:** first-run nếu `config.yml` chưa tồn tại sẽ tự seed 4 entry `codex`, `openclaw`, `hermes`, `freebuff`. Nếu user tạo trước một file rỗng/file khác, `ductncli` sẽ không đụng.
- **Filter rule:** agent có trong config nhưng binary không tồn tại trên host **luôn** bị ẩn khỏi menu/autocomplete — verify bằng test `test_hermes_in_config_but_not_installed_is_hidden`.
- **Docs:** `docs/UPDATE-2026-07-20-ductncli-extend.md`.
- **Release:** `5.7.2` — 2026-07-20.

---

## Version 5.7.0 Working Baseline

**Version:** `5.7.0+ppa~1`
**Branch:** `chore/5.7.0-release`
**Scope:** Release DNS watch removal, Python 3.9/service status fixes và OpenClaw CLI support.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** release được ghi trong `CHANGELOG.md` và `src/debian/changelog`.

### ✅ Release 5.7.0

- **Included PRs:** #48, #49, #50
- **Status:** ✅ READY FOR REVIEW
- **Validation:**
  - [x] `ductn --version` → `5.7.0+ppa~1`
  - [x] `ductn version:newrelease` → `5.7.1`
  - [x] CLI/service regression tests → 9/9 passed
  - [x] `git diff --check`

---

## Version 5.6.9 Working Baseline

**Version:** `5.6.9+ppa~1`
**Branch:** `task/5.6.9-001-package-sshd-config`
**Scope:** Package Sếp-managed sshd keepalive config into `ductn`.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** tasks in this version update the shared `5.6.9+ppa~1` entry in `src/debian/changelog`.

### ✅ Task 5.6.9-001: Package sshd keepalive config
- **Branch:** `task/5.6.9-001-package-sshd-config`
- **Base:** `main`
- **Scope:** Add `/etc/ssh/sshd_config.d/ductn.conf` to the `ductn` package from Sếp-managed local config.
- **Status:** ✅ COMPLETED
- **Installed path:** `/etc/ssh/sshd_config.d/ductn.conf`
- **Source path:** `src/ductn/etc/ssh/sshd_config.d/ductn.conf`
- **Config:**
  - `ClientAliveInterval 60`
  - `ClientAliveCountMax 10`
  - `TCPKeepAlive yes`
- **Files:**
  - `src/ductn/etc/ssh/sshd_config.d/ductn.conf`
  - `src/debian/ductn.install`
  - `src/debian/changelog`
  - `README.md`
- **Validation:**
  - [x] `sshd -t -f /tmp/ductn-sshd-test/sshd_config`
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version` → 5.6.9+ppa~1
  - [x] `git diff --check`

---

## Version 5.6.8 Working Baseline

**Version:** `5.6.8+ppa~1`
**Scope:** Tiep tuc migration Bash sang Python — focus vao cac task Pending va Partial.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** tasks in this version update the shared `5.6.8+ppa~1` entry in `src/debian/changelog`.

### Migration Backlog (5.6.8) — ĐÃ ĐÓNG

Bảng backlog dưới đây được lập ngày 2026-07-20 và **không còn đúng**. Giữ lại
lịch sử trong git; trạng thái thực tế xem mục "Migration Status" ở đầu file hoặc
`docs/MIGRATION-STATUS-2026-11-25.md`.

Các task từng ghi PENDING nhưng thực tế đã xong từ lâu: 1.7 cronjob, 2.9 disk,
2.13 port, 3.1 git, 3.4 php, 5.1 gpg, 5.2 curl, 5.7 server, 5.8 env_detect,
5.9 helpers, 5.10 main. Task 2.8 user và 4.1 env là **bỏ có chủ đích**, không
phải pending.

---

## Version 5.6.6 Working Baseline

**Version:** `5.6.6+ppa~1`
**Branch:** `5.6.6`
**Scope:** Remove tmux + shpool; gọi hermes/codex trực tiếp qua terminal tại workspace directory.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** tasks in this version update the shared `5.6.6+ppa~1` entry in `src/debian/changelog`.

### ✅ Task 5.6.6-001: Remove tmux + shpool integration
- **Branch:** `chore/5.6.6-remove-tmux`
- **Base:** `main`
- **Scope:** Xóa toàn bộ tmux + shpool config, postinst logic, dependencies, docs. ductncli gọi hermes/codex trực tiếp qua `os.execv` tại workspace directory — không cần session manager.
- **Status:** ✅ COMPLETED
- **Files removed:**
  - `src/ductn/etc/ductn/tmux.conf`
  - `docs/UPDATE-2026-05-26-ductn-cli-tmux.md`
- **Files modified:**
  - `src/debian/ductn.install` — remove `tmux.conf` install line
  - `src/debian/postinst` — remove tmux config copy block
  - `src/debian/control` — remove `tmux` dependency
  - `README.md` — update CLI section, replace tmux/shpool references with direct terminal
  - `docs/DUCTN-COMPLETION-VALIDATION.md` — replace "tmux pane" with "terminal pane"
  - `docs/VERSION-WORKFLOW.md` — update branch example
  - `src/debian/changelog` — add 5.6.6 entry
- **Validation:**
  - [x] `bash -n src/debian/postinst`
  - [x] `! grep -rn "tmux\|shpool" src/ --include="*.py" --include="*.sh" --include="*.install" --include="*.control" --include="*.conf" | grep -v deprecated`
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version`
  - [x] `git diff --check`

---

---

## Version 5.6.5 Working Baseline

**Version:** `5.6.5+ppa~1`
**Branch:** `5.6.5`
**Scope:** Deprecate sys service validation (apache2, mysql, mssql-server không còn sử dụng); clean up legacy bash scripts.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** tasks in this version update the shared `5.6.5+ppa~1` entry in `src/debian/changelog`.

### ✅ Task 5.6.5-001: Deprecate sys service validation bash script
- **Branch:** `chore/5.6.5-deprecate-sys-service-valid`
- **Base:** `main`
- **Scope:** Move `src/var/lib/sys.service.valid.sh` to `deprecated/`. Không migrate sang Python vì apache2, mysql, mssql-server không còn sử dụng. Dependencies (`swap:install`, `log:cleanup`) đã deprecated hoặc thuộc task khác.
- **Status:** ✅ COMPLETED
- **Files:**
  - `src/var/lib/sys.service.valid.sh` → `deprecated/src/var/lib/sys.service.valid.sh`
  - `TASKS.md` — Task 5.6 marked as DEPRECATED
  - `src/debian/changelog` — entry `5.6.5+ppa~1`
- **Validation:**
  - [x] `bash -n deprecated/src/var/lib/sys.service.valid.sh`
  - [x] `git diff --check`

---

## Version 5.6.3 Working Baseline

**Version:** `5.6.3+ppa~1`
**Branch:** `5.6.3`
**Base rule:** task branches target `5.6.3`; final version PR targets `main` only after task PRs are merged.
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** each task branch updates the shared `5.6.3+ppa~1` entry in `src/debian/changelog`.

### ✅ Task 5.6.3-001: Cache command list for bash completion
- **Branch:** `task/5.6.3-001-command-cache`
- **Base:** `5.6.3`
- **Scope:** Generate `/usr/share/ductn/commands` during package build and make installed-command completion read cache before runtime fallback. Development/path wrappers skip the installed cache so they reflect the current checkout.
- **Status:** ✅ COMPLETED
- **PR:** task branch targets `5.6.3`
- **Files:**
  - `src/debian/rules`
  - `src/ductn/usr/share/bash-completion/completions/ductn`
  - `docs/UPDATE-2026-05-28-ductn-completion-command-cache.md`
- **Validation:**
  - [x] `bash -n src/ductn/usr/share/bash-completion/completions/ductn`
  - [x] completion smoke test using temporary cache file
  - [x] fallback smoke test without cache
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version`
  - [x] `make -n -f debian/rules override_dh_install`
  - [x] `git diff --check`

### ✅ Task 5.6.3-002: Add completion cache maintenance command
- **Branch:** `task/5.6.3-002-cache-maintenance`
- **Base:** `5.6.3`
- **Scope:** Add a CLI command to inspect/refresh the command cache for debugging installed systems.
- **Status:** ✅ COMPLETED
- **Command:** `completion:cache <show|refresh|path> [path]`
- **Files:**
  - `src/utils/completion.py`
  - `src/utils/__init__.py`
  - `tests/unit/test_completion.py`
  - `tests/unit/test_modules.py`
- **Validation:**
  - [x] `python3 -m unittest tests.unit.test_completion tests.unit.test_modules tests.unit.test_registry -v`
  - [x] `python3 -m compileall src/utils src/ductn.py`
  - [x] `./ductn completion:cache show`
  - [x] `./ductn completion:cache refresh /tmp/ductn-commands-test`
  - [x] `git diff --check`

### ✅ Task 5.6.3-003: Document and validate tmux completion workflow
- **Branch:** `task/5.6.3-003-completion-docs-validation`
- **Base:** `5.6.3`
- **Scope:** Add docs/tests/manual validation checklist for tmux autocomplete, cache path, and fallback behavior.
- **Status:** ✅ COMPLETED
- **Files:**
  - `docs/DUCTN-COMPLETION-VALIDATION.md`
  - `scripts/validate-ductn-completion.sh`
- **Validation:**
  - [x] `bash -n scripts/validate-ductn-completion.sh`
  - [x] `bash scripts/validate-ductn-completion.sh`
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version`
  - [x] `git diff --check`

### ✅ Task 5.6.3-004: Add bash completion for ductncli
- **Branch:** `task/5.6.3-004-ductncli-completion`
- **Base:** `5.6.3`
- **Scope:** Add bash completion for `ductncli` to autocomplete agent names (`hermes`, `codex`) and workspace paths (directories + project names).
- **Status:** ✅ COMPLETED
- **Files:**
  - `src/ductn/usr/share/bash-completion/completions/ductncli`
  - `src/debian/ductn.install`
  - `src/debian/changelog`
- **Validation:**
  - [x] `bash -n src/ductn/usr/share/bash-completion/completions/ductncli`
  - [x] `git diff --check`

---

## Version 5.6.2 Working Baseline

**Version:** `5.6.2+ppa~1`
**Branch:** `5.6.2`
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** tasks in this version update the `5.6.2+ppa~1` entry in `src/debian/changelog`.

### ✅ Task 5.6.2-001: Package and harden ductn bash completion
- **Version:** `5.6.2+ppa~1`
- **Status:** ✅ COMPLETED
- **Branch:** `5.6.2`
- **Scope:** Move ductn completion script to the standard bash-completion lazy-load path and harden the function for tmux/dev-wrapper usage.
- **Source:** `src/ductn/etc/bash_completion.d/ductn-prompt`
- **Target:** `src/ductn/usr/share/bash-completion/completions/ductn`
- **Changes:**
  - [x] Install completion under `/usr/share/bash-completion/completions/ductn`
  - [x] Guard missing `_get_comp_words_by_ref` helper
  - [x] Guard missing `__ltrim_colon_completions` helper
  - [x] Register dev wrappers: `./ductn`, `./ductn.sh`, `./ductn.py`
  - [x] Redirect stderr when calling `${COMP_WORDS[0]} commands`
  - [x] Quote completion variables and fallback cleanly if command listing fails
  - [x] Remove obsolete `/etc/bash_completion.d/ductn-prompt` conffile on upgrade via `src/debian/ductn.maintscript`
- **Documentation:**
  - [x] `TASKS.md`
  - [x] `src/debian/changelog`
  - [x] `docs/UPDATE-2026-05-28-ductn-bash-completion-path.md`
- **Validation:**
  - [x] `bash -n src/ductn/usr/share/bash-completion/completions/ductn`
  - [x] manual bash completion smoke test for `ductn ap` and `./ductn ap`
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version`
  - [x] `git diff --check`

---

## Version 5.6.1 Working Baseline

**Version:** `5.6.1+ppa~1`
**Branch rule:** mỗi task = một branch riêng từ `main`
**Workflow reference:** `docs/VERSION-WORKFLOW.md`
**Changelog rule:** mọi task thuộc version này cập nhật chung entry `5.6.1+ppa~1` trong `src/debian/changelog`; không tự tạo version mới.

### Version 5.6.1 Scope

- Tiếp tục migrate Bash scripts từ `src/var/lib/` sang Python modules trong `src/utils/`.
- Hoàn thiện Python CLI command registry qua `@register_command`.
- Giữ Debian packaging ổn định, chỉ sửa khi task thật sự cần.
- Bổ sung documentation đầy đủ để agent khác đọc là làm tiếp được.
- Không xóa legacy Bash script nếu Python chưa có parity và validation đủ.

### Version 5.6.1 Task Workflow

Mỗi task trong version 5.6.1 phải đi theo flow:

```text
Chọn task trong TASKS.md
  ↓
Tạo branch riêng: feat/5.6.1-<task> hoặc fix/5.6.1-<task>
  ↓
Đọc source hiện tại và Bash legacy nếu có
  ↓
Implement Python/code/docs
  ↓
Cập nhật README.md, TASKS.md, src/debian/changelog
  ↓
Tạo docs/UPDATE-YYYY-MM-DD-<topic>.md nếu behavior/package thay đổi
  ↓
Chạy validation phù hợp
  ↓
Commit local
  ↓
Báo cáo Sếp, không push/PR/merge khi chưa được phép
```

### Version 5.6.1 Documentation Checklist

| File | Required | Purpose |
|------|----------|---------|
| `docs/VERSION-WORKFLOW.md` | Always read | Quy trình version/task/branch/changelog/validation |
| `README.md` | Khi command/usage thay đổi | Tài liệu user-facing |
| `TASKS.md` | Mọi task | Tracking scope, status, checklist |
| `src/debian/changelog` | Mọi task thuộc package | Release notes cho `5.6.1+ppa~1` |
| `docs/UPDATE-YYYY-MM-DD-<topic>.md` | Khi behavior/config/package thay đổi | Change note chi tiết |
| Module README nếu có | Khi module có docs riêng | Tài liệu module-specific |

### Version 5.6.1 Task Template

Dùng mẫu này khi thêm hoặc cập nhật task:

```md
### ⏳ Task <id>: <Task Name>
- **Version:** `5.6.1+ppa~1`
- **Status:** ⏳ PENDING
- **Branch:** `feat/5.6.1-<task-name>`
- **Workflow:** `docs/VERSION-WORKFLOW.md`
- **Scope:** <mô tả ngắn task>
- **Source:** `<file gốc nếu có>`
- **Target:** `<file đích nếu có>`
- **Commands:**
  | Command | Description | Status |
  |---------|-------------|--------|
  | `<command>` | <mô tả> | Pending |
- **Documentation:**
  - [ ] `README.md`
  - [ ] `TASKS.md`
  - [ ] `src/debian/changelog` entry `5.6.1+ppa~1`
  - [ ] `docs/UPDATE-YYYY-MM-DD-<topic>.md` nếu cần
- **Validation:**
  - [ ] `python3 -m py_compile <file>` nếu có Python change
  - [ ] `python3 -m compileall src` nếu có Python CLI change
  - [ ] `bash -n <script>` nếu có shell/Debian script change
  - [ ] `cd src && ./ductn commands` nếu command registry đổi
  - [ ] `git diff --check`
- **Definition of Done:**
  - [ ] Code/config/docs hoàn thành
  - [ ] Changelog cập nhật đúng version
  - [ ] Validation OK
  - [ ] Commit local
  - [ ] Báo cáo Sếp
  - [ ] Chưa push/PR/merge khi chưa được phép
```

### Version 5.6.1 Definition of Done

Một task 5.6.1 chỉ được coi là xong local khi đủ:

- [ ] Có branch riêng, không làm trên `main`.
- [ ] Scope đúng một task.
- [ ] Code/config/docs hoàn thành.
- [ ] `README.md` cập nhật nếu command/usage đổi.
- [ ] `TASKS.md` cập nhật trạng thái/checklist.
- [ ] `src/debian/changelog` có bullet trong entry `5.6.1+ppa~1`.
- [ ] Có `docs/UPDATE-*` nếu behavior/config/package thay đổi.
- [ ] Validation chạy OK và ghi lại trong báo cáo.
- [ ] Không secrets/.env/debug/temp files.
- [ ] Commit local theo chuẩn `type(scope): description`.
- [ ] Báo cáo Sếp, không tự push/PR/merge.

### ✅ Task 5.6.1-001: Version workflow documentation
- **Version:** `5.6.1+ppa~1`
- **Status:** ✅ COMPLETED
- **Branch:** `docs/5.6.1-version-workflow`
- **Workflow:** `docs/VERSION-WORKFLOW.md`
- **Scope:** Tạo quy trình chính thức cho version/task/branch/changelog/validation.
- **Target:** `docs/VERSION-WORKFLOW.md`, `TASKS.md`, `AGENTS.md`, `src/debian/changelog`
- **Documentation:**
  - [x] `docs/VERSION-WORKFLOW.md`
  - [x] `TASKS.md`
  - [x] `src/debian/changelog` entry `5.6.1+ppa~1`
- **Validation:**
  - [x] `git diff --check`
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version`
- **Definition of Done:**
  - [x] Docs hoàn thành
  - [x] Changelog cập nhật đúng version
  - [x] Validation OK
  - [x] Commit local
  - [x] PR mở để Sếp review

### ✅ Task 5.6.1-002: Package install locale auto-fix
- **Version:** `5.6.1+ppa~1`
- **Status:** ✅ COMPLETED
- **Branch:** `docs/5.6.1-version-workflow`
- **Workflow:** `docs/VERSION-WORKFLOW.md`
- **Scope:** Tự động cấu hình locale UTF-8 khi cài package `ductn`, ưu tiên `C.UTF-8`, fallback `en_US.UTF-8`.
- **Source:** `src/debian/postinst`, `src/debian/control`
- **Target:** `src/debian/postinst`, `src/debian/control`, `README.md`, `docs/UPDATE-2026-05-27-locale-install.md`, `src/debian/changelog`
- **Documentation:**
  - [x] `README.md`
  - [x] `TASKS.md`
  - [x] `src/debian/changelog` entry `5.6.1+ppa~1`
  - [x] `docs/UPDATE-2026-05-27-locale-install.md`
- **Validation:**
  - [x] `bash -n src/debian/postinst`
  - [x] `bash -n src/build.sh`
  - [x] `dpkg-parsechangelog -l src/debian/changelog -S Version`
  - [x] `git diff --check`
- **Definition of Done:**
  - [x] Locale setup hoàn thành
  - [x] Docs hoàn thành
  - [x] Changelog cập nhật đúng version
  - [x] Validation OK
  - [x] Commit local
  - [x] Update PR để Sếp review

### ✅ Task 5.6.1-003: Deprecate swap commands
- **Version:** `5.6.1+ppa~1`
- **Status:** ✅ COMPLETED
- **Branch:** `docs/5.6.1-version-workflow`
- **Workflow:** `docs/VERSION-WORKFLOW.md`
- **Scope:** Review `src/var/lib/swap.sh`, move legacy swap implementation to `deprecated/`, and remove active `swap:*` commands from the `ductn` package.
- **Source:** `src/var/lib/swap.sh`, `src/utils/swap.py`, `src/utils/__init__.py`
- **Target:** `deprecated/src/var/lib/swap.sh`, `deprecated/src/utils/swap.py`, `TASKS.md`, `README.md`, `docs/UPDATE-2026-05-27-swap-deprecated.md`, `src/debian/changelog`
- **Commands removed:**
  - `swap:remove`
  - `swap:install`
- **Documentation:**
  - [x] `README.md`
  - [x] `TASKS.md`
  - [x] `src/debian/changelog` entry `5.6.1+ppa~1`
  - [x] `docs/UPDATE-2026-05-27-swap-deprecated.md`
- **Validation:**
  - [x] `python3 -m compileall src/utils`
  - [x] `bash -n deprecated/src/var/lib/swap.sh`
  - [x] `! ./ductn commands | tr ' ' '\n' | grep '^swap:'`
  - [x] `git diff --check`
- **Definition of Done:**
  - [x] Active swap commands removed
  - [x] Legacy files moved to `deprecated/`
  - [x] Docs hoàn thành
  - [x] Changelog cập nhật đúng version
  - [x] Validation OK
  - [x] Update PR để Sếp review

### ✅ Task 5.6.1-004: Recreate ssh:cleanup (safe subset)
- **Version:** `5.6.1+ppa~1`
- **Status:** ✅ COMPLETED
- **Branch:** `docs/5.6.1-version-workflow`
- **Workflow:** `docs/VERSION-WORKFLOW.md`
- **Scope:** Tái tạo `src/utils/ssh.py` với `ssh:cleanup` — lệnh an toàn, 2 mode:
  1. Không arg: dedup authorized_keys + fix permissions
  2. Có arg (`ssh:cleanup <ip>`): xóa host key cũ khỏi known_hosts (LXC/VM thay đổi, cùng IP)
- **Source:** `deprecated/src/utils/ssh.py` (tham khảo logic cũ)
- **Target:** `src/utils/ssh.py` (mới, `d_ssh_cleanup`)
- **Commands added:**
  - `ssh:cleanup` — dedup authorized_keys, chmod 700/600
  - `ssh:cleanup <ip_or_hostname>` — xóa host key cũ khỏi known_hosts (tương đương `ssh-keygen -R`)
- **Commands still deprecated:**
  - `ssh:install` — vẫn trong `deprecated/`
  - `ssh:copy` — vẫn trong `deprecated/`
- **Documentation:**
  - [x] `TASKS.md`
  - [x] `src/debian/changelog`
- **Validation:**
  - [x] `python3 -m compileall src/utils/ssh.py`
  - [x] `./ductn ssh:cleanup` — dedup mode
  - [x] `./ductn ssh:cleanup <ip>` — remove host key mode
- **Definition of Done:**
  - [x] `d_ssh_cleanup` hoạt động 2 mode
  - [x] Import trong `__init__.py`
  - [x] Validation OK
  - [x] Update PR để Sếp review

---

## Phase 1: Core Infrastructure (HIGH PRIORITY)

### ✅ Task 1.1: APT Package Management
- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/apt.sh` → deprecated
- **Python:** `src/utils/apt.py`
- **Active Commands:** `apt:fix`, `apt:check`
- **Removed Commands:** `apt:install`, `apt:remove`, `apt:uninstall`
- **Notes:** `apt:fix` tự tìm process giữ lock; không dùng `killall`. Không `--force` thì báo PID/process nếu đang giữ lock. Có `--force`/`-f` thì kill đúng PID đang giữ lock, remove stale locks, rồi repair dpkg/apt.
- **PR:** #7 (merged), updated in 5.6.1 PR #26

### ✅ Task 1.2: DNS Management
- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/dns.sh` → deprecated
- **Python:** `src/utils/dns.py`
- **Commands:** `dns:clean`, `dns:reset`, `dns:disable`, `dns:resolved`
- **PR:** #9, #10 (merged)

### ✅ Task 1.3: SSL Management
- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/ssl.sh` → `deprecated/src/var/lib/ssl.sh`
- **Python:** `src/utils/ssl.py`
- **Commands:**
  | Command | Description |
  |---------|-------------|
  | `ssl:install` | Install certbot plus Cloudflare/Apache/Nginx plugins |
  | `ssl:configure` | Configure default SSL certificates with auto Apache/Nginx integration or DNS fallback |
  | `ssl:setup` | Issue default or custom SSL certificates |
  | `ssl:certbot` | Run certbot with auto Apache/Nginx integration or Cloudflare DNS fallback |
- **Commands removed:** `ssl:pull`, `ssl:push`, `ssl:upload`
- **Tests:** `python3 -m unittest tests.unit.test_ssl -v`

### 🚫 Task 1.4: VPN/WireGuard Management
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/vpn.sh` → `deprecated/src/var/lib/vpn.sh`
- **Python:** `src/utils/vpn.py` → `deprecated/src/utils/vpn.py`
- **Commands removed:**
  - `vpn:wireguard:is_exist`
  - `vpn:wireguard:is:exist`
  - `vpn:wireguard:install`
  - `vpn:wireguard:keygen`
  - `vpn:wireguard:reload`
  - `vpn:wireguard:stop`
  - `vpn:wireguard:example`
  - `vpn:openvpn:uninstall`
  - `vpn:type`
- **Reason:** VPN command group removed from active Bash and Python CLI surface.

### 🚫 Task 1.5: SSH Management
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/ssh.sh` → `deprecated/src/var/lib/ssh.sh`
- **Python:** `src/utils/ssh.py` → `deprecated/src/utils/ssh.py`
- **Commands removed:**
  - `ssh:cleanup`
  - `ssh:install`
  - `ssh:copy`
- **Reason:** SSH command group removed from active Bash and Python CLI surface. Commands manipulate private keys, authorized_keys, and remote access directly; should not be shipped as default package commands without a dedicated, reviewed workflow.

### ✅ Task 1.6: Log Management
- **Status:** ✅ COMPLETED
- **Bash:** `deprecated/src/var/lib/log.sh` (moved)
- **Python:** `src/utils/log.py` — refactored
- **Commands:**
  - `log` — alias for log:watch
  - `log:watch [service]` — tail all /var/log/*log or journalctl -u service -f
  - `log:cleanup [--yes]` — truncate logs, remove rotated files, clear trash (requires confirmation)
  - `log:config` — generate /etc/logrotate.d/ductn for store/mssql users
- **Changes from bash:**
  - Added `--yes` flag for non-interactive cleanup
  - Added confirmation prompt before destructive cleanup
  - Added mssql log dir to rotated file cleanup
  - Replaced shell globbing with Python glob module
  - Used shutil.rmtree instead of rm -rf for trash cleanup

### ✅ Task 1.7: Cronjob Management
- **Status:** ✅ COMPLETED
- **Bash:** `deprecated/src/var/lib/cronjob.sh`
- **Python:** `src/utils/cronjob.py`
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `cron:min` | Add minute cron job |
  | `cron:5min` | Add 5-minute cron job |
  | `cron:hour` | Add hourly cron job |
  | `cron:month` | Add monthly cron job |
- **Action:** Create `src/utils/cronjob.py`

---

## Phase 2: System Administration (MEDIUM PRIORITY)

### ✅ Task 2.1: System Management
- **Status:** ✅ COMPLETED
- **Bash:** `deprecated/src/var/lib/sys.sh` (đã deprecated từ PR #33)
- **Python:** `src/utils/system.py`
- **Commands:**
  | Command | Description | Status |
  |---------|-------------|--------|
  | `update` | Check và upgrade ductn package | ✅ |
  | `sys:sysctl` | Apply sysctl rules từ /etc/sysctl.d/99-ductn.conf | ✅ (mới) |
  | `sys:upgrade` | Gọi `update` (alias) | ✅ |
- **Không migrate:**
  - `sys:init` — Bỏ. Timezone đã có `time:timezone` + postinst. Orchestrator cho tasks chưa sẵn sàng.
  - `sys:clean` — Bỏ. Apt quản lý package, không còn legacy bin/hooks/aliases.
  - `sys:selfupdate` / `__self-update` — Đã hợp nhất vào `update`.
- **Validation:**
  - [x] `python3 -m py_compile src/utils/system.py`
  - [x] `git diff --check`
  - [x] `bash -n src/debian/postinst`
  - [x] postinst gọi `ductn sys:sysctl` trong section `configure` (sau `ductn time:timezone`)
  - [x] Laravel parity verified: bash `php.lar.sh` chỉ có 1 function `php artisan $@`; Python `laravel.py` có đủ parity + mở rộng (composer, cache:clear, config:cache, route:cache)

### ✅ Task 2.2: Host Management
- **Status:** ✅ COMPLETED (phạm vi thu hẹp có chủ đích)
- **Bash:** `deprecated/src/var/lib/host.sh`
- **Python:** `src/utils/host.py`
- **Commands:** `host:name`, `host:domain`, `host:fullname`
- **Bỏ có chủ đích** (không phải "còn lại"):
  - `host:address` → thay bằng `ip:local` / `ip:locals`
  - `host:ip`, `host:address:valid` → `addr.py` đã có `_is_valid_ipv4()`
  - `host:is_server`, `host:is_vpn_server`, `host:serial` → gắn với mô hình
    Proxmox cũ, không còn dùng
  - `hosts:add/remove`, `sys:hosts:*` → sửa `/etc/hosts` bằng tay an toàn hơn
- **Sửa 5.8.6:** `_host_domain()` ưu tiên `search` trong `/etc/resolv.conf`,
  loại suffix dạng IPv4 (host Proxmox `postgresql.192.168.1.1`).

### ✅ Task 2.3: IP Management (complete)
- **Status:** ✅ COMPLETED
- **Bash:** `deprecated/src/var/lib/ip.sh` (moved)
- **Python:** `src/utils/addr.py` — refactored and simplified
- **Commands:**
  - `ip:wan` — get public IP (dig fallback to HTTP)
  - `ip:local` — get local IP from default route interface
  - `ip:locals` — get all IPs from UP interfaces
- **Removed:** `ip:valid` (no longer needed)

### ✅ Task 2.4: Route Management (complete)
- **Status:** ✅ COMPLETED
- **Bash:** `deprecated/src/var/lib/route.sh` (moved)
- **Python:** `src/utils/route.py` — all commands migrated
- **Commands:**
  - `route:default` — get default network interface
  - `route:monitor` — DEPRECATED (old LXC workaround, systemd handles this now)
  - `route:checkAndUp` — integrated into `route:monitor` (checks UP, pings, reloads on failure)
  - `route:reload` — integrated as `_interface_reload()` (down + up)

### ✅ Task 2.5: Service Management
- **Status:** ✅ COMPLETED (viết lại kiến trúc, không port 1-1)
- **Bash:** `deprecated/src/var/lib/service.sh`
- **Python:** `src/utils/system_service.py` (6 command lifecycle) +
  `src/utils/service.py` (daemon scheduler) + `src/utils/serviceScheduler.py`
  + `src/utils/serviceContext.py`
- **Commands:** `service:install`, `service:start`, `service:stop`,
  `service:restart`, `service:status`, `service:watch`, `service` (daemon)
- **Không port:** `sys:service:main`, `sys:service:isactive`,
  `sys:service:re-install`, `d_run_as_service` — kiến trúc cũ dùng vòng lặp
  bash tự viết; nay `ServiceScheduler` + systemd unit đảm nhiệm.

### ✅ Task 2.6: OS Management (complete)
- **Status:** ✅ COMPLETED
- **Bash:** `deprecated/src/var/lib/os.sh` (moved)
- **Python:** `src/utils/system_os.py` — all commands migrated
- **Commands:**
  - `os:codename` — get OS codename (e.g. noble, jammy)
  - `os:release` — get OS version (e.g. 24.04)
  - `os:distro` — get OS distro ID (e.g. ubuntu, debian)
  - `os:architecture` — get machine architecture
  - `os:type` — get OS type (Linux, Darwin)
  - `os:list` — DEPRECATED (web scraping releases.ubuntu.com)

### ✅ Task 2.7: VM Management
- **Status:** ✅ COMPLETED (5.8.7)
- **Bash:** `deprecated/src/var/lib/vm.sh`
- **Python:** `src/utils/vm.py`
- **Commands:**
  - `vm:info` — thông tin VM
  - `vm:sync` — đồng bộ bản ghi A lên DNS nội bộ
  - `vm:agent:install` / `pve:vm` — cài `qemu-guest-agent` (salvage từ bash
    `pve:vm`, trước chỉ là `apt install`)
  - `vm:command '<json>'` — chạy danh sách lệnh từ payload Proxmox
    (salvage từ bash `_vm:command`). **Cảnh báo:** thực thi lệnh tuỳ ý.

### 🚫 Task 2.8: User Management
- **Status:** 🚫 DROPPED (deprecate ở 5.6.4, không phải pending)
- **Bash:** `src/var/lib/user.sh` (111 lines)
- **Python:** `src/utils/user.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `user:new` | Create new user |
  | `user:config` | Configure user |
  | `user:config:bash` | Setup user bash |
  | `user:config:chmod` | Fix user permissions |
  | `user:config:admin` | Make user admin |
  | `user:is_sudoer` | Check if user is sudoer |
- **Action:** Create `src/utils/user.py`

### ✅ Task 2.9: Disk/ZFS Management
- **Status:** ✅ COMPLETED (ZFS replace bổ sung ở 5.8.7)
- **Bash:** `deprecated/src/var/lib/disk.sh`
- **Python:** `src/utils/disk.py`

**Bổ sung 5.8.7 (salvage từ bash):**
  - `disk:check` — nay đo throughput bằng `dd` (8k/512k) đúng như bash;
    trước đó gọi `smartctl` sai mục đích.
  - `disk:health [device]` — tách riêng phần SMART.
  - `zfs:disk:replace:disk <pool> <old> <new>` — thay đĩa hỏng trong
    pool RAIDZ/mirror (bash `zfs:disk:replace_disk`).
  - `zfs:disk:replace:boot <old_disk> <new_disk>` — thay đĩa BOOT Proxmox
    với `sgdisk -R` + `sgdisk -G` + `zpool replace` (bash
    `zfs:disk:replace_boot_disk`). Tên cũ vẫn chạy nhưng deprecated.
  - `zfs:disk:format:boot:disk <part>` — chạy `proxmox-boot-tool
    format|init` có xác nhận (bash chỉ có comment).
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `disk:check` | Check disk health |
  | `disk:check8k` | Check 8K sector disks |
  | `disk:check512k` | Check 512K sector disks |
  | `zfs:disk:list` | List ZFS disks |
  | `zfs:disk:offline` | Take ZFS disk offline |
  | `zfs:disk:replace` | Replace ZFS disk |
  | `zfs:disk:replace_disk` | Replace disk helper |
  | `zfs:disk:replace_boot_disk` | Replace boot disk |
  | `zfs:disk:format_boot_disk` | Format boot disk |
- **Action:** Create `src/utils/disk.py`

### 🚫 Task 2.10: UFW/Firewall Management
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/ufw.sh` → `deprecated/src/var/lib/ufw.sh`
- **Python:** `src/utils/ufw.py` → `deprecated/src/utils/ufw.py`
- **Commands removed:**
  - `ufw:disable`
  - `ufw:geoip:uninstall`
  - `ufw:geoip:allow:cloudflare`
  - `ufw:geoip:allowCloudflare`
  - `ufw:fail2ban:uninstall`
  - `ufw:iptables:uninstall`
- **Reason:** UFW/firewall command group removed from active package surface.

### 🚫 Task 2.11: MySQL Management
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/mysql.sh` → `deprecated/src/var/lib/mysql.sh`
- **Python:** `src/utils/mysql_utils.py` → `deprecated/src/utils/mysql_utils.py`
- **Data/config:** `src/var/lib/mysql/` → `deprecated/src/var/lib/mysql/`
- **Commands removed:**
  - `mysql:setup`
  - `mysql:ssl:enable`
- **Reason:** MySQL command group removed from active Bash and Python CLI surface.

### 🚫 Task 2.12: Swap Management
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/swap.sh` → `deprecated/src/var/lib/swap.sh`
- **Python:** `src/utils/swap.py` → `deprecated/src/utils/swap.py`
- **Commands removed:**
  - `swap:remove`
  - `swap:install`
- **Reason:** Swap command group removed from active Bash and Python CLI surface. Commands directly manipulate `/swapfile` and are no longer shipped by the `ductn` package.

### ✅ Task 2.13: Port Management
- **Status:** ✅ COMPLETED
- **Bash:** `deprecated/src/var/lib/port.sh`
- **Python:** `src/utils/port.py`
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `port:open` | Check if port is open |
- **Action:** Create `src/utils/port.py`

---

## Phase 3: Development Tools (MEDIUM PRIORITY)

### ✅ Task 3.1: Git Management
- **Status:** ✅ COMPLETED (sửa ngữ nghĩa ở 5.8.7)
- **Bash:** `src/var/lib/git.sh` → xoá
- **Python:** `src/utils/git_utils.py`

**Sửa 5.8.7 (Python trước đó sai so với bash):**
  - `git:detrack` chạy `git update-index --no-assume-unchanged`
    (trước: `git rm --cached` — xoá file khỏi index, sai hoàn toàn).
  - `git:untrack` chạy `git update-index --assume-unchanged`
    (trước: alias sang detrack).
  - `git:viewuntrack` parse `git ls-files -v` lấy dòng chữ thường
    (trước: `git status --short` lọc `??`).
  - `git:tag:cleanup [N]` xoá tag cũ trên origin rồi fetch --prune
    (trước: chỉ in danh sách, không xoá).
  - `git:configure --global` bổ sung `core.fileMode`, `core.autocrlf`,
    `core.eol`, `gc.auto`, `receive.denyCurrentBranch`, và sinh
    `~/.gitignore` + trỏ `core.excludesfile` (trước: thiếu hết).
- **Tests:** `tests/unit/test_git_utils.py` (24 test)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `git:configure` | Configure git for project |
  | `git:detrack` | Remove file from tracking |
  | `git:untrack` | Untrack file |
  | `git:viewuntrack` | View untracked files |
  | `git:tag:cleanup` | Cleanup old git tags |
- **Action:** Create `src/utils/git.py`

### ✅ Task 3.2: PHP/Laravel (complete)
- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/php.lar.sh` → `deprecated/src/var/lib/php.lar.sh`
- **Python:** `src/utils/laravel.py` (đã có đủ chức năng)
- **Reason:** Python version có đầy đủ functionality, thậm chí tốt hơn bash (structured subcommands).

### ✅ Task 3.3: PHP/Magento2
- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/php.m2.sh` → `deprecated/src/var/lib/php.m2.sh`
- **Python:** `src/utils/magento2.py` (viết lại hoàn toàn)
- **Wrapper:** `src/ductn/usr/bin/m2` → `/usr/bin/m2`
- **Commands migrated:**
  | Command | Description | Status |
  |---------|-------------|--------|
  | `php:m2` / `m2` | Main entry — show all subcommands or forward to bin/magento | ✅ |
  | `m2:ch` | Fix permissions on Magento directories | ✅ |
  | `m2:group` | Add current user to www-data | ✅ |
  | `m2:urn` | Generate URN catalog + fix permissions | ✅ |
  | `m2:perm` | Fix ownership, permissions, g+ws | ✅ |
  | `m2:rmgen` | Remove generated/code files | ✅ |
  | `m2:static` | Clear static assets + view_preprocessed | ✅ |
  | `m2:cache` | Flush cache + fix permissions | ✅ |
  | `m2:index` | Reindex + fix permissions | ✅ |
  | `m2:grunt` | Run grunt exec:all + watch | ✅ |
  | `m2:up` | Run setup:upgrade + fix permissions | ✅ |
  | `m2:config` | Enable all modules, DI compile, fix permissions | ✅ |
  | `m2:setting` | Apply standard config store settings [domain] | ✅ |
  | `m2:developer` | Enable developer mode with full workflow | ✅ |
  | `m2:logenable` | Enable query log | ✅ |
  | `m2:logdisable` | Disable query log | ✅ |
  | `m2:tempdebugenable` | Enable template hints | ✅ |
  | `m2:tempdebugdisable` | Disable template hints | ✅ |
  | `m2:completion` | Generate bash completion for magerun2 | ✅ |
- **Routing:**
  - `ductn cli` → chỉ hiển thị `php:m2`
  - `m2` (terminal) → hiển thị đầy đủ subcommands
  - `m2 <action>` → `ductn php:m2 <action>`
- **Validation:**
  - [x] `python3 -m py_compile src/utils/magento2.py`
  - [x] `bash -n deprecated/src/var/lib/php.m2.sh`
  - [x] `git diff --check`

### ✅ Task 3.4: PHP General
- **Status:** ✅ COMPLETED (verify SHA384 bổ sung ở 5.8.7)
- **Bash:** `src/var/lib/php.sh` → xoá
- **Python:** `src/utils/php_utils.py`
- **Commands:** `php:apt:install`, `php:composer:install`, `php:install`,
  `php:phpcsfixer:install`
- **Sửa 5.8.7:** `php:composer:install` nay verify SHA384 của installer với
  `composer.github.io/installer.sig` trước khi chạy (trước: comment
  "Verify signature (skip for now)"), và tải vào tmpdir thay vì `~`.

### 🚫 Task 3.5: HTTPD/Web Server
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/httpd.sh` → `deprecated/src/var/lib/httpd.sh`
- **Python:** `src/utils/httpd.py` → `deprecated/src/utils/httpd.py`
- **Commands removed:**
  - `httpd:install`
  - `httpd:config`
  - `httpd:restart`
  - `httpd:config:sites`
- **Reason:** HTTPD command group removed from active `ductn` package command surface. Apache/web-server provisioning should use a dedicated, reviewed workflow before returning to active package commands.

---

## Phase 4: Network & Security (LOWER PRIORITY)

### 🚫 Task 4.1: Environment/Network Config
- **Status:** 🚫 DROPPED (`env.sh` đã vào deprecated/, gắn với hạ tầng Proxmox cũ)
- **Bash:** `src/var/lib/env.sh` (199 lines)
- **Python:** `src/utils/env_config.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `env` | Show env config |
  | `env:domains` | Show domains |
  | `env:nat` | Show NAT config |
  | `env:dhcp` | Show DHCP config |
  | `env:vpn` | Show VPN config |
  | `env:sync` | Sync env config |
- **Action:** Create `src/utils/env_config.py`

### 🚫 Task 4.2: DDNS Management
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/ddns.sh` → `deprecated/src/var/lib/ddns.sh`
- **Python:** `src/utils/ddns.py` → `deprecated/src/utils/ddns.py`
- **Commands removed:**
  - `ddns:bind9:install`
  - `ddns:resolved`
- **Reason:** DDNS command group removed from active Bash and Python CLI surface.

### 🚫 Task 4.3: DNS Technitium
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/dns.technitium.sh` → `deprecated/src/var/lib/dns.technitium.sh`
- **Python:** `src/utils/dns_technitium.py` → `deprecated/src/utils/dns_technitium.py`
- **Commands removed:**
  - `dns:technitium:install`
  - `dns:technitium:record:list`
  - `dns:technitium:recordList`
  - `dns:technitium:get` (legacy target, not active)
- **Reason:** Technitium-specific command group removed from active package surface.

### 🚫 Task 4.4: DHCP Server
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/dhcpd.sh` → `deprecated/src/var/lib/dhcpd.sh`
- **Python:** `src/utils/dhcpd.py` → `deprecated/src/utils/dhcpd.py`
- **Commands removed:**
  - `dhcp:setup`
  - `dhcp:config`
  - `sys:dhcp:setup`
  - `sys:dhcp:config`
- **Related service cleanup:** `sys:service:dhcp` removed from active `src/var/lib/sys.service.valid.sh`.
- **Reason:** DHCPD command group and related service validation removed from active Bash and Python CLI surface.

---

## Phase 5: Utilities & Helpers (LOWEST PRIORITY)

### ✅ Task 5.1: GPG Management
- **Status:** ✅ COMPLETED
- **Bash:** `deprecated/src/var/lib/gpg.sh`
- **Python:** `src/utils/gpg.py`
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `gpg` | GPG main command |
  | `gpg:export` | Export GPG key |
  | `gpg:import` | Import GPG key |
- **Action:** Create `src/utils/gpg.py`

### ✅ Task 5.2: CURL/HTTP Utilities
- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/curl.sh` → xoá
- **Python:** `src/utils/curl_utils.py`
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `curl:get` | HTTP GET request |
  | `curl:gg` | Google search via curl |
- **Action:** Create `src/utils/curl_utils.py`

### ✅ Task 5.3: File Utilities
- **Status:** ✅ COMPLETED (5.8.7)
- **Bash:** `deprecated/src/var/lib/file.sh`
- **Python:** `src/utils/file.py`
- **Commands:**
  - `file:cleanpath` — đổi tên file, bỏ dấu tiếng Việt
  - `file:chmod <path>` — in quyền dạng bát phân
  - `file:chmod:files <mode> <dir>` — chmod đệ quy file
  - `file:chmod:dirs <mode> <dir>` — chmod đệ quy thư mục
- **Tests:** `tests/unit/test_salvage.py`

### ✅ Task 5.4: Bash Completion
- **Status:** ✅ COMPLETED (5.8.7)
- **Bash:** `src/var/lib/completion.sh` → xoá
- **Python:** `src/utils/completion.py` (command cache) +
  `src/utils/completion_paths.py` (tra completion bên thứ ba) +
  `src/ductn/usr/share/bash-completion/completions/ductn` (file tĩnh)
- **Commands:**
  - `completion:cache <show|refresh|path>` — cache danh sách command
  - `completion:path <tool>` — in đường dẫn completion của ductn/magerun/
    magerun2/wp/angular (tìm `/var/www/base/bash/completion/` rồi `~/.completion/`)
  - `completion:exists <tool>` — kiểm tra tool có trong PATH
- **Ghi chú:** bash có 6 function gần trùng nhau (`sys:completion:base`,
  `:magerun`, `:magerun2`, `:wp`, `:angular`, `:exists`); nay gộp thành một
  command có tham số. Giữ quirk `angular` → `angular2.sh`.

### ✅ Task 5.5: MSSQL Support
- **Status:** ✅ COMPLETED (5.8.7)
- **Bash:** `src/var/lib/mssql.sh` → xoá
- **Python:** `src/utils/mssql.py`
- **Commands:**
  | Command | Description |
  |---------|-------------|
  | `sqlsrv:apt` | Thêm Microsoft APT repo (keyring + signed-by) |
  | `sqlsrv:install` / `mssql:install` | Cài SQL Server 2019 |
  | `sqlsrv:php:install` / `mssql:php:install` | ODBC driver + PHP extension |
  | `sqlsrv:php:enable` / `mssql:php:enable` | Bật sqlsrv + pdo_sqlsrv |
  | `sqlsrv:php:disable` / `mssql:php:disable` | Tắt extension |
- **Khác bash gốc:**
  - Dùng keyring `/etc/apt/keyrings/microsoft-prod.asc` + `signed-by`,
    KHÔNG dùng `apt-key` (đã bị bỏ ở Debian 12 / Ubuntu 24.04).
  - Chỉ hỗ trợ Ubuntu 20.04/22.04/24.04 (bash hardcode 16.04–22.04).
  - `sqlsrv:ad:spn` KHÔNG port — trộn PowerShell/ktpass và chứa mật khẩu
    domain trong argv. Giữ làm runbook: `docs/MSSQL-AD-SPN.md`.
- **Tests:** `tests/unit/test_mssql.py` (26 test)

### 🚫 Task 5.6: Sys Service Validation
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/sys.service.valid.sh` → `deprecated/src/var/lib/sys.service.valid.sh`
- **Reason:** apache2, mysql, mssql-server không còn sử dụng. Dependencies đã deprecated (`swap:install`, `log:cleanup` thuộc Task 1.6). Moved to deprecated/ trong version 5.6.5.

### ✅ Task 5.7: Server Install
- **Status:** ✅ COMPLETED
- **Bash:** `deprecated/src/var/lib/server.sh`
- **Python:** `src/utils/server.py`
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `server:install` | Full server setup |
- **Action:** Create `src/utils/server.py`

### ✅ Task 5.8: Environment Detection (color/text)
- **Status:** ✅ COMPLETED (5.8.7)
- **Bash:** `src/var/lib/environment.sh`, `environment.color.sh`,
  `environment.text.sh` → xoá
- **Python:** `src/utils/env_detect.py` (virt/DMI/container detection) +
  `src/utils/style.py` (ANSI palette + status glyphs)
- **Ghi chú:** ba file bash chỉ định nghĩa biến màu ANSI và 3 ký hiệu
  `TXTtrue`/`TXTfalse`/`TXTinfo`, không có function. Nay là `style.py` với
  `GREEN`/`B_RED`/`ON_WHITE`…, `ok()`/`fail()`/`info()`, và tự tắt màu khi
  không phải TTY hoặc có `NO_COLOR`.
- **Tests:** `tests/unit/test_style.py` (16 test)

### ✅ Task 5.9: Helper Functions
- **Status:** ✅ COMPLETED (5.8.7)
- **Bash:** `src/var/lib/functions.sh` → xoá
- **Python:** `src/utils/helpers.py`
- **Commands:** `echo`, `hash:md5`, `ssh`
- **Ghi chú:** `--logger` nay dùng `logging` chuẩn; `--hash_MD5` thành
  `hash:md5` (dùng `secrets` 20 ký tự thay `$RANDOM | md5sum`); `--ssh`
  thành `ssh` (giữ `-T`, nhưng không nuốt stderr như bash).
- **Tests:** `tests/unit/test_helpers.py` (13 test)

### ✅ Task 5.10: Main Entry Point
- **Status:** ✅ COMPLETED (5.8.7)
- **Bash:** `src/var/lib/main.sh` → xoá; `src/var/lib/ductnd.sh.org` → xoá
- **Python:** `src/ductn.py` (entry point) + `src/utils/fleet.py`
  (`fleet:status`)
- **Salvage:** `main.sh:_main()` có hai nửa. Nửa **inventory** (duyệt domain
  qua SSH, đọc FQDN + version, cảnh báo host lệch bản) đã port thành
  `fleet:status`. Nửa **WireGuard provisioning** không port: hardcode dải
  `10.8.x.x`, ghi config qua `sudo tee`, phụ thuộc `--host:serial` (Proxmox
  VMID) — tất cả thuộc môi trường đã bị deprecate cùng `env.sh`.
- **Tests:** `tests/unit/test_salvage.py`

---

## Migration Rules

1. Each module must have docstrings for all public functions.
2. Register commands with `@register_command` decorator.
3. Support both Linux and macOS where applicable.
4. Do NOT delete bash script until Python equivalent is tested and working.
5. Move deprecated bash scripts to `deprecated/src/var/lib/`.
6. Update this file after each migration.

---

**Tổng kết 2026-11-25:** `src/var/lib/` rỗng. 0 file bash chưa migrate.
`deprecated/src/var/lib/` giữ 31 file làm lịch sử, không được đóng gói.
