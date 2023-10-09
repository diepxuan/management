<?php

namespace Diepxuan\Command\Providers;

use Illuminate\Support\AggregateServiceProvider as ServiceProvider;

class CommandServiceProvider extends ServiceProvider
{
    /**
     * The provider class names.
     *
     * @var string[]
     */
    protected $providers = [
        LoadCommandServiceProvider::class,
        HideCommandServiceProvider::class,
        ScheduleCommandServiceProvider::class,
    ];
}
