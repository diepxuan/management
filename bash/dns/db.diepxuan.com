;;
;; Domain:     diepxuan.com.
;; Exported:   2020-11-01 16:07:01
;;
;; This file is intended for use for informational and archival
;; purposes ONLY and MUST be edited before use on a production
;; DNS server.  In particular, you must:
;;   -- update the SOA record with the correct authoritative name server
;;   -- update the SOA record with the contact e-mail address information
;;   -- update the NS record(s) with the authoritative name servers for this domain.
;;
;; For further information, please consult the BIND documentation
;; located on the following website:
;;
;; http://www.isc.org/
;;
;; And RFC 1035:
;;
;; http://www.ietf.org/rfc/rfc1035.txt
;;
;; Please note that we do NOT offer technical support for any use
;; of this zone data, the BIND name server, or any other third-party
;; DNS software.
;;
;; Use at your own risk.
;; SOA Record
diepxuan.com.   3600    IN  SOA diepxuan.com. root.diepxuan.com. 2035591342 7200 3600 86400 3600

;; A Records
diepxuan.com.   1   IN  A   35.232.100.140
diepxuan.com.   1   IN  A   125.212.237.119
dx1.diepxuan.com.   1   IN  A   35.232.100.140
dx3.diepxuan.com.   1   IN  A   125.212.237.119

;; CNAME Records
ad.diepxuan.com.    1   IN  CNAME   dx3.diepxuan.com.
cloud.diepxuan.com. 1   IN  CNAME   dx1.diepxuan.com.
insider.diepxuan.com.   1   IN  CNAME   dx1.diepxuan.com.
luong.diepxuan.com. 1   IN  CNAME   dx1.diepxuan.com.
ordinary.diepxuan.com.  1   IN  CNAME   dx1.diepxuan.com.
pma.diepxuan.com.   1   IN  CNAME   dx1.diepxuan.com.
server2.diepxuan.com.   1   IN  CNAME   dx1.diepxuan.com.
server.diepxuan.com.    1   IN  CNAME   dx3.diepxuan.com.
work.diepxuan.com.  1   IN  CNAME   dx1.diepxuan.com.
www.diepxuan.com.   1   IN  CNAME   diepxuan.com.

;; MX Records
diepxuan.com.   1   IN  MX  30 mx3.zoho.com.
diepxuan.com.   1   IN  MX  20 mx2.zoho.com.
diepxuan.com.   1   IN  MX  10 mx.zoho.com.

;; NS Records
a.ns.diepxuan.com.  1   IN  NS  a.ns.hostvn.net.
b.ns.diepxuan.com.  1   IN  NS  b.ns.hostvn.net.

;; TXT Records
diepxuan.com.   1   IN  TXT "v=spf1 include:zoho.com ~all"
