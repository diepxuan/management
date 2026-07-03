# ductn-ll

Debian source package độc lập, upstream version `1.0.0`.

- Package: `ductn-ll`
- Debian version: `1:1.0.0+ppa~1` (epoch `1` để nâng cấp từ dòng version chung `5.x`).
- CLI: `ll`
- Chức năng: gọi `ls -lah` với nguyên danh sách đối số.
- Runtime dependencies: không có ngoài shell/coreutils của hệ thống.

Build:

```bash
cd src
bash build.sh
```

`src/build.sh` build source chính và toàn bộ package độc lập trong một pipeline.
