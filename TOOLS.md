# TOOLS.md - ductnd Local Notes

## Paths

| Path | Description |
|------|-------------|
| `src/ductn.py` | Main CLI (Python) |
| `src/ductn.sh` | Bash wrapper (venv/uv) |
| `src/etc/ductn.conf` | Production config (.env format) |
| `src/debian/` | Package metadata |
| `src/debian/control` | Package definitions |
| `src/debian/changelog` | Version history |
| `TASKS.md` | Migration tracking (Bash → Python) |

## Quick Commands

```bash
# Run CLI directly
./ductn -v
uv run src/ductn.py <command>

# With venv
python3 -m venv venv && source venv/bin/activate
pip install -r src/requirements.txt
python src/ductn.py <command>

# Build Debian package
cd src/debian && debuild -us -uc
```

## Config Notes

- `src/etc/ductn.conf` — Laravel-style .env, do NOT commit with real credentials
- `src/debian/control` — Maintainer: Tran Ngoc Duc <ductn@diepxuan.com>
- Packages: ductn, lar, m2, ductn-ll

## Dependencies

### Python
- `src/requirements.txt`

### System (Debian)
- net-tools, jq, curl, bash-completion, openssl, unzip, apt-transport-https, sudo, dnsutils, lsof, ductn-ll

### Build
- debhelper-compat (= 12), dh-python, python3-venv, python3-pip, python3-dev, libpython3-all-dev

## SSH Hosts

| Host | Purpose |
|------|---------|
| ppa.diepxuan.com | Package repository server |
| admin.diepxuan.com | Production server |

**Need:** SSH details from Sếp.

## Debugging

```bash
# CLI not working
python3 --version
ls -la venv/bin/activate
pip show argcomplete

# Build fail
cd src/debian && lintian
debuild -us -uc 2>&1 | grep -i error

# Import errors
ls -la src/utils/
python3 -c "from utils import *; print(COMMANDS)"
```

## Release Checklist

- [ ] Update `src/debian/changelog`
- [ ] Bump version in control files
- [ ] Test CLI commands
- [ ] Build package locally
- [ ] Test .deb installation
- [ ] Commit + tag → PR → review → merge
- [ ] Upload to PPA
