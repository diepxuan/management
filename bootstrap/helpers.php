<?php

if (function_exists("runkit7_function_rename"))
    runkit7_function_rename('realpath', 'org_realpath');

if (function_exists("runkit7_function_add"))
    runkit7_function_add('realpath', '$path', 'return override_realpath($path);');

function override_realpath($path)
{
    $realpath = org_realpath($path);
    if ($realpath == false && file_exists($path)) {
        if (str_starts_with($path, 'phar://'))
            $realpath = $path;
        elseif (strpos($path, 'phar://') === 0)
            $realpath = $path;

        $realpath = trim($path, DIRECTORY_SEPARATOR);
        // if (is_dir($path)) {
        //     $realpath = trim($path, DIRECTORY_SEPARATOR);
        // }
    }
    return $realpath;
}
