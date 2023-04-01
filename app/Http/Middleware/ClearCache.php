<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Http\Middleware;

use Illuminate\Support\Facades\Artisan;
use Closure;
use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Support\Facades\Cache;

class ClearCache
{
    /**
     * Handle an incoming request.
     *
     * @param \Illuminate\Http\Request $request
     *
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        if (!in_array(config("app.env"), ["production", "staging"])) {
            Artisan::call("cache:clear");
            Artisan::call("view:clear");
            Cache::flush();
        }

        return $next($request);
    }
}