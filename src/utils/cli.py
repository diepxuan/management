"""Developer CLI helpers for launching agents in their workspace."""

import os
import re
import shutil
import sys
from pathlib import Path
from typing import Iterable, NoReturn

from .registry import register_command


DEFAULT_WORKSPACE_DIR = str(Path.home())
OPENCLAW_PROJECT_DIR = str(Path.home() / ".openclaw" / "workspace" / "projects")
HERMES_PROJECT_DIR = str(Path.home() / ".hermes" / "workspace" / "projects")
DATA_PROJECT_DIR = "/data"

CODEX_PROFILE_NAME = "ninerouter"

AGENT_BIN_DIRS = [
    ".local/share/pnpm",
    ".local/share/pnpm/bin",
    ".npm-global/bin",
    ".local/bin",
]
SYSTEM_BIN_DIRS = [
    "/usr/local/bin",
    "/usr/bin",
    "/opt/homebrew/bin",
    "/home/linuxbrew/.linuxbrew/bin",
]

# Default AI-agent CLI registry used by `ductncli`.
# Each entry: (name, args, description).
# Only entries whose binary resolves via `_resolve_agent_binary` are
# advertised in the interactive menu and autocomplete.
AGENTS_DEFAULT = [
    ("hermes",   [],            "Hermes CLI"),
    ("codex",    ["--profile", CODEX_PROFILE_NAME], "Codex with ninerouter profile"),
    ("openclaw", ["tui"],       "OpenClaw TUI"),
    ("freebuff", [],            "Freebuff"),
    ("claude",   [],            "Anthropic Claude CLI"),
    ("gemini",   [],            "Google Gemini CLI"),
    ("aider",    [],            "Aider coding assistant"),
    ("llm",      [],            "Simon Willison's llm CLI"),
    ("aichat",   [],            "aichat"),
    ("cursor",   [],            "Cursor IDE launcher"),
    ("windsurf", [],            "Windsurf IDE launcher"),
    ("continue", [],            "Continue"),
    ("goose",    [],            "Goose"),
    ("qwen",     [],            "Qwen CLI"),
    ("chatgpt",  [],            "ChatGPT CLI"),
    ("sgpt",     [],            "Shell GPT"),
    ("mod",      [],            "mod"),
]

DEFAULT_CONFIG_PATH = Path.home() / ".config" / "ductn" / "config.yml"

# Agents written to a freshly-created default `config.yml`. Users can edit
# the file to add or remove entries without touching ductn's source.
DEFAULT_CONFIG_AGENT_NAMES = ("codex", "openclaw", "hermes", "freebuff")
DEFAULT_CONFIG_HEADER = """# ductn cli agent registry
# Edit this file to add, remove, or tune agents used by `ductncli`.
# Only agents whose binary resolves on PATH (or in pnpm/npm/apt/Homebrew
# fallback dirs) are shown in the interactive menu; the rest are hidden.
# Override precedence (low -> high): in-code defaults < this file < env vars
# (DuctnCLI_AGENT_ARGS_<NAME>).
#
# Per-entry schema:
#   name:        CLI binary name (required)
#   args:        list of arguments passed to the binary (optional)
#   description: short text shown next to the agent (optional)
#   enabled:     set to false to hide the agent from menu/autocomplete (optional)
#
# Example additions:
#   - name: claude
#     description: Anthropic Claude CLI
#   - name: aider
#     args: ["--model", "sonnet"]
# See docs/UPDATE-2026-07-20-ductncli-extend.md for the full schema.

agents:
"""

_HERMES_TUI_THEME_KEY = "HERMES_TUI_THEME"
_HERMES_TUI_THEME_DARK = "dark"


def _usage(available_agents=None):
    """Print usage information."""
    agents_line = " ".join(available_agents) if available_agents else "hermes|codex|openclaw|..."
    msg = f"""Usage:
  ductncli [{agents_line}] [path]
  ductncli [path]                 # defaults to the first available agent
  ductncli                        # select agent, workspace defaults to ~/

Examples:
  ductncli hermes
  ductncli codex
  ductncli openclaw
  ductncli freebuff
  ductncli claude projects/portal
  ductncli /root/.hermes/workspace/projects/ductnd

Configuration:
  Default agent registry lives in this module; override it via:
    $XDG_CONFIG_HOME/ductn/config.yml  (fallback: ~/.config/ductn/config.yml)
  See docs/UPDATE-2026-07-20-ductncli-extend.md for the schema.

Workspace path resolution:
  - No path: use ~/
  - Absolute path: use it if the directory exists
  - Relative path: try ./path first, then ~/path
  - Project shortcut: try /data/path, ~/.openclaw/workspace/projects/path, then ~/.hermes/workspace/projects/path

Notes:
  - Agents whose binary is not installed on PATH or in the standard
    pnpm/npm/apt/Homebrew fallback directories are hidden from the
    interactive menu and rejected when supplied as an argument.
"""
    print(msg)


def _die(msg: str) -> NoReturn:
    """Print error and exit."""
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


# ---------------------------------------------------------------------------
# YAML config loader (vendored, no PyYAML dependency)
# ---------------------------------------------------------------------------

def _strip_yaml_comment(line: str) -> str:
    """Strip a YAML `#` comment while respecting quoted strings."""
    in_single = False
    in_double = False
    for idx, ch in enumerate(line):
        if ch == "'" and not in_double:
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
        elif ch == "#" and not in_single and not in_double:
            return line[:idx].rstrip()
    return line.rstrip()


def _split_flow_top_level(text: str, sep: str = ",") -> list:
    """Split a flow-style sequence/mapping body into ``sep``-separated parts
    while respecting quoted strings and nested brackets.
    """
    parts = []
    buf: list = []
    depth_sq = depth_cu = 0
    in_single = in_double = False
    for ch in text:
        if ch == "'" and not in_double:
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
        elif not in_single and not in_double:
            if ch == "[":
                depth_sq += 1
            elif ch == "]":
                depth_sq -= 1
            elif ch == "{":
                depth_cu += 1
            elif ch == "}":
                depth_cu -= 1
            elif ch == sep and depth_sq == 0 and depth_cu == 0:
                parts.append("".join(buf))
                buf = []
                continue
        buf.append(ch)
    tail = "".join(buf).strip()
    if tail:
        parts.append(tail)
    return parts


def _parse_flow_value(text: str):
    """Parse a YAML flow-style scalar / sequence value.

    Supports:
      - quoted strings: ``"foo bar"`` / ``'foo bar'``
      - booleans / ints / floats / null
      - inline list: ``[a, b, "c d"]``
      - inline map: ``{a: 1, b: two}``
    """
    text = text.strip()
    if text == "":
        return ""
    if text.startswith("[") and text.endswith("]"):
        body = text[1:-1]
        if body.strip() == "":
            return []
        return [_parse_flow_value(item) for item in _split_flow_top_level(body)]
    if text.startswith("{") and text.endswith("}"):
        body = text[1:-1]
        result: dict = {}
        for pair in _split_flow_top_level(body):
            if ":" not in pair:
                continue
            k, _, v = pair.partition(":")
            result[k.strip()] = _parse_flow_value(v)
        return result
    # Plain scalar.
    return _parse_scalar(text)


def _parse_scalar(value: str):
    """Parse a YAML scalar into its native Python type."""
    text = value.strip()
    if not text:
        return ""
    # Quoted string: keep content as-is.
    if (text.startswith('"') and text.endswith('"')) or (text.startswith("'") and text.endswith("'")):
        return text[1:-1]
    lower = text.lower()
    if lower in ("true", "yes", "on"):
        return True
    if lower in ("false", "no", "off"):
        return False
    if lower in ("null", "~", ""):
        return None
    # Integer / float literal.
    if re.fullmatch(r"-?\d+", text):
        return int(text)
    if re.fullmatch(r"-?\d+\.\d+", text):
        return float(text)
    return text


def _yaml_indent(line: str) -> int:
    """Return the indentation width of `line` (number of leading spaces)."""
    return len(line) - len(line.lstrip(" "))


def _load_yaml_config(path: Path) -> dict:
    """Very small YAML subset reader focused on the ductncli schema.

    Supports only the schema documented in
    ``docs/UPDATE-2026-07-20-ductncli-extend.md``::

        top-level-key: scalar
        agents:
          - name: <str>
            args:
              - <str>
            description: <str>
            enabled: <bool>

    Anchors, multi-doc streams, flow style, and tags are intentionally not
    supported to avoid a PyYAML dependency.
    """
    if not path.is_file():
        return {}

    raw_lines = path.read_text(encoding="utf-8").splitlines()

    # Pre-process: strip comments, drop blank lines.
    lines = [_strip_yaml_comment(raw) for raw in raw_lines]
    lines = [ln for ln in lines if ln.strip() != ""]

    def parse_scalar_block(start_idx: int, parent_indent: int) -> tuple[object, int]:
        """Parse a scalar value or an empty block at ``start_idx``."""
        line = lines[start_idx]
        _, _, rest = line.partition(":")
        rest = rest.strip()
        if rest:
            return _parse_scalar(rest), start_idx + 1
        # Find first non-blank child line.
        j = start_idx + 1
        while j < len(lines) and lines[j].strip() == "":
            j += 1
        if j >= len(lines):
            return "", start_idx + 1
        child_indent = _yaml_indent(lines[j])
        if child_indent <= parent_indent:
            return "", start_idx + 1
        # Decide between list and map by leading "-".
        if lines[j].lstrip().startswith("- "):
            value, end_idx = parse_list_block(j, child_indent)
            return value, end_idx
        value, end_idx = parse_map_block(j, child_indent)
        return value, end_idx

    def parse_list_block(start_idx: int, list_indent: int) -> tuple[list, int]:
        items: list = []
        j = start_idx
        n = len(lines)
        while j < n:
            cur = lines[j]
            cur_indent = _yaml_indent(cur)
            if cur_indent < list_indent:
                break
            if cur_indent > list_indent:
                # Stray indented line — skip (defensive).
                j += 1
                continue
            stripped = cur.lstrip()
            if not stripped.startswith("- "):
                # Same indent but not a list item — done.
                break
            # New list item.
            rest = stripped[2:]
            item: dict | object
            if ":" in rest:
                # First field is a mapping entry. Build the mapping.
                item = {}
                k, _, v = rest.partition(":")
                item[k.strip()] = _parse_flow_value(v.strip()) if v.strip() else ("", j + 1)[1]
                j += 1
                # Read subsequent mapping fields at list_indent + 2.
                cont_indent = list_indent + 2
                while j < n:
                    next_line = lines[j]
                    if next_line.strip() == "":
                        j += 1
                        continue
                    next_indent = _yaml_indent(next_line)
                    if next_indent < cont_indent:
                        break
                    if next_indent == list_indent and next_line.lstrip().startswith("- "):
                        break
                    stripped_next = next_line.lstrip()
                    if ":" in stripped_next and not stripped_next.startswith("- "):
                        nk, _, nv = stripped_next.partition(":")
                        nk = nk.strip()
                        nv = nv.strip()
                        if nv:
                            item[nk] = _parse_flow_value(nv)
                            j += 1
                        else:
                            value, end_idx = parse_scalar_block(j, next_indent)
                            item[nk] = value
                            j = end_idx
                    else:
                        j += 1
            else:
                # Plain scalar list item.
                item = _parse_scalar(rest.strip())
                j += 1
            items.append(item)
        return items, j

    def parse_map_block(start_idx: int, map_indent: int) -> tuple[dict, int]:
        result: dict = {}
        j = start_idx
        n = len(lines)
        while j < n:
            line = lines[j]
            cur_indent = _yaml_indent(line)
            if cur_indent < map_indent:
                break
            if cur_indent > map_indent:
                j += 1
                continue
            stripped = line.lstrip()
            if stripped.startswith("- "):
                # Next list sibling — stop reading mapping.
                break
            if ":" not in stripped:
                j += 1
                continue
            k, _, v = stripped.partition(":")
            k = k.strip()
            v = v.strip()
            if v:
                result[k] = _parse_scalar(v)
                j += 1
            else:
                value, end_idx = parse_scalar_block(j, cur_indent)
                result[k] = value
                j = end_idx
        return result, j

    # Parse top-level: only entries at indent 0.
    top: dict = {}
    j = 0
    n = len(lines)
    while j < n:
        line = lines[j]
        if _yaml_indent(line) != 0:
            j += 1
            continue
        stripped = line.lstrip()
        if ":" not in stripped:
            j += 1
            continue
        k, _, v = stripped.partition(":")
        k = k.strip()
        v = v.strip()
        if v:
            top[k] = _parse_flow_value(v)
            j += 1
        else:
            value, end_idx = parse_scalar_block(j, 0)
            top[k] = value
            j = end_idx

    return top


# ---------------------------------------------------------------------------
# Agent registry: defaults + config override + env override
# ---------------------------------------------------------------------------

def _coerce_argv(value) -> list:
    """Coerce a YAML/env value into a list of CLI argument strings."""
    if value is None:
        return []
    if isinstance(value, list):
        return [str(v) for v in value]
    if isinstance(value, str):
        return value.split()
    return [str(value)]


def _env_override_args(name: str) -> list | None:
    """Return override args from env var, or None if not set.

    Env var: ``DuctnCLI_AGENT_ARGS_<NAME>`` (uppercased, hyphens -> underscores).
    Whitespace-separated tokens. Empty string = explicit no args.
    """
    key = "DuctnCLI_AGENT_ARGS_" + re.sub(r"[^A-Za-z0-9]+", "_", name).upper().strip("_")
    if key not in os.environ:
        return None
    return os.environ[key].split()


def _resolve_agents(config: dict | None = None) -> list:
    """Return the merged agent registry as a list of dict entries.

    Each entry has keys: ``name`` (str), ``args`` (list[str]),
    ``description`` (str), ``enabled`` (bool).

    Override layers (lowest -> highest priority):
      1. ``AGENTS_DEFAULT`` (in-code defaults)
      2. ``config['agents']`` list (YAML user file)
      3. ``DuctnCLI_AGENT_ARGS_<NAME>`` environment variable
    """
    base = [
        {"name": name, "args": list(args), "description": desc, "enabled": True}
        for (name, args, desc) in AGENTS_DEFAULT
    ]

    merged: dict = {entry["name"]: entry for entry in base}

    cfg_agents = []
    if config and isinstance(config.get("agents"), list):
        cfg_agents = config["agents"]

    # Apply config layer: add new, override existing, disable via enabled=false.
    for raw in cfg_agents:
        if not isinstance(raw, dict):
            continue
        name = raw.get("name")
        if not isinstance(name, str) or not name:
            continue
        existing = merged.get(name, {"name": name, "args": [], "description": name, "enabled": True})
        if "args" in raw:
            existing["args"] = _coerce_argv(raw.get("args"))
        if "description" in raw and isinstance(raw.get("description"), str):
            existing["description"] = raw["description"]
        if "enabled" in raw:
            existing["enabled"] = bool(raw.get("enabled"))
        merged[name] = existing

    # Environment variable layer.
    for name in list(merged.keys()):
        override = _env_override_args(name)
        if override is not None:
            merged[name]["args"] = override

    # Stable order: keep insertion order of defaults, then any new ones from config.
    ordered: list = []
    seen = set()
    for entry in base:
        if entry["name"] not in seen:
            ordered.append(merged[entry["name"]])
            seen.add(entry["name"])
    for name in merged:
        if name not in seen:
            ordered.append(merged[name])
            seen.add(name)
    return ordered


def _load_config(path: Path | None = None) -> dict:
    """Load the user config file (if present) and return its dictionary."""
    xdg = os.environ.get("XDG_CONFIG_HOME")
    if path is None:
        if xdg:
            path = Path(xdg) / "ductn" / "config.yml"
        else:
            path = DEFAULT_CONFIG_PATH
    try:
        return _load_yaml_config(Path(path)) or {}
    except OSError:
        return {}


def _render_default_config_yaml() -> str:
    """Render the canned `config.yml` body for a first-time install.

    The content only includes entries the user is most likely to need.
    Additional defaults from `AGENTS_DEFAULT` (claude, gemini, aider, ...)
    remain discoverable when their binaries get installed later.
    """
    lookup = {
        name: {"args": list(args), "description": desc}
        for (name, args, desc) in AGENTS_DEFAULT
    }
    lines = [DEFAULT_CONFIG_HEADER.rstrip("\n")]
    for name in DEFAULT_CONFIG_AGENT_NAMES:
        entry = lookup.get(name)
        if entry is None:
            continue
        lines.append(f"  - name: {name}")
        if entry["args"]:
            quoted = ", ".join(f'"{arg}"' for arg in entry["args"])
            lines.append(f"    args: [{quoted}]")
        if entry["description"]:
            desc = entry["description"].replace('"', '\\"')
            lines.append(f'    description: "{desc}"')
        lines.append("")
    return "\n".join(lines) + "\n"


def _ensure_default_config(path: Path | None = None) -> tuple[Path, bool]:
    """Create the default ``config.yml`` if it does not yet exist.

    Returns ``(path, created)`` where ``created`` is True when a new file was
    written. Skipped (returns ``(path, False)``) when:

      * the file already exists,
      * filesystem access fails (no perms / read-only filesystem).
    """
    xdg = os.environ.get("XDG_CONFIG_HOME")
    if path is None:
        target = (
            Path(xdg) / "ductn" / "config.yml"
            if xdg else DEFAULT_CONFIG_PATH
        )
    else:
        target = Path(path)

    try:
        if target.exists():
            return target, False
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(_render_default_config_yaml(), encoding="utf-8")
        return target, True
    except OSError:
        return target, False


def _available_agent_entries() -> list:
    """Return the merged registry filtered to entries whose binary resolves."""
    config = _load_config()
    entries = _resolve_agents(config)
    return [e for e in entries if e.get("enabled", True) and _resolve_agent_binary(e["name"])]


def _available_agent_names() -> list:
    """Return the names of agents that are both enabled and installed."""
    return [e["name"] for e in _available_agent_entries()]


def _find_agent(name: str):
    """Look up an entry by name in the merged registry (regardless of install state)."""
    config = _load_config()
    for entry in _resolve_agents(config):
        if entry["name"] == name:
            return entry
    return None


def _select_agent() -> str:
    """Interactive agent selection — only lists agents that are installed."""
    available = _available_agent_entries()
    if not available:
        _die("No supported AI agent CLI is installed on this system.")

    print("Select an agent:", file=sys.stderr)
    print("----------------------------------------", file=sys.stderr)
    default_name = available[0]["name"]
    for idx, entry in enumerate(available, start=1):
        marker = " [default]" if entry["name"] == default_name else ""
        print(f"{idx}) {entry['name']}{marker}", file=sys.stderr)
    print("0) Exit", file=sys.stderr)
    print("", file=sys.stderr)

    prompt = f"Enter your choice [1]: "
    choice = input(prompt).strip() or "1"

    if choice in ("0", "q", "Q", "exit"):
        print("Exited.", file=sys.stderr)
        sys.exit(0)

    # Numeric selection: only valid against the dynamically built menu.
    if choice.isdigit():
        n = int(choice)
        if 1 <= n <= len(available):
            return available[n - 1]["name"]

    # Accept textual short codes (first letter / full name) for backwards compat.
    for entry in available:
        if choice == entry["name"]:
            return entry["name"]
        if choice and choice.lower() == entry["name"][0].lower():
            return entry["name"]

    _die("Invalid agent choice.")


def _expand_tilde(input_path):
    """Expand ~ and ~/prefix to $HOME."""
    home = str(Path.home())
    if input_path == "~":
        return home
    if input_path.startswith("~/"):
        return os.path.join(home, input_path[2:])
    return input_path


def _agent_binary_candidates(command: str):
    """Return common pnpm, npm, apt and Homebrew binary locations."""
    home = str(Path.home())
    user_candidates = [os.path.join(home, directory, command) for directory in AGENT_BIN_DIRS]
    system_candidates = [os.path.join(directory, command) for directory in SYSTEM_BIN_DIRS]
    return user_candidates + system_candidates


def _resolve_agent_binary(command: str):
    """Resolve an agent executable and return its canonical real path."""
    path_bin = shutil.which(command)
    if path_bin:
        return os.path.realpath(path_bin)

    for candidate in _agent_binary_candidates(command):
        if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
            return os.path.realpath(candidate)

    return None


def _resolve_workspace_dir(input_path=""):
    """Resolve workspace directory from user input."""
    if not input_path:
        return DEFAULT_WORKSPACE_DIR

    expanded = _expand_tilde(input_path)

    # 1) Direct path exists
    if os.path.isdir(expanded):
        return str(Path(expanded).resolve())

    # 2) Relative path under ~/
    if not os.path.isabs(expanded):
        relative_home = str(Path.home() / expanded)
        if os.path.isdir(relative_home):
            return str(Path(relative_home).resolve())

        # 3) Project shortcut under /data
        data_project = os.path.join(DATA_PROJECT_DIR, expanded)
        if os.path.isdir(data_project):
            return str(Path(data_project).resolve())

        # 4) Agent project shortcuts: openclaw first, then hermes
        openclaw_project = os.path.join(OPENCLAW_PROJECT_DIR, expanded)
        if os.path.isdir(openclaw_project):
            return str(Path(openclaw_project).resolve())

        hermes_project = os.path.join(HERMES_PROJECT_DIR, expanded)
        if os.path.isdir(hermes_project):
            return str(Path(hermes_project).resolve())

    # Build error message with all checked paths
    checked = [expanded]
    if not os.path.isabs(input_path):
        checked.append(str(Path.home() / input_path))
        checked.append(os.path.join(DATA_PROJECT_DIR, input_path))
        checked.append(os.path.join(OPENCLAW_PROJECT_DIR, input_path))
        checked.append(os.path.join(HERMES_PROJECT_DIR, input_path))
    _die(f"Workspace directory not found: {input_path} (checked: {', '.join(checked)})")


def _confirm_start(agent, workspace_dir):
    """Confirm before starting."""
    try:
        confirm = input(f"Start {agent} in '{workspace_dir}'? (Y/n): ").strip() or "Y"
    except EOFError:
        confirm = "Y"
    if confirm.lower() != "y":
        print("Cancelled.")
        sys.exit(0)


def _start_agent(agent: str, workspace_dir: str):
    """Start the agent in the workspace directory."""
    entry = _find_agent(agent)
    if entry is None:
        _die(f"Invalid agent: {agent}")
    agent_args = list(entry.get("args") or [])

    agent_bin = _resolve_agent_binary(agent)
    if not agent_bin:
        _die(f"Required command not found: {agent}")

    argv = [agent_bin] + agent_args

    # Change to workspace directory before exec
    os.chdir(workspace_dir)

    # Restore stdin from /dev/tty before execv.
    # input() in _confirm_start can alter terminal attributes; reopening
    # /dev/tty ensures the agent receives a clean TTY for interactive mode.
    try:
        tty_fd = os.open("/dev/tty", os.O_RDWR)
        os.dup2(tty_fd, 0)
        os.dup2(tty_fd, 1)
        os.dup2(tty_fd, 2)
        os.close(tty_fd)
    except OSError:
        pass  # /dev/tty not available (e.g. non-interactive env)

    # Skip OSC 11 background color query in Hermes TUI.
    # Without this, Hermes sends \x1b]11;?\x1b\\ to query terminal BG color,
    # but the escape is consumed by the wrapper, leaving "]11;rgb:..." leaking
    # into the agent's stdin and corrupting the first prompt.
    os.environ[_HERMES_TUI_THEME_KEY] = _HERMES_TUI_THEME_DARK

    print(f"Starting {agent} in {workspace_dir}")

    os.execv(argv[0], argv)


@register_command("cli")
def d_cli(args=None):
    """Launch AI agent CLI (Codex/OpenClaw/Hermes/...) in a workspace.

    The agent registry is built from the in-code defaults merged with
    ``~/.config/ductn/config.yml`` (``$XDG_CONFIG_HOME/ductn/config.yml``)
    and optional ``DuctnCLI_AGENT_ARGS_<NAME>`` environment overrides.

    Agents whose binary is not installed on PATH or in the standard
    pnpm/npm/apt/Homebrew fallback directories are hidden from the
    interactive menu and rejected when supplied as an argument.

    Usage::

        ductncli [agent] [path]
        ductncli [path]                 # defaults to the first available agent
        ductncli                        # interactive menu
    """
    if args is None:
        args = []

    # Ensure default user config exists on first run (no-op when already
    # present).
    cfg_path, created = _ensure_default_config()
    if created:
        print(f"Created default agent config: {cfg_path}", file=sys.stderr)

    # Parse arguments
    first = args[0] if len(args) > 0 else ""
    second = args[1] if len(args) > 1 else ""

    if first in ("-h", "--help", "help"):
        _usage()
        return 0

    if first == "":
        agent = _select_agent()
        path_input = ""
    else:
        agent = first
        path_input = second
        if len(args) > 2:
            _die("Too many arguments. Use: ductncli [agent] [path]")

    # Reject unknown agents before resolving anything.
    entry = _find_agent(agent)
    if entry is None:
        if not _available_agent_names():
            _die("No supported AI agent CLI is installed on this system.")
        known = ", ".join(_available_agent_names())
        _die(f"Unknown agent: {agent}. Available: {known}")

    # Require the binary to actually resolve.
    if not _resolve_agent_binary(agent):
        _die(f"Required command not found: {agent}")

    # Resolve workspace
    workspace_dir = _resolve_workspace_dir(path_input)

    # Confirm
    _confirm_start(agent, workspace_dir)

    # Start agent directly in workspace directory
    _start_agent(agent, workspace_dir)
    # _start_agent uses os.execv, so we never reach here


# ---------------------------------------------------------------------------
# Exposed helpers for tests & external callers
# ---------------------------------------------------------------------------

def list_default_agent_names() -> Iterable[str]:
    """Yield the names from the in-code default registry."""
    for name, _args, _desc in AGENTS_DEFAULT:
        yield name
