<?php

// rename_function('realpath', 'org_realpath');
// override_function('realpath', '$path', 'return phar_realpath($path);');

// uopz_function(DateTime::class, "aMethod", function ($arg) {
//     return $arg;
// });

// uopz_function(DateTime::class, "aStaticMethod", function ($arg) {
//     return $arg;
// }, ZEND_ACC_STATIC);

if (!function_exists('absolutepath')) {
    function phar_absolutepath($path)
    {
        $path = str_replace(array('/', '\\'), DIRECTORY_SEPARATOR, $path);
        $parts = array_filter(explode(DIRECTORY_SEPARATOR, $path), 'strlen');
        $absolutes = array();
        foreach ($parts as $part) {
            if ('.' == $part) continue;
            if ('..' == $part) {
                array_pop($absolutes);
            } else {
                $absolutes[] = $part;
            }
        }
        return implode(DIRECTORY_SEPARATOR, $absolutes);
    }
}

function phar_realpath($path)
{
    $realPath = org_realpath($path);
    if ($realPath == false && file_exists($path)) {
        if (str_starts_with($path, 'phar:///'))
            $strStart = 'phar:///';
        $realPath = str_replace($strStart, '', $path);
        $realPath = phar_absolutepath($realPath);
        $realPath = "$strStart$realPath";
    }
    return $realPath;
}

runkit7_function_rename('realpath', 'org_realpath');

runkit7_function_add('realpath', '$path', 'return phar_realpath($path);');

runkit7_method_add(
    $class_name = \Symfony\Component\Finder\SplFileInfo::class,
    $method_name = 'getRealPath',
    function () {
        return parent::getRealPath() ?: phar_realpath(parent::getPathname());
    }
);


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
