<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Http\Controllers\Sys;

use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
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
                $domains = \App\Models\Sys\Env\Domain::all();
                foreach ($domains as $domain) {
                    $domain = $domain->name;
                    $data = "$data\n$domain";
                }
                $data = trim($data);
                break;

            case 'sshdconfig':
                $vms = \App\Models\Sys\Env\Ssh::all();
                foreach ($vms as $vm) {
                    // $vm = $vm->host;
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
                try {
                    $data = file_get_contents("https://diepxuan.github.io/ppa/etc/$env");
                    $data = html_entity_decode($data);
                } catch (\Throwable $th) {
                    $data = null;
                }
                break;
        }

        return $data;
    }

    /**
     * Display the specified resource.
     */
    public function showByVm(string $env, \App\Models\Admin\Vm $vm)
    {
        $data = null;
        Log::info($vm->domains);
        switch ($env) {
            case 'domains':
                return $vm->domains;
                break;

            case 'sshdconfig':
                $vms = \App\Models\Sys\Env\Ssh::all();
                foreach ($vms as $vm) {
                    // $vm = $vm->host;
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
                // try {
                //     $data = file_get_contents("https://diepxuan.github.io/ppa/etc/$env");
                //     $data = html_entity_decode($data);
                // } catch (\Throwable $th) {
                //     $data = null;
                // }
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