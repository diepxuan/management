#!/usr/bin/env python3

import argparse
import sys
import os
import platform
import subprocess
import importlib.util
import argcomplete

from utils import *

# from utils.registry import COMMANDS

# 1. Biến toàn cục và xác định đường dẫn
EXEC_PREFIX = "d_"
PACKAGE_NAME = "ductn"
SERVICE_NAME = "ductnd"
SRC_DIR = os.path.dirname(os.path.realpath(__file__))


def main():
    args = parser.parse_args()
    args.func(args)

    return


if __name__ == "__main__":
    main()
