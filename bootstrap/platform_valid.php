<?php

// $currentFile = $_SERVER['PHP_SELF'];

// Sử dụng hàm debug_backtrace() để lấy danh sách các tệp đã include hoặc require.
// $includedFiles = get_included_files();

// foreach ($includedFiles as $file) {
//     // Kiểm tra xem tệp hiện tại có được include từ tệp nào không.
//     if ($file === $currentFile) {
//         echo "Tệp hiện tại ($currentFile) đã được include từ tệp: $file";
//         break;
//     }
// }
// if (!function_exists('runkit7_function_rename')) {
//     echo 'test';
//     die();
// }
// var_dump(__NAMESPACE__);
// die;

if (\Phar::running() == "") return;

if (!function_exists('__platform_valid')) {
    function __platform_valid_php($version = PHP_VERSION, $flag = false)
    {
        if (!$flag) return;
        $shell = '
command -v add-apt-repository >/dev/null 2>&1 &&
    sudo grep -r "deb http://ppa.launchpad.net/ondrej/php/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/ >/dev/null 2>&1 &&
    sudo add-apt-repository ppa:ondrej/php -y &&
    sudo DEBIAN_FRONTEND=noninteractive apt update

sudo grep -r "deb http://ppa.launchpad.net/ondrej/php/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/ >/dev/null 2>&1 &&
    cat <<EOF | sudo tee /etc/apt/sources.list.d/ondrej-ubuntu-php-focal.list >/dev/null &&
deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu focal main
EOF
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C &&
    sudo DEBIAN_FRONTEND=noninteractive apt update

sudo DEBIAN_FRONTEND=noninteractive apt install php%version%-cli php%version%-xml php%version%-dev -y
';
        $version = substr($version, 0, strrpos($version, '.'));
        $shell = str_replace('%version%', $version, $shell);
        shell_exec($shell);
        // passthru($shell);
    }

    function __platform_valid_runkit7($flag = false)
    {
        if (!$flag) return;
        __platform_valid_php(PHP_VERSION, $flag);
        $shell = <<<PHPEOF
pecl shell-test runkit7 || pecl install runkit7-alpha

EXTENSION="runkit7"
MODS=$(find /etc/php/ -name "mods-available" -type d 2>/dev/null || echo '')
for DIR in \$MODS; do
    if [ ! -f "\${DIR}/\${EXTENSION}.ini" ]; then
        cat <<EOF | tee "\${DIR}/\${EXTENSION}.ini" >/dev/null
; configuration for pecl runkit7 module
; priority=20
extension=runkit7.so
runkit.internal_override=On
EOF
    fi
done

phpenmod runkit7
PHPEOF;
        shell_exec($shell);
    }

    function __platform_valid()
    {
        $minVersion = "8.1.0";
        $curVersion = PHP_VERSION;
        $version    = $curVersion;

        $result = version_compare($curVersion, $minVersion);
        if ($result === 0)
            $version = $curVersion;
        elseif ($result === -1)
            $version = $minVersion;
        else
            $version = $curVersion;

        __platform_valid_php($version, $version != $curVersion);
        __platform_valid_runkit7(!extension_loaded('runkit7'));
    }
}

__platform_valid();
