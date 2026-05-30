#!/usr/bin/env python3
"""
Magento 2 helper commands.

Usage:
    ductn php:m2              — Show all available subcommands
    ductn php:m2 <action>     — Run a specific action
    ductn php:m2 <any magento command>  — Forward to bin/magento

All actions require running inside a Magento 2 project directory (bin/magento must exist).
"""

import os
import subprocess
import logging
import shutil

from .registry import register_command


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

WEBSERVER_GROUP = "www-data"


def _has_magento():
    """Check if we're in a Magento 2 project directory."""
    return os.path.isfile("bin/magento")


def _run_magento(*args, check=True):
    """Run bin/magento with memory/time limits."""
    if not _has_magento():
        logging.error("Not in a Magento 2 project directory (bin/magento not found)")
        return False
    cmd = ["php", "-d", "memory_limit=756M", "-d", "max_execution_time=18000",
           "bin/magento"] + list(args)
    try:
        subprocess.run(cmd, check=check)
        return True
    except subprocess.CalledProcessError as e:
        logging.error(f"Magento error: {e}")
        return False


def _run_magerun2(*args, check=True):
    """Run n98-magerun2 (download if missing)."""
    if not _has_magento():
        logging.error("Not in a Magento 2 project directory (bin/magento not found)")
        return False
    magerun2 = "bin/magerun2"
    if not os.path.isfile(magerun2):
        logging.info("Downloading n98-magerun2...")
        try:
            subprocess.run(
                ["curl", "-sS", "-o", "n98-magerun2.phar",
                 "https://files.magerun.net/n98-magerun2.phar"],
                check=True,
            )
            os.chmod("n98-magerun2.phar", 0o755)
            shutil.move("n98-magerun2.phar", magerun2)
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to download magerun2: {e}")
            return False
    cmd = ["php", "-d", "memory_limit=756M", "-d", "max_execution_time=18000",
           magerun2] + list(args)
    try:
        subprocess.run(cmd, check=check)
        return True
    except subprocess.CalledProcessError as e:
        logging.error(f"Magerun2 error: {e}")
        return False


def _run_grunt(*args):
    """Run npx grunt (install npm deps if needed)."""
    try:
        subprocess.run(
            ["npx", "grunt", "--version"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        logging.info("Installing npm dependencies for grunt...")
        subprocess.run(["npm", "install"], check=True)
    cmd = ["npx", "grunt"] + list(args)
    try:
        subprocess.run(cmd, check=True)
        return True
    except subprocess.CalledProcessError as e:
        logging.error(f"Grunt error: {e}")
        return False


def _ch(*paths):
    """chmod g+ws (dirs) / g+w (files) on given paths."""
    for p in paths:
        if not os.path.exists(p):
            continue
        if os.path.isdir(p):
            subprocess.run(["chmod", "-R", "g+w", p])
            subprocess.run(["chmod", "g+ws", p])
        else:
            subprocess.run(["chmod", "g+w", p])


def _fix_magento_permissions():
    """Full permission fix: chown group + chmod directories/files + g+ws."""
    logging.info("Fixing Magento permissions...")
    subprocess.run(["chmod", "u+x", "bin/magento"])
    subprocess.run(["chown", "-R", f":{WEBSERVER_GROUP}", "."])
    _ch(
        "app/etc", "vendor", "generated", "generation",
        "generation/code", "pub/static", "pub/media",
        "var", "var/log", "var/cache", "var/page_cache",
        "var/generation", "var/view_preprocessed", "var/tmp",
    )
    # WordPress theme dir if exists
    if os.path.isdir("wp/wp-content/themes"):
        _ch("wp/wp-content/themes")


# ---------------------------------------------------------------------------
# Subcommands (each maps to _dev:m2:* in bash)
# ---------------------------------------------------------------------------

def _m2_ch(args):
    """m2:ch — Fix permissions on Magento directories."""
    _fix_magento_permissions()
    logging.info("Permissions fixed.")


def _m2_group(args):
    """m2:group — Add current user to webserver group."""
    import getpass
    user = getpass.getuser()
    try:
        subprocess.run(["usermod", "-aG", WEBSERVER_GROUP, user], check=True)
        logging.info(f"Added {user} to group {WEBSERVER_GROUP}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed: {e}")


def _m2_urn(args):
    """m2:urn — Generate URN catalog for IDE + fix permissions."""
    _run_magerun2("dev:urn-catalog:generate", ".idea/misc.xml")
    _fix_magento_permissions()


def _m2_perm(args):
    """m2:perm — Fix ownership, permissions, and g+ws."""
    _fix_magento_permissions()
    logging.info("Permissions fixed.")


def _m2_rmgen(args):
    """m2:rmgen — Remove generated/code, generation, var/generation dirs."""
    dirs_to_clean = [
        "generated", "generated/code",
        "generation", "generation/code",
        "var/generation",
    ]
    for d in dirs_to_clean:
        if os.path.isdir(d):
            # Skip Magento/Composer/Symfony subdirs
            for item in os.listdir(d):
                if item in ("Magento", "Composer", "Symfony"):
                    continue
                full = os.path.join(d, item)
                if os.path.isdir(full):
                    shutil.rmtree(full)
            logging.info(f"Cleaned {d}")
    _run_magerun2("generation:flush")
    logging.info("Generated files removed.")


def _m2_static(args):
    """m2:static — Clear static assets + view_preprocessed."""
    import glob
    for pattern in [
        "var/view_preprocessed/*",
        "pub/static/frontend/*",
        "pub/static/adminhtml/*",
        "pub/static/_requirejs/*",
    ]:
        for p in glob.glob(pattern):
            if os.path.isdir(p):
                shutil.rmtree(p)
            elif os.path.isfile(p):
                os.remove(p)
    _run_magerun2("dev:asset:clear")
    logging.info("Static assets cleared.")


def _m2_cache(args):
    """m2:cache — Flush cache + fix permissions."""
    _run_magento("cache", "flush")
    _fix_magento_permissions()


def _m2_index(args):
    """m2:index — Reindex + fix permissions."""
    _run_magento("indexer", "reindex")
    _fix_magento_permissions()


def _m2_grunt(args):
    """m2:grunt — Run grunt exec:all then watch."""
    _run_grunt("exec:all")
    _run_grunt("watch")


def _m2_up(args):
    """m2:up — Run setup:upgrade + fix permissions."""
    _run_magento("setup:upgrade", *args)
    _fix_magento_permissions()


def _m2_config(args):
    """m2:config — Enable all modules, compile DI, fix permissions."""
    _run_magerun2("module:enable", "--all")
    _run_magerun2("setup:di:compile")
    _fix_magento_permissions()


def _m2_setting(args):
    """m2:setting — Apply standard config store settings."""
    settings = [
        ("admin/security/admin_account_sharing", "1"),
        ("admin/security/use_form_key", "0"),
        ("admin/startup/page", "dashboard"),
        ("customer/startup/redirect_dashboard", "0"),
        ("web/seo/use_rewrites", "1"),
        ("web/session/use_frontend_sid", "0"),
        ("web/url/redirect_to_base", "1"),
        ("web/browser_capabilities/local_storage", "1"),
        ("web/secure/use_in_frontend", "1"),
        ("web/secure/use_in_adminhtml", "1"),
        ("web/secure/enable_hsts", "1"),
        ("web/secure/enable_upgrade_insecure", "1"),
        ("admin/autologin/enable", "1"),
        ("admin/autologin/username", "admin"),
        ("system/smtp/active", "1"),
        ("system/smtp/smtphost", "smtp.zoho.com"),
        ("system/smtp/username", "admin@diepxuan.com"),
        ("system/smtp/password", "fbJdfF2xsKd5NSrv"),
    ]
    for path, value in settings:
        _run_magerun2("config:store:set", path, value)

    # Domain-specific URLs
    domain = args[0] if args else None
    if domain:
        _run_magerun2("config:store:set", "web/unsecure/base_url", f"http://{domain}/")
        _run_magerun2("config:store:set", "web/secure/base_url", f"https://{domain}/")
        _run_magerun2("config:store:set", "web/cookie/cookie_domain", domain)

    _run_magerun2("admin:notifications", "--off")
    _m2_cache([])
    logging.info("Settings applied.")


def _m2_developer(args):
    """m2:developer — Enable developer mode with full workflow."""
    # Require dev module
    subprocess.run(
        ["composer", "-vvv", "require", "--dev", "diepxuan/module-email"],
        check=False,
    )
    _fix_magento_permissions()

    # Clean generated
    for d in ["generated", "generated/code", "var/generation"]:
        if os.path.isdir(d):
            shutil.rmtree(d)

    # Clear static
    import glob
    for pattern in ["var/view_preprocessed/*", "pub/static/frontend/*",
                     "pub/static/adminhtml/*", "pub/static/_requirejs/*"]:
        for p in glob.glob(pattern):
            if os.path.isdir(p):
                shutil.rmtree(p)

    _m2_cache([])

    # Maintenance mode
    _run_magerun2("maintenance:enable")
    _run_magerun2("deploy:mode:set", "developer")
    _run_magerun2("module:enable", "--all")
    _run_magento("setup:upgrade")
    _run_magerun2("setup:di:compile")
    _run_magerun2("maintenance:disable")

    _m2_cache([])
    _fix_magento_permissions()
    logging.info("Developer mode enabled.")


def _m2_logenable(args):
    """m2:logenable — Enable query log."""
    _run_magento("dev:query-log:enable")


def _m2_logdisable(args):
    """m2:logdisable — Disable query log."""
    _run_magento("dev:query-log:disable")


def _m2_tempdebugenable(args):
    """m2:tempdebugenable — Enable template hints."""
    _run_magerun2("dev:template-hints-blocks", "--on")
    _run_magerun2("dev:template-hints", "--on")


def _m2_tempdebugdisable(args):
    """m2:tempdebugdisable — Disable template hints."""
    _run_magerun2("dev:template-hints-blocks", "--off")
    _run_magerun2("dev:template-hints", "--off")


def _m2_completion(args):
    """m2:completion — Generate bash completion for magerun2."""
    try:
        result = subprocess.run(
            ["symfony-autocomplete", "--shell=bash", "--", "magerun2"],
            capture_output=True, text=True, check=True,
        )
        # Post-process: adjust last line to include magerun2 binary path
        lines = result.stdout.splitlines()
        if lines:
            lines[-1] = lines[-1].rstrip() + " n98-magerun2 magerun2"
        output = "\n".join(lines[1:])  # skip first line (shebang)
        completion_dir = "/etc/bash_completion.d"
        os.makedirs(completion_dir, exist_ok=True)
        with open(os.path.join(completion_dir, "n98-magerun2"), "w") as f:
            f.write(output)
        logging.info("Bash completion installed at /etc/bash_completion.d/n98-magerun2")
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to generate completion: {e}")
    except FileNotFoundError:
        logging.error("symfony-autocomplete not found. Install via: composer global require bamarni/symfony-console-autocomplete")


# ---------------------------------------------------------------------------
# Dispatch table
# ---------------------------------------------------------------------------

M2_SUBCOMMANDS = {
    "ch": (_m2_ch, "Fix permissions on Magento directories"),
    "group": (_m2_group, "Add current user to webserver group"),
    "urn": (_m2_urn, "Generate URN catalog + fix permissions"),
    "perm": (_m2_perm, "Fix ownership, permissions, g+ws"),
    "rmgen": (_m2_rmgen, "Remove generated/code files"),
    "static": (_m2_static, "Clear static assets + view_preprocessed"),
    "cache": (_m2_cache, "Flush cache + fix permissions"),
    "index": (_m2_index, "Reindex + fix permissions"),
    "grunt": (_m2_grunt, "Run grunt exec:all + watch"),
    "up": (_m2_up, "Run setup:upgrade + fix permissions"),
    "config": (_m2_config, "Enable all modules, DI compile, fix permissions"),
    "setting": (_m2_setting, "Apply standard config store settings [domain]"),
    "developer": (_m2_developer, "Enable developer mode with full workflow"),
    "logenable": (_m2_logenable, "Enable query log"),
    "logdisable": (_m2_logdisable, "Disable query log"),
    "tempdebugenable": (_m2_tempdebugenable, "Enable template hints"),
    "tempdebugdisable": (_m2_tempdebugdisable, "Disable template hints"),
    "completion": (_m2_completion, "Generate bash completion for magerun2"),
}


def _print_m2_help():
    """Show full subcommand help (used by `m2` wrapper and `ductn php:m2`)."""
    print("Magento 2 helper commands:")
    print()
    print("  m2 <action>           Run a Magento 2 action")
    print("  m2 <magento command>  Forward directly to bin/magento")
    print()
    print("Available actions:")
    for name, (_, desc) in M2_SUBCOMMANDS.items():
        print(f"  m2 {name:<20s} {desc}")


# ---------------------------------------------------------------------------
# Main command
# ---------------------------------------------------------------------------

@register_command
def d_php_m2(args=None):
    """
    Magento 2 helper.

    Usage:
        ductn php:m2              — Show all subcommands
        ductn php:m2 <action>     — Run action (cache, static, rmgen, ...)
        ductn php:m2 <any cmd>    — Forward to bin/magento
    """
    if not _has_magento():
        # If not in a Magento directory, still show help
        _print_m2_help()
        return

    if not args:
        _print_m2_help()
        return

    action = args[0]
    rest = args[1:] if len(args) > 1 else []

    if action in M2_SUBCOMMANDS:
        fn, _ = M2_SUBCOMMANDS[action]
        fn(rest)
    else:
        # Forward to bin/magento
        _run_magento(action, *rest)
