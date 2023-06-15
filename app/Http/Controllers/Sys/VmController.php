<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Http\Controllers\Sys;

use Illuminate\Support\Facades\Log;
use App\Models\Sys\Vm;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class VmController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return view('sys/vm', [
            'data' => []
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
        Log::info('create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
        Log::info('store');
    }

    /**
     * Display the specified resource.
     */
    public function show(string $vm)
    {
        //
        Log::info('show');
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $vm)
    {
        //
        Log::info('edit');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $vm)
    {
        $vm = Vm::updateOrCreate(["vm_id" => $vm]);
        $vm->name     = $request->input("name", $vm->name);
        $vm->pri_host = $request->input("pri_host", $vm->pri_host);
        $vm->pub_host = $request->input("pub_host", $vm->pub_host);
        $vm->version  = $request->input("version", $vm->version);

        $gateway      = explode(" ", $request->input("gateway"));
        $vm->gateway  = count($gateway) > 0 ? $gateway : $vm->gateway;

        $wg_key       = explode(" ", $request->input("wg_key"));
        $vm->wgkey    = count($wg_key) > 0 ? $wg_key : $vm->wgkey;

        $vm->save();

        // Log::info($vm->vm_id);
        // Log::info($vm->gateway);
        // Log::info($vm->wg_pri);
        // Log::info($vm->wg_pub);

        if ($vm->vm_id == 'pve1.diepxuan.com') {
            $vm->commands = [
                // "sudo csf -ra",
                // "--sys:env:sync",
            ];

            // Log::info($vm->vm_id);

            // $vm->dnsUpdate();
        }

        $vm->dnsUpdate();

        $vm->commands = [
            // "--sys:env:sync",
            // "--sys:upgrade",
            // "--sys:dhcp:config",
        ];

        if ($vm->is_allow)
            return response()->json([
                "vm" => $vm,
            ]);

        return;
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $vm)
    {
        //
    }
}