#!/usr/bin/env python3
"""Regression tests for independently versioned wrapper packages."""
import os
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
PACKAGES = {
    "ductn-ll": ("ll", "1:1.0.0+ppa~1"),
    "ductn-m2": ("m2", "1.0.0+ppa~1"),
    "ductn-lar": ("lar", "1.0.0+ppa~1"),
}


class TestSplitPackages(unittest.TestCase):
    def test_packages_have_independent_version_and_cli(self):
        for package, (command, version) in PACKAGES.items():
            with self.subTest(package=package):
                source = ROOT / "packages" / package
                changelog = (source / "debian" / "changelog").read_text()
                control = (source / "debian" / "control").read_text()
                wrapper = source / "usr" / "bin" / command

                self.assertTrue(changelog.startswith(f"{package} ({version})"))
                self.assertIn(f"Source: {package}\n", control)
                self.assertIn(f"Package: {package}\n", control)
                self.assertTrue(wrapper.is_file())
                self.assertTrue(os.access(wrapper, os.X_OK))

    def test_main_source_only_keeps_migration_packages(self):
        control = (ROOT / "src" / "debian" / "control").read_text()

        self.assertNotIn("Package: ductn-ll\n", control)
        self.assertIn("Package: m2\n", control)
        self.assertIn("Depends: ${misc:Depends}, ductn-m2\n", control)
        self.assertIn("Package: lar\n", control)
        self.assertIn("Depends: ${misc:Depends}, ductn-lar\n", control)

    def test_single_build_script_contains_all_source_packages(self):
        workflow = (ROOT / ".github" / "workflows" / "main.yml").read_text()
        build_script = (ROOT / "src" / "build.sh").read_text()

        self.assertNotIn("matrix.package", workflow)
        self.assertIn("working-directory: src", workflow)
        self.assertIn("bash build.sh", workflow)
        for package in PACKAGES:
            self.assertIn(f'packages/{package}', build_script)

        self.assertIn('echo "::warning::dput failed for', build_script)
        self.assertIn("build remains successful", build_script)


if __name__ == "__main__":
    unittest.main(verbosity=2)
