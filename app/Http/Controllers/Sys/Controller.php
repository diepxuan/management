<?php

/*
 * Copyright © 2019 Dxvn, Inc. All rights reserved.
 */

namespace App\Http\Controllers\Sys;

class Controller extends \App\Http\Controllers\Controller
{
    function __construct()
    {
        \Barryvdh\Debugbar\Facades\Debugbar::disable();
    }
}