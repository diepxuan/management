taskkill /f /im OneDrive.exe

%SystemRoot%\System32\OneDriveSetup.exe /uninstall
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall

rd "%UserProfile%\OneDrive" /Q /S
rd "%LocalAppData%\Microsoft\OneDrive" /Q /S
rd "%ProgramData%\Microsoft OneDrive" /Q /S
rd "C:\OneDriveTemp" /Q /S

REG Delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
REG Delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f

rem netsh advfirewall firewall add rule name="Deny CCleaner x64" dir=in action=allow program="C:\Program Files\CCleaner\CCleaner64.exe"
rem netsh advfirewall firewall add rule name="Deny CCleaner" dir=in action=allow program="C:\Program Files\CCleaner\CCleaner.exe"

rem netsh advfirewall firewall add rule name="Deny CCleaner x64" dir=in action=block program="C:\Program Files\CCleaner\CCleaner64.exe"
rem netsh advfirewall firewall add rule name="Deny CCleaner" dir=in action=block program="C:\Program Files\CCleaner\CCleaner.exe"

rem netsh advfirewall firewall add rule name="Deny Adobe" dir=in interface=any action=block remoteip=192.150.16.69
rem netsh advfirewall firewall add rule name="Deny Adobe" dir=out interface=any action=block remoteip=192.150.16.69

rem netsh advfirewall firewall add rule name="Deny Adobe" dir=in interface=any action=block remoteip=192.150.16.211
rem netsh advfirewall firewall add rule name="Deny Adobe" dir=out interface=any action=block remoteip=192.150.16.211

rem mklink /H D:\server\www\live\pma.diepxuan.vn\config.inc.php D:\server\www\code\php\phpmyadmin\config.inc.php
