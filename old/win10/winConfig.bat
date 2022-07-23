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

rem netsh advfirewall firewall add rule name="apps.skype.com" dir=in interface=any action=block remoteip=2.23.109.81
rem netsh advfirewall firewall add rule name="apps.skype.com" dir=out interface=any action=block remoteip=2.23.109.81

rem mklink /H D:\server\www\live\pma.diepxuan.vn\config.inc.php D:\server\www\code\php\phpmyadmin\config.inc.php


rem clear key
slmgr -upk
slmgr /ckms

rem win 10
rem 1. slmgr /ipk PW48G-MNG8W-B9978-YWBRP-76DGY
rem 1.1 KWWVF-VNVFM-HTVTP-YP824-WFDHC
rem 1.2 T6R8N-X9P9Q-K9W99-7G7KQ-B9492

rem 2.
rem slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
rem 2.2 VK7JG-NPHTM-C97JM-9MPGT-3V66T

rem winserver 2016
slmgr /ipk WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY
rem slmgr /ipk N4698-DX2CQ-PDTDG-CHB6B-8FHXR
rem slmgr /ipk 623H6-N2399-P9J4X-MPD8T-V6D9R

rem vs 2017 Enterprise
rem NJVYC-BMHX2-G77MM-4XJMR-6Q8QF

rem vs 2017 Pro
rem KBJFW-NXHK6-W4WJM-CRMQB-G3CDH
rem HMGNV-WCYXV-X7G9W-YCX63-B98R2

rem slmgr /skms kms.digiboy.ir
slmgr /skms kms.lotro.cc

slmgr /ato

rem valid
slmgr -xpr
