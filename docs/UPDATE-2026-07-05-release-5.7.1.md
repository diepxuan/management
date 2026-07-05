# UPDATE-2026-07-05 — Release 5.7.1

## Mục đích

Release `5.7.1+ppa~1` cho thay đổi tách wrapper CLI khỏi source package chính `diepxuan`.

## Nội dung phát hành

- `ductn` giữ version `5.7.1+ppa~1`.
- `ductn-ll` được phát hành độc lập với version `1:1.0.0+ppa~1`.
- `ductn-m2` được phát hành độc lập với version `1.0.0+ppa~1`.
- `ductn-lar` được phát hành độc lập với version `1.0.0+ppa~1`.
- Package chuyển tiếp rỗng `m2` và `lar` vẫn nằm trong source chính để nâng cấp an toàn sang `ductn-m2` và `ductn-lar`.

## Ghi chú vận hành

Luồng build chính vẫn là:

```bash
cd src
bash build.sh
```

`src/build.sh` build source chính trước, sau đó build ba wrapper package dưới `packages/`, rồi gom artifact vào `dists/`.

## Validation

- `python3 -m unittest tests.unit.test_split_packages -v`
- `bash -n src/build.sh`
- `bash -n packages/ductn-ll/usr/bin/ll`
- `bash -n packages/ductn-m2/usr/bin/m2`
- `bash -n packages/ductn-lar/usr/bin/lar`

## Rủi ro

- `ductn-ll` dùng Debian epoch `1` để tránh apt xem `1.0.0` là downgrade từ chuỗi version `5.x` cũ.
- Nếu apt gặp conflict với package `m2` hoặc `lar` cũ, gỡ package cũ rồi cài lại `ductn-m2` hoặc `ductn-lar`.
