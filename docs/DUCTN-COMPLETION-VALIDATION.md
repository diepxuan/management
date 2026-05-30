# ductn Bash Completion Validation

## Purpose

Use this checklist to validate ductn autocomplete in normal shells, terminal panes, installed packages, and development checkouts.

## Expected files

Installed package should provide:

```text
/usr/share/bash-completion/completions/ductn
```

Version 5.6.3 additionally expects a command cache:

```text
/usr/share/ductn/commands
```

The old compatibility file should not remain after upgrading from 5.6.2+:

```text
/etc/bash_completion.d/ductn-prompt
```

## Shell reload rule

Bash completion files are loaded by the current shell process. Existing terminal panes do not automatically reload files installed after the pane was opened.

For an existing pane, reload shell state:

```bash
exec bash
```

Or open a new terminal pane/session.

## Installed command validation

```bash
complete -p ductn
ls -l /usr/share/bash-completion/completions/ductn
ls -l /usr/share/ductn/commands
```

Expected:

```text
complete -F _ductn_completions ductn
/usr/share/bash-completion/completions/ductn exists
/usr/share/ductn/commands exists
```

Completion check:

```bash
ductn ap<TAB>
```

Expected candidates:

```text
apt:check
apt:fix
```

## Development checkout validation

From repository root:

```bash
complete -p ./ductn
./ductn ap<TAB>
```

Expected candidates:

```text
apt:check
apt:fix
```

## Cache validation

Show current cache path:

```bash
ductn completion:cache path
```

Show command list:

```bash
ductn completion:cache show
```

Refresh installed cache:

```bash
sudo ductn completion:cache refresh
```

Refresh temporary cache:

```bash
ductn completion:cache refresh /tmp/ductn-commands-test
```

## Session validation matrix

| Context | Command | Expected |
|---------|---------|----------|
| New login shell | `ductn ap<TAB>` | `apt:check`, `apt:fix` |
| New terminal pane | `ductn ap<TAB>` | `apt:check`, `apt:fix` |
| Existing pane after `exec bash` | `ductn ap<TAB>` | `apt:check`, `apt:fix` |
| Repo checkout | `./ductn ap<TAB>` | `apt:check`, `apt:fix` |

## Troubleshooting

### `apt` completes but `ductn` does not

Check whether bash-completion is loaded:

```bash
type _completion_loader
```

Check lazy-load file:

```bash
ls -l /usr/share/bash-completion/completions/ductn
```

Reload shell:

```bash
exec bash
```

### Old completion still appears

Check obsolete conffile:

```bash
ls -l /etc/bash_completion.d/ductn-prompt
```

It should be absent after upgrade cleanup.

### Completion is slow

Check whether cache exists:

```bash
ls -l /usr/share/ductn/commands
```

If missing, refresh it:

```bash
sudo ductn completion:cache refresh
```
