import distro

from rich.console import Console
from rich.table import Table

from . import host as dHost
from . import ip as dIp
from . import system_info as dOs
from . import vm
from . import registry
from . import about
from .registry import COMMANDS
