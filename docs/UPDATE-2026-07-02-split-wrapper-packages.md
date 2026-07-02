# Split wrapper packages

## Mục đích

Tách `ll`, `m2` và `lar` khỏi Debian source `diepxuan`. Trước thay đổi này, các wrapper không đổi nhưng vẫn nhận version của package chính, ví dụ `5.7.0`.

## Package mapping

| Debian source/package | CLI | Version ban đầu |
|---|---|---:|
| `ductn-ll` | `ll` | `1:1.0.0+ppa~1` |
| `ductn-m2` | `m2` | `1.0.0+ppa~1` |
| `ductn-lar` | `lar` | `1.0.0+ppa~1` |

`ductn-m2` và `ductn-lar` cung cấp `Provides/Conflicts/Replaces` cho package cũ `m2` và `lar`, giúp apt thay thế package cũ trong quá trình nâng cấp.

`ductn-ll` dùng epoch `1` vì cùng tên với package cũ version `5.7.0`; nếu không có epoch, apt sẽ coi `1.0.0` là downgrade. Source chính giữ package chuyển tiếp rỗng `m2` và `lar` version `5.7.1`, lần lượt phụ thuộc `ductn-m2` và `ductn-lar`.

## Cấu trúc

Mỗi source nằm tại `packages/<package>/` và có riêng:

- `debian/control`
- `debian/changelog`
- `debian/rules`
- `debian/install`
- `usr/bin/<cli>`
- `README.md`

## Build và publish

```bash
cd src
bash build.sh
```

`src/build.sh` là entrypoint duy nhất: build `ductn`, sau đó build lần lượt ba package wrapper và gom toàn bộ artifact vào `dists/`. Pull request/local chỉ build để validation; `dput` được chạy trên push `main`, release hoặc workflow dispatch.

Lỗi `dput` được giữ nguyên trên log và phát GitHub Actions warning theo từng package, nhưng không làm CI fail. Lỗi build hoặc thiếu `_source.changes` vẫn làm CI fail.

## Dependencies

- `ductn-ll`: shell và coreutils.
- `ductn-m2`: package `ductn`, chuyển tiếp tới `ductn php:m2`.
- `ductn-lar`: package `ductn`, chuyển tiếp tới `ductn php:lar`.

## Breaking changes

- Package binary `m2` đổi thành `ductn-m2`.
- Package binary `lar` đổi thành `ductn-lar`.
- Tên CLI `m2` và `lar` không đổi.
- Version hiển thị của `ductn-ll` có epoch Debian: `1:1.0.0+ppa~1`.

## Troubleshooting

- Nếu apt báo conflict, gỡ package cũ `m2`/`lar` rồi cài `ductn-m2`/`ductn-lar`.
- Nếu wrapper báo thiếu `ductn`, cài hoặc nâng cấp package `ductn`.
- Nếu Launchpad từ chối version, tăng changelog của đúng source package, không tăng version package khác.
