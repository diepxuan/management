# MSSQL — Kerberos / AD SPN runbook

Phần này **không** được ship thành command trong gói `ductn`. Lý do: script bash gốc
(`src/var/lib/mssql.sh`, hàm `__sqlsrv:ad:spn`) trộn ba môi trường khác nhau (Domain
Controller Windows, SQL Server host, KDC) và nhúng mật khẩu domain trực tiếp trong argv.
Chạy nó như một command của package là đưa credential vào lịch sử shell và log.

Giữ lại đây làm tài liệu thao tác thủ công.

---

## 1. Trên Domain Controller (Windows PowerShell)

Tạo user service cho SQL Server:

```powershell
Import-Module ActiveDirectory
New-ADUser mssql -AccountPassword (Read-Host -AsSecureString "Enter Password") `
  -PasswordNeverExpires $true -Enabled $true
```

Trong **Properties → Accounts → Account options**, tick:

- This account supports Kerberos AES 128 bit encryption
- This account supports Kerberos AES 256 bit encryption

## 2. Tạo SPN

```powershell
setspn -A MSSQLSvc/dc3.diepxuan.com:1433 mssql
setspn -A MSSQLSvc/dx3:1433 mssql
```

## 3. Kiểm tra từ SQL Server host

```bash
kinit Administrator@DIEPXUAN.COM
kvno Administrator@DIEPXUAN.COM
kvno MSSQLSvc/dx3:1433@DIEPXUAN.COM
# kỳ vọng: MSSQLSvc/dx3:1433@DIEPXUAN.COM: kvno = 2
```

## 4. Sinh keytab trên Domain Controller

```powershell
ktpass /princ MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL `
  /crypto aes256-sha1 /mapuser mssql@diepxuan.com /out mssql.keytab `
  -setpass -setupn /kvno 2 /pass <PASSWORD>

ktpass /princ MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL `
  /crypto rc4-hmac-nt /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab `
  -setpass -setupn /kvno 2 /pass <PASSWORD>

# lặp lại cho MSSQLSvc/dx3:1433 và cho principal mssql@DIEPXUAN.COM
```

> Trong bash gốc, `<PASSWORD>` là chuỗi literal `Ductn@7691`. Chuỗi đó đã nằm
> trong git history — **cần đổi mật khẩu tài khoản `mssql`** và không ghi lại
> vào repo.

## 5. Nạp keytab trên SQL Server host (nếu không copy file từ DC)

```bash
sudo ktutil
ktutil: addent -password -p MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM -k 2 -e aes256-cts-hmac-sha1-96
ktutil: addent -password -p MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM -k 2 -e rc4-hmac
ktutil: addent -password -p MSSQLSvc/dx3:1433@DIEPXUAN.COM -k 2 -e aes256-cts-hmac-sha1-96
ktutil: addent -password -p MSSQLSvc/dx3:1433@DIEPXUAN.COM -k 2 -e rc4-hmac
ktutil: addent -password -p mssql@DIEPXUAN.COM -k 2 -e aes256-cts-hmac-sha1-96
ktutil: addent -password -p mssql@DIEPXUAN.COM -k 2 -e rc4-hmac
ktutil: wkt /var/opt/mssql/secrets/mssql.keytab
ktutil: quit
```

Hoặc copy `mssql.keytab` từ DC vào `/var/opt/mssql/secrets/`.

## 6. Cấu hình SQL Server dùng keytab

```bash
sudo chown mssql:mssql /var/opt/mssql/secrets/mssql.keytab
sudo chmod 400 /var/opt/mssql/secrets/mssql.keytab
sudo mssql-conf set network.privilegedadaccount mssql
sudo /opt/mssql/bin/mssql-conf set network.kerberoskeytabfile /var/opt/mssql/secrets/mssql.keytab
sudo systemctl restart mssql-server
```

## 7. Kiểm tra

```bash
klist -k /var/opt/mssql/secrets/mssql.keytab
sqlcmd -S localhost -U sa -P '<sa-password>' -Q "SELECT @@VERSION"
```

---

## Liên quan

- Cài đặt SQL Server / PHP driver: `ductn sqlsrv:install`, `ductn sqlsrv:php:install`
- Code: `src/utils/mssql.py`
- Script gốc đã xoá: `src/var/lib/mssql.sh` (version 5.8.7)
