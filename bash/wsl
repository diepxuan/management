#!/usr/bin/env bash
#!/bin/bash

--wsl:cli:install() {
    if grep -q Microsoft /proc/version; then
        _wsl:cli:install
    fi
    if grep -q microsoft /proc/version; then
        _wsl:cli:install
    fi
}

_wsl:cli:install() {
    mkdir -p /mnt/c/wslcli/
    # cat /var/www/base/bash/win10/php.bat >/mnt/c/wslcli/php.bat
    cat /var/www/base/bash/win10/composer.bat >/mnt/c/wslcli/composer.bat

    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -O /mnt/c/wslcli/phpcs
    cat /var/www/base/bash/win10/phpcs.bat >/mnt/c/wslcli/phpcs.bat

    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -O /mnt/c/wslcli/phpcbf
    cat /var/www/base/bash/win10/phpcbf.bat >/mnt/c/wslcli/phpcbf.bat

    wget https://cs.symfony.com/download/php-cs-fixer-v3.phar -O /mnt/c/wslcli/php-cs-fixer
    cat /var/www/base/bash/win10/php-cs-fixer.bat >/mnt/c/wslcli/php-cs-fixer.bat

    # cat /var/www/base/bash/win10/node.bat >/mnt/c/wslcli/node.bat
    cat /var/www/base/bash/win10/yarn.bat >/mnt/c/wslcli/yarn.bat

    cat /var/www/base/bash/win10/git.bat >/mnt/c/wslcli/git.bat

    if [[ ! -f "$(which shfmt)" ]]; then
        $(curl -fsSL https://raw.githubusercontent.com/chiefbiiko/shfmt-install/v0.1.0/install.sh | sh) -d .
        chmod +x shfmt
        sudo chown root:root shfmt
        sudo mv shfmt /usr/local/bin/shfmt
    fi
    cat /var/www/base/bash/win10/shfmt.bat >/mnt/c/wslcli/shfmt.bat
}
