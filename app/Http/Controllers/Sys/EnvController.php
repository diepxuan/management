<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Http\Controllers\Sys;

use Illuminate\Support\Facades\Log;
use Barryvdh\Debugbar\Facades\Debugbar;
use Illuminate\Support\Facades\Storage;

class EnvController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware([]);
        parent::__construct();
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index(
        string $conf = null
    ) {

        // Storage::disk('local')->get("bin/etc/$conf");
        $data = file_get_contents("https://diepxuan.github.io/ppa/etc/$conf");
        Debugbar::info($conf);

        return view('sys/env', [
            'data' => $data
        ]);
    }
}