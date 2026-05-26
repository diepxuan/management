# UPDATE 2026-05-26 - ductn cli tmux integration

## Mục đích

Tích hợp script `/root/scripts/ductncli` vào package `ductn` để người dùng chạy qua command public:

```bash
ductn cli
```

## Thay đổi chính

- Thêm script package: `src/ductn/usr/bin/ductncli`.
- Thêm tmux config mặc định: `src/ductn/etc/ductn/tmux.conf`.
- Thêm Python command module: `src/utils/cli.py`.
- Import module mới trong `src/utils/__init__.py`.
- Cập nhật Debian install mapping trong `src/debian/ductn.install`.
- Cập nhật `src/debian/postinst` để:
  - set executable bit cho `/usr/bin/ductncli`;
  - copy `/etc/ductn/tmux.conf` sang `/root/.tmux.conf`;
  - ghi đè trực tiếp config cũ, không tạo backup.

## Commands

```bash
# Mở menu chọn agent, workspace mặc định ~/
ductn cli

# Mở Hermes trong project shortcut ductnd
ductn cli ductnd

# Mở Codex trong project shortcut ductnd
ductn cli codex ductnd

# Cài lại tmux config mặc định vào ~/.tmux.conf
ductn cli:tmux:install

# Reload tmux config
ductn cli:tmux:reload
```

## Path resolution của ductncli

- Không truyền path: dùng `~/`.
- Absolute path: dùng trực tiếp nếu directory tồn tại.
- Relative path: thử `./path`, sau đó `~/path`.
- Project shortcut: thử `~/.openclaw/workspace/projects/<name>`, sau đó `~/.hermes/workspace/projects/<name>`.

## Tmux behavior

- Session name dạng `<agent>-<workspace-slug>`.
- Nếu session đã tồn tại thì attach lại, không tạo session mới.
- Nếu session thiếu pane shell bên phải thì tạo thêm đúng một pane.
- Layout mặc định: pane trái chạy agent, pane phải là bash.

## Dependencies runtime

- `tmux`
- `realpath`
- `hermes` khi chạy agent Hermes
- `codex` khi chạy agent Codex

## Troubleshooting

### `ERROR: ductncli script not found: /usr/bin/ductncli`

Package chưa cài file script. Cài lại package hoặc kiểm tra `src/debian/ductn.install` trong build artifact.

### `Required command not found: tmux`

Cài `tmux` trên máy đích.

### Không muốn ghi đè `/root/.tmux.conf`

Trước khi cài package, backup file thủ công. `postinst` luôn ghi đè trực tiếp `/root/.tmux.conf` bằng config mặc định từ `/etc/ductn/tmux.conf`.
