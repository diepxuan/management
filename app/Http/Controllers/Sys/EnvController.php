<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Http\Controllers\Sys;

use App\Http\Requests\EnvRequest;
use App\Helpers\Str;
use App\Models\Sys\Vm;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;
use League\CommonMark\Node\Inline\Newline;

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
    public function index()
    {
        //
    }


    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(string $env)
    {
        $data = null;
        switch ($env) {
            case 'domains':
                return VM::first()->domains;
                break;

            case 'sshdconfig':
                $vms = \App\Models\Sys\Env\Ssh::all();
                foreach ($vms as $vm) {
                    $data .= "Host $vm->host\n";
                    $data .= "  User ductn\n";
                    $data .= "  HostName $vm->hostName\n";
                    if ($vm->proxyJump)
                        $data .= "  ProxyJump $vm->proxyJump\n";
                    $data .= "\n";
                }
                $data = trim($data);
                break;

            default:
                return ([
                    'portforward' => '# <IPADDRESS>:<tcp port>:<udp port>
10.0.pve.10:88,135,139,389,464,445,636,3268,3269,3389:88,123,135,138,389,445,464
10.0.pve.11:1433
10.0.2.12:9200
10.0.2.13:13389',
                    'tunel' => '',
                    'csf' => 'TESTING = "0"
TCP_IN = "22,53,80,88,389,443,1433,3268,3389,5173,8006,9200,13389,17691"
TCP_OUT = "1:65535"
UDP_IN = "53,67"
UDP_OUT = "1:65535"
CC_DENY = ""
CLUSTER_SENDTO = "10.8.0.1,10.8.0.2,192.168.11.201,192.168.11.202,10.0.2.1,10.0.2.11,10.0.2.150,10.0.1.1,10.0.1.11,171.244.62.193,125.212.237.119"
CLUSTER_RECVFROM = "10.8.0.1,10.8.0.2,192.168.11.201,192.168.11.202,10.0.2.1,10.0.2.11,10.0.2.150,10.0.1.1,10.0.1.11,171.244.62.193,125.212.237.119"
CUSTOM1_LOG = "/var/log/syslog"
DYNDNS = "300"',
                    'dhcp' => "dc1     ba:1f:4a:6a:63:a1 10.0.1.10
sql1    ae:fa:53:5f:00:f1 10.0.1.11
drive   C6:F1:E9:AF:58:1C 10.0.1.12

dc2     62:F0:9D:12:02:61 10.0.2.10
sql2    16:13:D5:80:B3:58 10.0.2.11
elastic	B6:56:68:1F:28:C4 10.0.2.12
social  C2:6E:9B:69:DD:C3 10.0.2.13",
                ])[$env];
                break;
        }

        return $data;
    }

    /**
     * Display the specified resource.
     */
    public function showByVm(EnvRequest $request, string $env, Vm $vm)
    {
        $data = null;
        switch ($env) {
            case 'domains':
                return trim($vm->domains)
                    . "\nsecurity.ubuntu.com"
                    . "\nppa.launchpad.net";
                break;

            case 'portforward':
                return $vm->portforward;
                break;

            case 'csf':
                return $vm->csf;
                break;

            case 'tunel':
                return $vm->tunel;
                break;

            case 'sshdconfig':
                $vms = \App\Models\Sys\Env\Ssh::all();
                foreach ($vms as $vm) {
                    $data .= "Host $vm->host\n";
                    $data .= "  User ductn\n";
                    $data .= "  HostName $vm->hostName\n";
                    if ($vm->proxyJump)
                        $data .= "  ProxyJump $vm->proxyJump\n";
                    $data .= "\n";
                }
                $data = trim($data);
                break;

            default:
                return ([
                    'tunel' => '',
                    'csf' => 'TESTING = "0"
TCP_IN = "22,53,80,88,389,443,1433,3268,3389,5173,8006,9200,13389,17691"
TCP_OUT = "1:65535"
UDP_IN = "53,67"
UDP_OUT = "1:65535"
CC_DENY = "RU,NL"
CLUSTER_SENDTO = "10.8.0.1,10.8.0.2,192.168.11.201,192.168.11.202,10.0.2.1,10.0.2.11,10.0.2.150,10.0.1.1,10.0.1.11,171.244.62.193,125.212.237.119"
CLUSTER_RECVFROM = "10.8.0.1,10.8.0.2,192.168.11.201,192.168.11.202,10.0.2.1,10.0.2.11,10.0.2.150,10.0.1.1,10.0.1.11,171.244.62.193,125.212.237.119"
CUSTOM1_LOG = "/var/log/syslog"
DYNDNS = "300"',
                    'dhcp' => "dc1     ba:1f:4a:6a:63:a1 10.0.1.10
sql1    ae:fa:53:5f:00:f1 10.0.1.11
drive   C6:F1:E9:AF:58:1C 10.0.1.12

dc2     62:F0:9D:12:02:61 10.0.2.10
sql2    16:13:D5:80:B3:58 10.0.2.11
elastic	B6:56:68:1F:28:C4 10.0.2.12
social  C2:6E:9B:69:DD:C3 10.0.2.13",
                ])[$env];
                break;
        }

        return $data;
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}