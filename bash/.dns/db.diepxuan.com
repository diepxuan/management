$TTL    604800
diepxuan.com.   IN  SOA john.ns.cloudflare.com. maya.ns.cloudflare.com. 2035591342 7200 3600 86400 3600

;; A Records
diepxuan.com.   IN  A   104.154.132.183
diepxuan.com.   IN  A   125.212.237.119
dx1.diepxuan.com.   IN  A   104.154.132.183
dx3.diepxuan.com.   IN  A   125.212.237.119

;; CNAME Records
ad.diepxuan.com.    IN  CNAME   dx3.diepxuan.com.
cloud.diepxuan.com. IN  CNAME   dx1.diepxuan.com.
insider.diepxuan.com.   IN  CNAME   dx1.diepxuan.com.
luong.diepxuan.com. IN  CNAME   dx1.diepxuan.com.
ordinary.diepxuan.com.  IN  CNAME   dx1.diepxuan.com.
pma.diepxuan.com.   IN  CNAME   dx1.diepxuan.com.
server2.diepxuan.com.   IN  CNAME   dx1.diepxuan.com.
server.diepxuan.com.    IN  CNAME   dx3.diepxuan.com.
work.diepxuan.com.  IN  CNAME   dx1.diepxuan.com.
www.diepxuan.com.   IN  CNAME   diepxuan.com.

;; MX Records
diepxuan.com.   IN  MX  30 mx3.zoho.com.
diepxuan.com.   IN  MX  20 mx2.zoho.com.
diepxuan.com.   IN  MX  10 mx.zoho.com.

;; NS Records
  IN  NS  a.ns.hostvn.net.
  IN  NS  b.ns.hostvn.net.

;; TXT Records
diepxuan.com.   IN  TXT "v=spf1 include:zoho.com ~all"
