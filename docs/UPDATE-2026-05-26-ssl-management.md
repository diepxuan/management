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
| `ssl:install` | Cài `certbot` và `python3-certbot-dns-cloudflare` qua APT |
| `ssl:configure` | Kiểm tra Cloudflare credentials rồi chạy setup mặc định |
| `ssl:setup` | Cấp cert cho domain mặc định hoặc domain truyền vào, sau đó restart apache2 |
| `ssl:certbot` | Chạy certbot DNS challenge trực tiếp cho domain truyền vào |
| `ssl:pull` | Pull cert từ remote host về local `/etc/letsencrypt/live/<domain>/` |
| `ssl:push` | Push cert local sang remote host |
| `ssl:upload` | Alias của `ssl:push` |

## Hành vi giữ từ Bash legacy

- Cloudflare credentials mặc định: `/etc/ductn/cloudflare`
- Email certbot mặc định: `caothu91@gmail.com`
- Domain setup mặc định:
  - `diepxuan.com`, `*.diepxuan.com`
  - `vps.diepxuan.com`, `*.vps.diepxuan.com`
- File cert đồng bộ:
  - `cert.pem`
  - `chain.pem`
  - `fullchain.pem`
  - `privkey.pem`
- `ssl:setup` restart Apache bằng `service apache2 restart` sau khi chạy certbot.

## Cách dùng

```bash
# Cài certbot + Cloudflare plugin
sudo ductn ssl:install

# Setup cert mặc định
sudo ductn ssl:setup

# Setup cert custom, hỗ trợ comma-separated domains
sudo ductn ssl:certbot example.com,*.example.com

# Pull cert mặc định diepxuan.com từ remote
sudo ductn ssl:pull server.example.com

# Pull cert custom domain từ remote
sudo ductn ssl:pull server.example.com example.com

# Push cert mặc định diepxuan.com tới remote
sudo ductn ssl:push server.example.com

# Upload là alias của push
sudo ductn ssl:upload server.example.com
```

## Dependencies

- Python stdlib: `os`, `shutil`, `subprocess`, `logging`
- System packages:
  - `certbot`
  - `python3-certbot-dns-cloudflare`
  - `openssh-client`
  - `apache2` nếu dùng restart mặc định
- Credentials file:
  - `/etc/ductn/cloudflare`

## Testing

Đã thêm/cập nhật unit tests cho:

- Constants và domain defaults
- Command registration
- Cloudflare credentials check
- Domain normalization
- Certbot command builder
- `ssl:install` APT sequence
- `ssl:certbot`, `ssl:setup`, `ssl:configure`
- `ssl:pull`, `ssl:push`, `ssl:upload`

Lệnh test:

```bash
python3 -m unittest tests.unit.test_ssl -v
python3 -m compileall -q src tests
```

## Troubleshooting

### Không tìm thấy Cloudflare credentials

Kiểm tra file:

```bash
sudo test -f /etc/ductn/cloudflare
sudo chmod 600 /etc/ductn/cloudflare
```

### Certbot fail do quyền

Các command SSL cần quyền root vì thao tác với `/etc/letsencrypt` và `/etc/ductn`.

### SSH pull/push fail

Kiểm tra remote host, SSH key, sudo quyền đọc/ghi `/etc/letsencrypt/live/<domain>/` trên remote.

## Ghi chú thiết kế

- Bash legacy đã được chuyển từ `src/var/lib/ssl.sh` sang `deprecated/src/var/lib/ssl.sh` sau khi Python equivalent có unit test và command registration pass.
- `ssl:pull`/`ssl:push` giữ default domain `diepxuan.com` để tương thích Bash cũ, đồng thời hỗ trợ thêm optional domain ở arg thứ 2.
