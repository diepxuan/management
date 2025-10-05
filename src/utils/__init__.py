import distro
from . import registry
from .registry import COMMANDS
from .registry import register_command

from rich.console import Console
from rich.table import Table

from . import host
from . import addr
from . import system_info
from . import vm
from . import about
from . import service
