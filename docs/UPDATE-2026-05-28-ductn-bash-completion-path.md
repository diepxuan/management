# Update: ductn Bash Completion Lazy-load Path (2026-05-28)

## Summary

Move ductn bash completion packaging from the legacy compatibility directory to the standard bash-completion lazy-load path and harden the completion function for tmux/dev-wrapper usage.

## Packaging change

Completion file moved from:

```text
src/ductn/etc/bash_completion.d/ductn-prompt
```

to:

```text
src/ductn/usr/share/bash-completion/completions/ductn
```

Debian install mapping changed from:

```text
ductn/etc/bash_completion.d/ductn-prompt etc/bash_completion.d
```

to:

```text
ductn/usr/share/bash-completion/completions/ductn usr/share/bash-completion/completions
```

## Reason

Commands such as `apt` use bash-completion's lazy-load directory:

```text
/usr/share/bash-completion/completions/<command>
```

When bash-completion is loaded, the first `<TAB>` on `ductn` can load the `ductn` completion file by command name, matching the standard pattern used by system commands.

## Completion hardening

The completion function was also hardened for cases observed in tmux and development checkouts:

- guard missing `_get_comp_words_by_ref` helper;
- guard missing `__ltrim_colon_completions` helper;
- redirect stderr when calling `${COMP_WORDS[0]} commands`;
- fallback to an empty command list if command listing fails;
- quote completion variables;
- keep file/folder completion for command arguments;
- register development wrappers:

```bash
complete -F _ductn_completions ./ductn
complete -F _ductn_completions ./ductn.sh
complete -F _ductn_completions ./ductn.py
```

The installed command registrations remain:

```bash
complete -F _ductn_completions ductn
complete -F _ductn_completions ductn.sh
complete -F _ductn_completions ductn.py
```

## Manual validation after package install

Start a new shell or reload bash completion in tmux:

```bash
exec bash
```

Then check:

```bash
complete -p ductn
complete -p ./ductn
ls -l /usr/share/bash-completion/completions/ductn
ductn ap<TAB>
./ductn ap<TAB>
```

Expected completion candidates include:

```text
apt:check
apt:fix
```

If testing an old tmux pane, remember that existing pane state does not automatically reload newly installed completion files. Open a new pane/session or run `exec bash`.

## Remaining possible follow-up

If completion is still slow or unstable, the next improvement is to avoid running the Python CLI on every `<TAB>` by generating a command cache at package install time.
