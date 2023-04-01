<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Http\Controllers\Dyndns;

use App\Models\Dyndns\Ddns;
use Illuminate\Support\Facades\Log;

class HomeController extends Controller
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
        string $hostname = null,
        string $ip = null
    ) {
        $ddns = Ddns::get()->first();
        $ipNew = $ip ?: $ipaddressHelper->client;
        $ipCurrent = gethostbyname($hostname);
        Log::debug($_SERVER);
        Log::debug($hostname);
        Log::debug($ipCurrent);
        Log::debug($ipNew);
        Log::debug($_SERVER['SERVER_ADDR']);
        Log::debug($ddns);
        // Log::debug(filter_var($hostname, FILTER_VALIDATE_DOMAIN, FILTER_FLAG_HOSTNAME));
        Log::debug($domainHelper->fqdnCheck($hostname));
        Log::debug(
            print_r($ddnsRepository->getService()->getZones(), true)
        );

        return view('dyndns/ddns', [
            'data' => []
        ]);
    }
}