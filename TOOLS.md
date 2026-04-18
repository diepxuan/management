# TOOLS.md - Local Notes

**Project:** ductnd (DiepXuan Personal Package)  
**Cập nhật:** 2026-04-18

---

## 1. Paths quan trọng

| Đường dẫn | Mô tả |
|-----------|-------|
| `/root/.openclaw/workspace/projects/ductnd/` | Workspace root |
| `src/ductn.py` | Main CLI entry point (Python) |
| `src/ductn.sh` | Bash wrapper (venv/uv support) |
| `src/etc/ductn.conf` | Production config (Laravel-style .env) |
| `src/debian/` | Debian package metadata |
| `src/debian/control` | Package definitions |
| `src/debian/changelog` | Version history |
| `app/Console/Commands/` | Laravel commands |
| `.github/workflows/build.yml` | CI/CD pipeline |

---

## 2. Commands hữu ích

### 2.1. Development

```bash
# Chạy CLI trực tiếp (development)
cd /root/.openclaw/workspace/projects/ductnd/
./ductn -v
uv run src/ductn.py <command>

# Tạo venv và chạy
python3 -m venv venv
source venv/bin/activate
pip install -r src/requirements.txt
python src/ductn.py <command>
```

### 2.2. Build package

```bash
# Build Debian package
cd src/debian/
debuild -us -uc

# Hoặc từ root
cd /root/.openclaw/workspace/projects/ductnd/
# (cần thêm build script nếu chưa có)
```

### 2.3. Git workflow

```bash
# Tạo branch mới cho task
git checkout -b feature/<task-name>

# Commit với convention
git commit -m "type(scope): description"

# Push branch (không push main)
git push origin feature/<task-name>
```

---

## 3. Config notes

### 3.1. Production config (`src/etc/ductn.conf`)

```bash
APP_NAME=DXPanel
APP_ENV=production
APP_DEBUG=false
APP_URL=https://admin.diepxuan.com
SERVER_PORT=8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=

# SSL MySQL
MYSQL_ATTR_SSL=true
MYSQL_ATTR_SSL_KEY=/etc/mysql/certs/client-key.pem
MYSQL_ATTR_SSL_CERT=/etc/mysql/certs/client-cert.pem
MYSQL_ATTR_SSL_CA=/etc/mysql/certs/ca-cert.pem
```

**⚠️ Lưu ý:**
- Không commit file này với credentials thật
- Production dùng SSL certificates từ `/etc/mysql/certs/`
- `APP_DEBUG=false` trong production

### 3.2. Package metadata (`src/debian/control`)

- **Maintainer:** Tran Ngoc Duc <ductn@diepxuan.com>
- **Priority:** optional
- **Section:** devel
- **Packages:** ductn, lar, m2, ductn-ll

---

## 4. Dependencies

### 4.1. Python (src/requirements.txt)

```bash
# Kiểm tra dependencies hiện tại
cat src/requirements.txt

# Cài đặt
pip install -r src/requirements.txt
```

### 4.2. System packages (Debian)

```bash
# Từ src/debian/control
Depends: net-tools, jq, curl, bash-completion, openssl, unzip,
         apt-transport-https, sudo, dnsutils, lsof,
         ductn-ll
```

### 4.3. Build dependencies

```bash
Build-Depends: debhelper-compat (= 12),
               dh-python, python3-venv, python3-pip, python3-dev,
               libpython3-all-dev
```

---

## 5. SSH hosts

| Host | IP/Domain | User | Ghi chú |
|------|-----------|------|---------|
| ppa.diepxuan.com | TBD | TBD | Package repository server |
| admin.diepxuan.com | TBD | TBD | Production server (APP_URL) |

**⚠️ Cần bổ sung:** SSH details khi có thông tin từ Sếp.

---

## 6. CI/CD

### 6.1. GitHub Actions

- File: `.github/workflows/build.yml`
- Trigger: push, pull_request
- Job: build Debian package

### 6.2. Build process

1. Checkout code
2. Install build dependencies
3. Run `debuild`
4. Upload artifacts (.deb files)

---

## 7. Debugging tips

### 7.1. CLI không chạy

```bash
# Kiểm tra Python version
python3 --version

# Kiểm tra venv
ls -la venv/bin/activate

# Re-create venv
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r src/requirements.txt

# Check argcomplete
pip show argcomplete
```

### 7.2. Build fail

```bash
# Kiểm tra debian/control syntax
cd src/debian/
lintian

# Check missing files
debuild -us -uc 2>&1 | grep -i error
```

### 7.3. Import errors

```bash
# Kiểm tra utils module
ls -la src/utils/
python3 -c "from utils import *; print(COMMANDS)"
```

---

## 8. Package structure

```
ductn (main package)
├── ductn-ll (ll command, like ls -l)
├── lar (Laravel support)
│   └── Depends: ductn
└── m2 (Magento 2 support)
    └── Depends: ductn
```

---

## 9. Release checklist

- [ ] Update `src/debian/changelog`
- [ ] Bump version trong control files
- [ ] Test CLI commands
- [ ] Build package locally
- [ ] Test installation từ .deb
- [ ] Commit + tag release
- [ ] Push branch → PR → review → merge
- [ ] Upload to PPA repository

---

## 10. Notes cần bổ sung

- [ ] SSH host details (ppa.diepxuan.com, admin.diepxuan.com)
- [ ] MySQL SSL certificates path (production)
- [ ] PPA upload credentials (GPG key)
- [ ] Full list of CLI commands từ `ductn --help`
- [ ] Test cases cho mỗi command

---

**TOOLS.md là cheat sheet — cập nhật khi học được info mới.**
