<?php

// rename_function('realpath', 'org_realpath');
// override_function('realpath', '$path', 'return phar_realpath($path);');

// uopz_function(DateTime::class, "aMethod", function ($arg) {
//     return $arg;
// });

// uopz_function(DateTime::class, "aStaticMethod", function ($arg) {
//     return $arg;
// }, ZEND_ACC_STATIC);

if (function_exists("runkit7_function_rename"))
    runkit7_function_rename('realpath', 'org_realpath');

if (function_exists("runkit7_function_add"))
    runkit7_function_add('realpath', '$path', 'return phar_realpath($path);');


function phar_realpath($path)
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

if (function_exists("runkit7_method_redefine"))
    runkit7_method_redefine(
        $class_name = \Illuminate\Log\LogManager::class,
        $method_name = 'createEmergencyLogger',
        function () {
            $config = $this->configurationFor('emergency');

            $logPath = $config['path'] ?? $this->app->storagePath() . '/logs/laravel.log';
            if (str_starts_with($logPath, 'phar://') || strpos($logPath, 'phar://') === 0)
                $logPath = '/var/log/ductn.log';

            $handler = new \Monolog\Handler\StreamHandler(
                $logPath,
                $this->level(['level' => 'debug'])
            );

            return new \Illuminate\Log\Logger(
                new \Monolog\Logger('laravel', $this->prepareHandlers([$handler])),
                $this->app['events']
            );
        }
    );

if (function_exists("runkit7_method_add"))
    runkit7_method_add(
        $class_name = \Symfony\Component\Finder\SplFileInfo::class,
        $method_name = 'getRealPath',
        function () {
            $realPath = parent::getRealPath();
            $path = $this->getPathname();
            if ($realPath == false && file_exists($path)) {
                if (str_starts_with($path, 'phar://'))
                    $realPath = $path;
                if (strpos($path, 'phar://') === 0)
                    $realPath = $path;
            }
            return $realPath;
        }
    );
