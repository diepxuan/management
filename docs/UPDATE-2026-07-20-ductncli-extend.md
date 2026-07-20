# UPDATE-2026-07-20 — ductncli extended registry (5.7.2)

## Mục đích

Phiên bản `5.7.2+ppa~1` mở rộng `ductncli` để hỗ trợ thêm nhiều AI agent CLI
phổ biến — không chỉ `codex` và `openclaw` — đồng thời cho phép người dùng
ghi đè registry mặc định qua file YAML ở `~/.config/ductn/config.yml` và
biến môi trường.

Các agent không có sẵn trên hệ thống sẽ bị ẩn khỏi menu tương tác và bị từ
chối nếu truyền vào `ductncli`, tránh thông báo lỗi khó hiểu.

## Mặc định 5.7.2

Registry mặc định trong `src/utils/cli.py` (`AGENTS_DEFAULT`):

| Name        | Default args             | Mô tả                          |
|-------------|--------------------------|--------------------------------|
| `hermes`    | `[]`                     | Hermes CLI                     |
| `codex`     | `[--profile, ninerouter]`| Codex với profile `ninerouter` |
| `openclaw`  | `[tui]`                  | OpenClaw TUI                   |
| `freebuff`  | `[]`                     | Freebuff                       |
| `claude`    | `[]`                     | Anthropic Claude CLI           |
| `gemini`    | `[]`                     | Google Gemini CLI              |
| `aider`     | `[]`                     | Aider coding assistant         |
| `llm`       | `[]`                     | Simon Willison's llm CLI       |
| `aichat`    | `[]`                     | aichat                         |
| `cursor`    | `[]`                     | Cursor IDE launcher            |
| `windsurf`  | `[]`                     | Windsurf IDE launcher          |
| `continue`  | `[]`                     | Continue                       |
| `goose`     | `[]`                     | Goose                          |
| `qwen`      | `[]`                     | Qwen CLI                       |
| `chatgpt`   | `[]`                     | ChatGPT CLI                    |
| `sgpt`      | `[]`                     | Shell GPT                      |
| `mod`       | `[]`                     | mod                            |

Cột "Default args" là đối số được truyền cho binary khi khởi chạy qua
`os.execv`. Chỉ những agent có binary thực sự tồn tại trên hệ thống
(shutil.which hoặc các thư mục fallback pnpm/npm/apt/Homebrew) mới được
liệt kê trong menu và trong thông báo lỗi "Unknown agent".

## Ghi đè qua file YAML

Đường dẫn được đọc theo thứ tự:

1. `$XDG_CONFIG_HOME/ductn/config.yml`
2. `~/.config/ductn/config.yml`

File phải ở định dạng YAML subset (xem schema bên dưới). Tệp không tồn tại
hoặc lỗi parse sẽ được bỏ qua; registry sẽ chỉ dùng giá trị mặc định.

### Schema

```yaml
# Key `agents:` là một danh sách các entry. Mỗi entry có các trường:
#   name:        bắt buộc, string
#   args:        tùy chọn, danh sách string (đối số truyền cho binary)
#   description: tùy chọn, string
#   enabled:     tùy chọn, bool (mặc định true nếu entry đã tồn tại ở default)

agents:
  # Ghi đè `codex` default: đổi profile và mô tả
  - name: codex
    args: ["--profile", "my-team"]
    description: "Codex cho team nội bộ"

  # Tắt `gemini` (chưa cài trên máy này)
  - name: gemini
    enabled: false

  # Thêm một entry tùy chỉnh
  - name: mybot
    args: ["--model", "gpt-5"]
    description: "Bot nội bộ của công ty"
```

Quy tắc merge:

- Entry trùng `name` với default sẽ ghi đè các trường có mặt; thiếu trường
  thì giữ nguyên giá trị cũ.
- Entry mới (không có trong default) sẽ được thêm vào registry.
- `enabled: false` không xoá entry khỏi registry, chỉ ẩn khỏi menu và
  autocomplete. Nếu muốn xoá hẳn, đơn giản không liệt kê trong config.

## Ghi đè qua biến môi trường

Biến môi trường dạng `DuctnCLI_AGENT_ARGS_<NAME>` ghi đè trực tiếp `args`
của agent. Tên biến là tên agent viết hoa, các ký tự không phải chữ-số
được đổi thành `_`. Ví dụ:

```bash
DuctnCLI_AGENT_ARGS_CODEX="--profile blue"
DuctnCLI_AGENT_ARGS_OPENCLAW="tui --debug"
```

Thứ tự ưu tiên từ thấp đến cao:

1. `AGENTS_DEFAULT` trong code
2. `config.yml` của người dùng
3. Biến môi trường (cao nhất)

## Tương thích ngược

- `ductncli hermes`, `ductncli codex`, `ductncli openclaw` vẫn chạy như
  trước, kể cả khi config không tồn tại.
- Menu số (`1) hermes`, `2) codex`, `3) openclaw`) vẫn hoạt động nếu cả ba
  vẫn được cài. Khi thêm/bớt agent, menu dùng số động dựa trên danh sách
  cài sẵn.
- Chấp nhận ký tự đầu của tên (`c` → `codex`, `o` → `openclaw`) chỉ khi
  match duy nhất; nếu có nhiều agent cùng chữ cái đầu, sẽ bị từ chối.

## Phụ thuộc

Không thêm dependency Python mới. YAML loader viết tay (~120 dòng) để
không phải kéo `PyYAML` vào danh sách requirements và tránh đổi binary
distribution.

## Validation

```bash
python3 -m unittest tests.unit.test_cli -v
bash -n src/build.sh
```

## Rủi ro

- YAML loader chỉ hỗ trợ subset: mapping lồng nhau, list of mappings,
  list of scalars, comment `#`. Không hỗ trợ anchor, alias, flow style
  (`{a: 1}`), tag (`!ref`), hoặc multi-document. Người dùng cần YAML phức
  tạp có thể cài `python3-yaml` rồi đợi release sau.
- Biến môi trường `DuctnCLI_AGENT_ARGS_<NAME>` không validate giá trị;
  sai tên biến sẽ im lặng, không override.
- Thay đổi này **không tự động cập nhật** bash completion cache
  (`/usr/share/ductn/commands`). Lần nâng cấp đầu tiên có thể cần chạy
  `ductn completion:cache refresh` hoặc ignore vì cache chỉ phục vụ
  bash completion cho subcommand `ductn`, không phải cho `ductncli`.
