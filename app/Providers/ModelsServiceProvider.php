<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class ModelsServiceProvider extends ServiceProvider
{
    public function register()
    {
        $this->app->bind(
            \App\Repositories\Dyndns\DdnsRepositoryInterface::class,
            \App\Repositories\Dyndns\DdnsRepository::class
        );
    }
}
