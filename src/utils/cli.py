"""Developer CLI helpers for launching agents in their workspace."""

import os
import shutil
import sys
from pathlib import Path
from typing import NoReturn

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


def _usage():
    """Print usage information."""
    msg = """Usage:
  ductncli [hermes|codex|openclaw] [path]
  ductncli [path]                 # defaults to hermes
  ductncli                        # select agent, workspace defaults to ~/

Examples:
  ductncli hermes
  ductncli codex
  ductncli openclaw
  ductncli hermes ~/projects/portal
  ductncli codex projects/portal
  ductncli openclaw portal
  ductncli ductnd
  ductncli /root/.hermes/workspace/projects/ductnd

Workspace path resolution:
  - No path: use ~/
  - Absolute path: use it if the directory exists
  - Relative path: try ./path first, then ~/path
  - Project shortcut: try /data/path, ~/.openclaw/workspace/projects/path, then ~/.hermes/workspace/projects/path
"""
    print(msg)


def _die(msg: str) -> NoReturn:
    """Print error and exit."""
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def _select_agent() -> str:
    """Interactive agent selection."""
    print("Select an agent:", file=sys.stderr)
    print("----------------------------------------", file=sys.stderr)
    print("1) hermes [default]", file=sys.stderr)
    print("2) codex", file=sys.stderr)
    print("3) openclaw", file=sys.stderr)
    print("0) Exit", file=sys.stderr)
    print("", file=sys.stderr)

    choice = input("Enter your choice [1]: ").strip() or "1"

    if choice in ("1", "h", "H", "hermes"):
        return "hermes"
    if choice in ("2", "c", "C", "codex"):
        return "codex"
    if choice in ("3", "o", "O", "openclaw"):
        return "openclaw"
    if choice in ("0", "q", "Q", "exit"):
        print("Exited.", file=sys.stderr)
        sys.exit(0)
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
    if agent == "hermes":
        agent_args = []
    elif agent == "codex":
        agent_args = ["--profile", CODEX_PROFILE_NAME]
    elif agent == "openclaw":
        agent_args = ["tui"]
    else:
        _die(f"Invalid agent: {agent}")

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
    os.environ["HERMES_TUI_THEME"] = "dark"

    print(f"Starting {agent} in {workspace_dir}")

    os.execv(argv[0], argv)


@register_command("cli")
def d_cli(args=None):
    """Launch Hermes/Codex/OpenClaw workspace helper.

    Resolves workspace directory, then starts the agent directly
    in that directory. No session manager (shpool/tmux) needed.
    """
    if args is None:
        args = []

    # Parse arguments
    first = args[0] if len(args) > 0 else ""
    second = args[1] if len(args) > 1 else ""

    if first in ("-h", "--help", "help"):
        _usage()
        return 0

    if first in ("hermes", "codex", "openclaw"):
        agent = first
        path_input = second
        if len(args) > 2:
            _die("Too many arguments. Use: ductncli [hermes|codex|openclaw] [path]")
    elif first == "":
        agent = _select_agent()
        path_input = ""
    else:
        agent = "hermes"
        path_input = first
        if second:
            _die("Too many arguments. Use: ductncli [hermes|codex|openclaw] [path]")

    # Require agent command
    if not _resolve_agent_binary(agent):
        _die(f"Required command not found: {agent}")

    # Resolve workspace
    workspace_dir = _resolve_workspace_dir(path_input)

    # Confirm
    _confirm_start(agent, workspace_dir)

    # Start agent directly in workspace directory
    _start_agent(agent, workspace_dir)
    # _start_agent uses os.execv, so we never reach here
