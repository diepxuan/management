# Update: ductn completion cache maintenance command (2026-05-28)

## Summary

Add a `completion:cache` CLI command to inspect or refresh the ductn bash-completion command cache.

## Command

```bash
ductn completion:cache <show|refresh|path> [path]
```

## Actions

```text
show [path]      Print command cache content or generated command list.
refresh [path]   Regenerate command cache. Default: /usr/share/ductn/commands
path             Print default command cache path.
```

## Examples

Show generated command list or existing cache:

```bash
ductn completion:cache show
```

Show a custom cache file:

```bash
ductn completion:cache show /tmp/ductn-commands-test
```

Refresh installed cache:

```bash
sudo ductn completion:cache refresh
```

Refresh a temporary cache for validation:

```bash
ductn completion:cache refresh /tmp/ductn-commands-test
```

Print default cache path:

```bash
ductn completion:cache path
```

## Reason

Package build creates `/usr/share/ductn/commands`, but an operator may need to inspect or regenerate the cache while debugging an installed system. This command provides that operational hook without requiring manual knowledge of Python internals.

## Validation

```bash
python3 -m unittest tests.unit.test_completion tests.unit.test_modules tests.unit.test_registry -v
python3 -m compileall src/utils src/ductn.py
./ductn completion:cache show
./ductn completion:cache refresh /tmp/ductn-commands-test
```
