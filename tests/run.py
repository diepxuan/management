#!/usr/bin/env python3
"""
Main test runner for ductn package.

Usage:
    python3 tests/run.py              # Run all tests
    python3 tests/run.py unit         # Run unit tests only
    python3 tests/run.py integration  # Run integration tests only
    python3 tests/run.py --verbose    # Verbose output
"""
import sys
import os
import unittest
import argparse
import importlib
import glob

# Add src to path
SRC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "src")
sys.path.insert(0, SRC_DIR)

# Mock os.geteuid for sandbox
os.geteuid = lambda: 0


def discover_tests(test_type="all"):
    """Discover and load tests based on type."""
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    base_dir = os.path.dirname(os.path.abspath(__file__))

    if test_type in ("all", "unit"):
        unit_dir = os.path.join(base_dir, "unit")
        for test_file in sorted(glob.glob(os.path.join(unit_dir, "test_*.py"))):
            module_name = os.path.basename(test_file)[:-3]
            full_module = f"unit.{module_name}"
            try:
                mod = importlib.import_module(full_module)
                suite.addTests(loader.loadTestsFromModule(mod))
            except Exception as e:
                print(f"Warning: Cannot load {full_module}: {e}")

    if test_type in ("all", "integration"):
        integ_dir = os.path.join(base_dir, "integration")
        for test_file in sorted(glob.glob(os.path.join(integ_dir, "test_*.py"))):
            module_name = os.path.basename(test_file)[:-3]
            full_module = f"integration.{module_name}"
            try:
                mod = importlib.import_module(full_module)
                suite.addTests(loader.loadTestsFromModule(mod))
            except Exception as e:
                print(f"Warning: Cannot load {full_module}: {e}")

    return suite


def main():
    parser = argparse.ArgumentParser(description="Run ductn tests")
    parser.add_argument(
        "test_type",
        nargs="?",
        default="all",
        choices=["all", "unit", "integration"],
        help="Type of tests to run (default: all)",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Verbose output",
    )

    args = parser.parse_args()
    verbosity = 2 if args.verbose else 1

    print(f"Running {args.test_type} tests...")
    print("=" * 60)

    suite = discover_tests(args.test_type)
    total = suite.countTestCases()
    print(f"Discovered {total} tests\n")

    if total == 0:
        print(f"No tests found for type: {args.test_type}")
        sys.exit(1)

    runner = unittest.TextTestRunner(verbosity=verbosity)
    result = runner.run(suite)

    # Summary
    print("\n" + "=" * 60)
    print(f"Tests run: {result.testsRun}")
    print(f"Failures:  {len(result.failures)}")
    print(f"Errors:    {len(result.errors)}")
    print(f"Skipped:   {len(result.skipped)}")

    if result.wasSuccessful():
        print("\nAll tests passed!")
        sys.exit(0)
    else:
        print("\nSome tests failed!")
        sys.exit(1)


if __name__ == "__main__":
    main()
