# Update: ductn Bash Completion Command Cache (2026-05-28)

## Summary

Add a build-time command list cache for ductn bash completion so pressing `<TAB>` does not need to start the ductn Python/PyInstaller CLI on every completion attempt.

## Files changed

```text
src/debian/rules
src/ductn/usr/share/bash-completion/completions/ductn
src/debian/changelog
TASKS.md
```

## Behavior

During package install/build, `src/debian/rules` now generates:

```text
/usr/share/ductn/commands
```

from:

```bash
./dist/ductn commands
```

The bash completion script now reads commands in this order:

1. For development/path wrappers such as `./ductn`, skip the installed cache and call the wrapper directly so autocomplete reflects the current checkout.
2. If `${DUCTN_COMMANDS_CACHE}` is set, read that cache path when present and readable.
3. For installed commands such as `ductn`, read `/usr/share/ductn/commands` when present and readable.
4. Fallback to `${COMP_WORDS[0]} commands 2>/dev/null` if the selected cache is missing.

## Reason

The old completion path called the ductn CLI every time the user pressed `<TAB>`:

```bash
${COMP_WORDS[0]} commands
```

That can be slow or unstable in tmux because it starts the full CLI runtime during shell completion. A static command cache avoids that startup cost for installed packages while preserving a fallback for development checkouts.

## Expected result

Installed package:

```text
<TAB> reads /usr/share/ductn/commands
```

Development checkout without installed cache:

```text
<TAB> falls back to ./ductn commands
```

## Manual validation

After installing the package:

```bash
ls -l /usr/share/ductn/commands
cat /usr/share/ductn/commands
exec bash
complete -p ductn
ductn ap<TAB>
```

Expected candidates include:

```text
apt:check
apt:fix
```

For development checkout fallback:

```bash
./ductn ap<TAB>
```

Expected candidates include:

```text
apt:check
apt:fix
```
