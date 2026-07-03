# ductn-m2

Debian source package độc lập, version `1.0.0+ppa~1`.

- Package: `ductn-m2`
- CLI: `m2`
- Chức năng: chuyển tiếp tới `ductn php:m2`.
- Runtime dependency: `ductn`.
- Migration: `Provides/Conflicts/Replaces: m2` để thay package cũ tên `m2`.

Build:

```bash
cd src
bash build.sh
```

`src/build.sh` build source chính và toàn bộ package độc lập trong một pipeline.
