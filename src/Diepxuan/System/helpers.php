<?php

use Composer\InstalledVersions as ComposerPackage;
use Diepxuan\System\Component\SplFileInfo;
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Arr;
use Illuminate\Support\Str;

if (!function_exists("shell")) {
    function shell(...$args)
    {
        $args = Arr::flatten(Arr::map(Arr::wrap($args), function (string $value, string $key) {
            return Str::of($value)->split('/[\s,]+/');
        }));
        $cmd = Arr::pull($args, 0);
        $args = Arr::join($args, ' ');


        $scriptPath = new SplFileInfo(ComposerPackage::getInstallPath('diepxuan/system'));
        $scriptPath = $scriptPath->isDir() ? $scriptPath : new SplFileInfo(__DIR__);
        $scriptPath = new SplFileInfo($scriptPath->getRealPath() . '/scripts/');

        $shellPath = new SplFileInfo($scriptPath->getRealPath() . "/$cmd");
        $shellPath = $shellPath->isFile() ? $shellPath : new SplFileInfo($scriptPath->getRealPath() . "/$cmd.sh");
        if (!$shellPath->isFile()) return false;
        $cmd = $shellPath->getRealPath();
        return Str::of(Process::run("bash $cmd $args")->output());
    }
}
