#!/usr/bin/env python3
import argparse
import argcomplete

import os
import sys
from . import register_command
from . import COMMANDS
from . import PACKAGE_NAME


@register_command
def d_commands():
    """Hiển thị danh sách command."""
    for key in COMMANDS.keys():
        print(key)
