# Update 2026-05-27 - Locale setup during package install

## Purpose

Package `ductn` now configures a UTF-8 locale during Debian `postinst` to avoid install-time/runtime warnings from tools that require a valid locale.

## Behavior

During `postinst configure`, the package runs locale setup before calling `ductn time:timezone` and before service setup.

Locale priority:

1. `C.UTF-8`
2. `en_US.UTF-8`

If `C.UTF-8` works, it is used directly. If not, `postinst` checks `en_US.UTF-8`. If `en_US.UTF-8` is missing and `locale-gen` is available, `postinst` enables/generates `en_US.UTF-8` and uses it as fallback.

The script exports:

```bash
LANG=<selected-locale>
LC_ALL=<selected-locale>
LANGUAGE=en_US:en
```

It also calls `update-locale` when available so later login/non-interactive sessions inherit the selected locale.

## Files changed

- `src/debian/postinst`
- `src/debian/control`
- `src/debian/changelog`
- `README.md`
- `TASKS.md`

## Dependencies

`ductn` now depends on `locales` so `locale-gen` and `update-locale` are available on Debian/Ubuntu systems.

## Validation

```bash
bash -n src/debian/postinst
bash -n src/build.sh
dpkg-parsechangelog -l src/debian/changelog -S Version
git diff --check
```

## Troubleshooting

If a host still shows locale warnings after install:

```bash
locale
locale -a | grep -E '^(C.UTF-8|en_US.utf8|en_US.UTF-8)$'
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=C.UTF-8 LC_ALL=C.UTF-8 LANGUAGE=en_US:en
```

`C.UTF-8` remains the preferred setting because it is lightweight and normally present without generation on modern Debian/Ubuntu.
