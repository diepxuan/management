"""Developer CLI helpers for launching agents in shpool sessions."""

import os
import sys
from pathlib import Path

from .registry import register_command


CODEX_PROFILE_NAME = "ninerouter"
DEFAULT_WORKSPACE_DIR = str(Path.home())
OPENCLAW_PROJECT_DIR = str(Path.home() / ".openclaw" / "workspace" / "projects")
HERMES_PROJECT_DIR = str(Path.home() / ".hermes" / "workspace" / "projects")


def _usage():
    """Print usage information."""
    msg = """Usage:
  ductncli [hermes|codex] [path]
  ductncli [path]                 # defaults to hermes
  ductncli                        # select agent, workspace defaults to ~/

Examples:
  ductncli hermes
  ductncli codex
  ductncli hermes ~/projects/portal
  ductncli codex projects/portal
  ductncli ductnd
  ductncli /root/.hermes/workspace/projects/ductnd

Workspace path resolution:
  - No path: use ~/
  - Absolute path: use it if the directory exists
  - Relative path: try ./path first, then ~/path
  - Project shortcut: try ~/.openclaw/workspace/projects/path, then ~/.hermes/workspace/projects/path
"""
    print(msg)


def _die(msg):
    """Print error and exit."""
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def _find_shpool():
    """Locate shpool binary.

    Prioritize bundled /usr/bin/shpool (from ductn package) over PATH
    to ensure consistent behavior regardless of user environment.
    """
    import shutil

    # 1) Bundled binary from package
    bundled = "/usr/bin/shpool"
    if os.path.isfile(bundled) and os.access(bundled, os.X_OK):
        return bundled

    # 2) Fallback to PATH (e.g. cargo install)
    path = shutil.which("shpool")
    if path:
        return path

    _die("shpool not found. Install it via 'ductn' package or 'cargo install shpool'.")


def _select_agent():
    """Interactive agent selection."""
    print("Select an agent:", file=sys.stderr)
    print("----------------------------------------", file=sys.stderr)
    print("1) hermes [default]", file=sys.stderr)
    print("2) codex", file=sys.stderr)
    print("0) Exit", file=sys.stderr)
    print("", file=sys.stderr)

    choice = input("Enter your choice [1]: ").strip() or "1"

    if choice in ("1", "h", "H", "hermes"):
        return "hermes"
    if choice in ("2", "c", "C", "codex"):
        return "codex"
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

        # 3) Project shortcut: openclaw first, then hermes
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
        checked.append(os.path.join(OPENCLAW_PROJECT_DIR, input_path))
        checked.append(os.path.join(HERMES_PROJECT_DIR, input_path))
    _die(f"Workspace directory not found: {input_path} (checked: {', '.join(checked)})")


def _workspace_session_slug(path):
    """Create a slug for the session name from workspace path."""
    home = str(Path.home())
    if path == home:
        return "home"

    slug = path.replace(home + "/", "").replace(home, "")
    slug = slug.lstrip("/")
    slug = slug.replace("/", "-")
    slug = "".join(c if c.isalnum() or c in "_-" else "_" for c in slug)
    return slug or "workspace"


def _confirm_start(agent, workspace_dir):
    """Confirm before starting."""
    try:
        confirm = input(f"Start {agent} in '{workspace_dir}'? (Y/n): ").strip() or "Y"
    except EOFError:
        confirm = "Y"
    if confirm.lower() != "y":
        print("Cancelled.")
        sys.exit(0)


def _ensure_shpool_daemon(shpool_bin):
    """Start shpool daemon if not running."""
    import subprocess
    try:
        subprocess.run([shpool_bin, "list"], check=True, capture_output=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Starting shpool daemon...")
        subprocess.run([shpool_bin, "daemon", "-d"], check=True, capture_output=True)
        import time
        time.sleep(1)


def _start_agent(agent, workspace_dir, session_name, shpool_bin):
    """Start the agent in a shpool session."""
    import subprocess

    if agent == "hermes":
        command_text = "hermes"
    elif agent == "codex":
        command_text = f"codex --profile {CODEX_PROFILE_NAME}"
    else:
        _die(f"Invalid agent: {agent}")

    print(f"Starting {agent}")
    print(f"Workspace: {workspace_dir}")
    if agent == "codex":
        print(f"Codex profile: {CODEX_PROFILE_NAME}")
    print(f"Session: {session_name}")

    os.execv(
        shpool_bin,
        [shpool_bin, "attach", "-c", command_text, "-d", workspace_dir, session_name],
    )


@register_command("cli")
def d_cli(args=None):
    """Launch Hermes/Codex workspace helper (shpool session manager).

    Ported from bash script to Python to avoid infinite loop:
    ductncli (bash wrapper) -> ductn cli (Python implementation)
    """
    if args is None:
        args = []

    # Parse arguments
    first = args[0] if len(args) > 0 else ""
    second = args[1] if len(args) > 1 else ""

    if first in ("-h", "--help", "help"):
        _usage()
        return 0

    if first in ("hermes", "codex"):
        agent = first
        path_input = second
        if len(args) > 2:
            _die("Too many arguments. Use: ductncli [hermes|codex] [path]")
    elif first == "":
        agent = _select_agent()
        path_input = ""
    else:
        agent = "hermes"
        path_input = first
        if second:
            _die("Too many arguments. Use: ductncli [hermes|codex] [path]")

    # Require agent command
    import shutil
    if not shutil.which(agent):
        _die(f"Required command not found: {agent}")

    # Resolve workspace
    workspace_dir = _resolve_workspace_dir(path_input)

    # Find shpool
    shpool_bin = _find_shpool()

    # Confirm
    _confirm_start(agent, workspace_dir)

    # Build session name and start
    slug = _workspace_session_slug(workspace_dir)
    session_name = f"{agent}-{slug}"

    _ensure_shpool_daemon(shpool_bin)
    _start_agent(agent, workspace_dir, session_name, shpool_bin)
    # _start_agent uses os.execv, so we never reach here
