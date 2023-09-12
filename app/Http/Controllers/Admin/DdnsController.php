<?php

/**
 * @copyright © 2023 DiepXuan. All rights reserved.
 * @author Tran Ngoc Duc <caothu91@gmail.com>
 *
 * Created on Thu May 25 2023 12:30:14
 */

namespace App\Http\Controllers\Admin;

use Diepxuan\System\Service\Ddns;
use Illuminate\Support\Facades\Log;

class DdnsController extends Controller
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
        \App\Helpers\IpaddressHelper $ipaddressHelper,
        \App\Helpers\DomainHelper $domainHelper,
        string $hostname = null,
        string $ip = null
    ) {
        $data['ddns']     = Ddns::all();

        return view('admin/ddns/index', $data);
    }
}
