# Update: ductn Bash Completion Lazy-load Path (2026-05-28)

## Summary

Move ductn bash completion packaging from the legacy compatibility directory to the standard bash-completion lazy-load path.

## Change

The completion script content is intentionally unchanged for this task. Only the packaged source path and Debian install mapping changed:

```text
src/ductn/etc/bash_completion.d/ductn-prompt
-> src/ductn/usr/share/bash-completion/completions/ductn
```

Install mapping changed from:

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

## What was not changed

The shell completion function body was not modified. This lets us validate whether moving the file to the lazy-load path alone improves tmux behavior before changing completion logic.

Current script still registers:

```bash
complete -F _ductn_completions ductn
complete -F _ductn_completions ductn.sh
complete -F _ductn_completions ductn.py
```

It does not yet register `./ductn`.

## Manual validation after package install

Start a new shell or reload bash completion in tmux:

```bash
exec bash
```

Then check:

```bash
complete -p ductn
# expected: complete -F _ductn_completions ductn

ls -l /usr/share/bash-completion/completions/ductn
ductn ap<TAB>
```

If testing an old tmux pane, remember that existing pane state does not automatically reload newly installed completion files. Open a new pane/session or run `exec bash`.

## Next step if still unstable

If this path-only change is insufficient, create a follow-up task to modify completion logic itself:

- add `./ductn` registration for dev-wrapper usage;
- guard missing `_get_comp_words_by_ref` / `__ltrim_colon_completions` helpers;
- avoid running Python CLI on every `<TAB>` by using a command cache.
