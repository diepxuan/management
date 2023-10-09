<?php

namespace Diepxuan\Command\Providers;

use Composer\InstalledVersions as ComposerPackage;
use Symfony\Component\Console\Command\Command;
use Illuminate\Contracts\Events\Dispatcher;
use Diepxuan\System\Component\SplFileInfo;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;
use ReflectionClass;

class LoadCommandServiceProvider extends ServiceProvider
{

    private static $namespace = \Diepxuan\Command::class;

    /**
     * Register any other events for your application.
     *
     * @param  \Illuminate\Contracts\Events\Dispatcher  $events
     * @return void
     */
    public function boot(Dispatcher $events)
    {
        //
    }

    /**
     * Register the service provider.
     *
     * @return void
     */
    public function register()
    {
        //
        $this->commands($this->load('Commands'));
    }

    /**
     * Register all of the commands in the given directory.
     *
     * @param  array|string  $paths
     * @return void
     */
    protected function load($paths): array
    {
        $paths       = is_array($paths) ? $paths : func_get_args();
        $packagePath = new SplFileInfo(ComposerPackage::getInstallPath('diepxuan/laravel-command'));

        return collect($paths)
            ->unique()
            ->map(function ($path) {
                return Str::of($path)->explode('\\')->implode(DIRECTORY_SEPARATOR);
            })
            ->map(function ($path) use ($packagePath) {
                return Str::of($packagePath->getRealPath())
                    ->explode(DIRECTORY_SEPARATOR)
                    ->push(Str::of($path)->trim()->explode(DIRECTORY_SEPARATOR))
                    ->flatten()
                    ->implode(DIRECTORY_SEPARATOR);
            })
            ->filter(function ($path) {
                $file = new SplFileInfo($path);
                return $file->isDir();
            })
            ->map(function ($path) use ($packagePath) {
                return collect(File::allFiles($path))
                    ->filter(function ($file) {
                        return $file->getExtension() == 'php';
                    })
                    ->map(function ($file) use ($packagePath) {
                        return Str::of($file->getRealPath())
                            ->after($packagePath->getRealPath())
                            ->trim(DIRECTORY_SEPARATOR)
                            ->remove('.php')
                            ->replace(DIRECTORY_SEPARATOR, '\\')
                            ->prepend(Str::of(self::$namespace)->trim('\\')->append('\\'))->toString();
                    });
            })
            ->flatten()
            ->filter(function ($command) {
                return is_subclass_of($command, Command::class);
            })
            ->filter(function ($command) {
                return !(new ReflectionClass($command))->isAbstract();
            })
            ->toArray();
    }
}
