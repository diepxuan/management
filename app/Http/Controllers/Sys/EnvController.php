<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Http\Controllers\Sys;

use Illuminate\Support\Facades\Log;

class EnvController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware([
            'clearcache',
        ]);
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index(
        \App\Helpers\IpaddressHelper $ipaddressHelper,
        \App\Helpers\DomainHelper $domainHelper,
        \App\Repositories\Dyndns\DdnsRepositoryInterface $ddnsRepository,
        string $conf = null
    ) {
        Log::debug($conf);

        return view('sys/env', [
            'data' => $conf
        ]);
    }
}