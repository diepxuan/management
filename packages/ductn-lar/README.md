# ductn-lar

Debian source package độc lập, version `1.0.0+ppa~1`.

- Package: `ductn-lar`
- CLI: `lar`
- Chức năng: chuyển tiếp tới `ductn php:lar`.
- Runtime dependency: `ductn`.
- Migration: `Provides/Conflicts/Replaces: lar` để thay package cũ tên `lar`.

Build:

```bash
cd src
bash build.sh
```

`src/build.sh` build source chính và toàn bộ package độc lập trong một pipeline.
