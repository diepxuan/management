# UPDATE-2026-05-26 - SSL Management Python Migration

## Mục đích

Migrate nhóm command SSL từ Bash legacy `src/var/lib/ssl.sh` sang Python module `src/utils/ssl.py` theo command registry hiện tại của `ductn`.

## Phạm vi thay đổi

Module Python mới/được cập nhật:

- `src/utils/ssl.py`

Test cập nhật:

- `tests/unit/test_ssl.py`

Backlog cập nhật:

- `TASKS.md`

## Commands được hỗ trợ

| Command | Mục đích |
|---------|----------|
| `ssl:install` | Cài `certbot`, Cloudflare DNS plugin, Apache plugin và Nginx plugin qua APT |
| `ssl:configure` | Chạy setup mặc định bằng certbot auto-integrate hoặc Cloudflare DNS fallback |
| `ssl:setup` | Cấp cert cho domain mặc định hoặc domain truyền vào |
| `ssl:certbot` | Chạy certbot cho domain truyền vào, tự chọn Apache/Nginx/DNS mode |

Các command `ssl:pull`, `ssl:push`, `ssl:upload` đã bị xóa khỏi command surface theo yêu cầu vì không còn dùng flow copy cert qua SSH.

## Hành vi hiện tại

- Email certbot mặc định: `caothu91@gmail.com`
- Domain setup mặc định:
  - `diepxuan.com`, `*.diepxuan.com`
  - `vps.diepxuan.com`, `*.vps.diepxuan.com`
- Certbot mode được chọn tự động:
  1. Nếu domain có wildcard (`*.example.com`) → dùng Cloudflare DNS challenge.
  2. Nếu máy có `apache2` và vhost Apache khai báo đúng domain bằng `ServerName`/`ServerAlias` → dùng `certbot --apache`.
  3. Nếu máy có `nginx` và vhost Nginx khai báo đúng domain bằng `server_name` → dùng `certbot --nginx`.
  4. Nếu không match vhost → fallback Cloudflare DNS challenge.
- Cloudflare credentials mặc định khi dùng DNS fallback: `/etc/ductn/cloudflare`.
- Không restart Apache thủ công sau setup; plugin `certbot --apache`/`--nginx` tự xử lý reload/integration khi được chọn.

## Cách dùng

```bash
# Cài certbot + Cloudflare/Apache/Nginx plugins
sudo ductn ssl:install

# Setup cert mặc định
sudo ductn ssl:setup

# Setup cert custom, hỗ trợ comma-separated domains
sudo ductn ssl:certbot example.com,www.example.com

# Wildcard sẽ dùng DNS challenge
sudo ductn ssl:certbot example.com,*.example.com
```

## Dependencies

- Python stdlib: `os`, `pathlib`, `shutil`, `subprocess`, `logging`
- System packages:
  - `certbot`
  - `python3-certbot-dns-cloudflare`
  - `python3-certbot-apache`
  - `python3-certbot-nginx`
  - `apache2` nếu muốn auto-integrate Apache
  - `nginx` nếu muốn auto-integrate Nginx
- Credentials file khi dùng DNS fallback:
  - `/etc/ductn/cloudflare`

## Testing

Đã thêm/cập nhật unit tests cho:

- Constants và domain defaults
- Command registration và xác nhận đã xóa `ssl:pull`/`ssl:push`/`ssl:upload`
- Cloudflare credentials check
- Domain normalization
- Certbot command builder cho DNS/Apache/Nginx
- Apache/Nginx vhost detection
- Certbot mode selection
- `ssl:install` APT sequence
- `ssl:certbot`, `ssl:setup`, `ssl:configure`

Lệnh test:

```bash
python3 -m unittest tests.unit.test_ssl -v
python3 -m compileall -q src tests
```

## Troubleshooting

### Không tìm thấy Cloudflare credentials

Xảy ra khi fallback sang DNS challenge. Kiểm tra file:

```bash
sudo test -f /etc/ductn/cloudflare
sudo chmod 600 /etc/ductn/cloudflare
```

### Certbot fail do quyền

Các command SSL cần quyền root vì thao tác với `/etc/letsencrypt`, webserver config và `/etc/ductn`.

### Apache/Nginx không được auto-integrate

Kiểm tra:

- Binary `apache2` hoặc `nginx` tồn tại trong `PATH`.
- Apache vhost có `ServerName`/`ServerAlias` đúng domain.
- Nginx vhost có `server_name` đúng domain.
- Wildcard domain luôn dùng DNS challenge, không dùng Apache/Nginx plugin.

## Ghi chú thiết kế

- Bash legacy đã được chuyển từ `src/var/lib/ssl.sh` sang `deprecated/src/var/lib/ssl.sh` sau khi Python equivalent có unit test và command registration pass.
- Auto-integrate chỉ bật khi vhost local match đúng domain để tránh certbot sửa nhầm webserver config.
- DNS fallback giữ Cloudflare plugin để hỗ trợ wildcard và môi trường không có vhost local tương ứng.
