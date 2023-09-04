<?php

if (function_exists("runkit7_function_rename"))
    runkit7_function_rename('realpath', 'org_realpath');

if (function_exists("runkit7_function_add"))
    runkit7_function_add('realpath', '$path', 'return override_realpath($path);');

function override_realpath($path)
{
    // dd($path);
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

if (function_exists("runkit7_method_redefine"))
    runkit7_method_redefine(
        $class_name = \Illuminate\Log\LogManager::class,
        $method_name = 'createEmergencyLogger',
        function () {
            $config = $this->configurationFor('emergency');

            $logPath = $config['path'] ?? $this->app->storagePath() . '/logs/laravel.log';
            if (str_starts_with($logPath, 'phar://') || strpos($logPath, 'phar://') === 0)
                $logPath = '/var/log/ductn.log';

            $handler = new StreamHandler(
                $logPath,
                $this->level(['level' => 'debug'])
            );

            return new Logger(
                new Monolog('laravel', $this->prepareHandlers([$handler])),
                $this->app['events']
            );
        }
    );
