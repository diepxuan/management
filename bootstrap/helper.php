<?php

if (!defined("DUCTN_CLI") || !DUCTN_CLI) return;

if (function_exists("runkit7_function_rename"))
    runkit7_function_rename('realpath', 'org_realpath');

if (function_exists("runkit7_function_add"))
    runkit7_function_add('realpath', '$path', 'return override_realpath($path);');

// if (function_exists("runkit7_method_redefine")) {
//     runkit7_method_redefine(
//         \SplFileInfo::class,
//         "getRealPath",
//         '',
//         'return $this->getPath();',
//         RUNKIT7_ACC_PUBLIC
//     );
//     runkit7_method_redefine(
//         \Symfony\Component\Finder\SplFileInfo::class,
//         "getRealPath",
//         '',
//         'return $this->getPath();',
//         RUNKIT7_ACC_PUBLIC
//     );
// }

function override_realpath($path)
{
    $realpath = org_realpath($path);
    if ($realpath == false && file_exists($path)) {
        if (str_starts_with($path, 'phar://'))
            $realpath = $path;
        if (strpos($path, 'phar://') === 0)
            $realpath = $path;
    }
    return $realpath;
}
