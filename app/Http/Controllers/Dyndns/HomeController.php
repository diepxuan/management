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

        // if ($ipNew == $ipCurrent) {
        //     printf("good %2\$s" . PHP_EOL, $hostname, $ipCurrent);
        // }

        // $dnsLst = $ddns->dns();
        // $ddns->log(json_encode($dnsLst));
        // \var_dump($dnsLst);
        // die;

        $dnsLst = array_filter($ddns->dns(), function ($dns, $k) use ($ddns, $hostname, $ip) {

            // if ($dns->name == $hostname) {
            //     $ddns->log(sprintf('%10s %20s %15s synced', 'starting', $hostname, $ip));
            //     return true;
            // }
            // return false;
            // return $dns->name == $hostname;
            return $dns->name == $hostname && $dns->content != $ip;
        }, ARRAY_FILTER_USE_BOTH);

        // $ddns->log(json_encode($dnsLst));

        $dnsLst = array_map(function ($dns) use ($ddns, $ip, $type) {
            $content = [
                'type' => $dns->type,
                'name' => $dns->name,
                'content' => $ip,
                // 'ttl' => 120,
                'proxied' => false,
            ];

            $result = $ddns->dnsUpdate($dns->zone_id, $dns->id, $content);
            $ddns->log(json_encode($result));

            if (!$result->success) {
                return $dns;
            }

            $dns = $result->result;

            echo sprintf("good %2\$s" . PHP_EOL, $dns->name, $dns->content);
            $ddns->log(sprintf('%10s %20s %15s pass', $type, $dns->name, $dns->content));

            return $dns;
        }, $dnsLst);

        // if (count($dnsLst) <= 0) {
        // echo printf("good %2\$s" . PHP_EOL, $hostname, $ip);
        //     $ddns->log(sprintf('%10s %20s %15s has been synced', $type, $hostname, $ip));
        // }
        // var_dump($_SERVER);
        return view('dyndns/ddns', [
            'data' => []
        ]);
    }
}
