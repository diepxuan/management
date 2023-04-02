<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Http\Controllers\Sys;

use Illuminate\Support\Facades\Log;
use App\Models\Sys\Vm;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use App\Http\Requests\UpdateVmRequest;

class VmController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {

        Log::info('index');
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
    public function store(StoreVmRequest $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(string $vm)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $vm)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateVmRequest $request, string $vm)
    {
        $vm = Vm::updateOrCreate(
            [
                "vm_id" => $vm,
            ],
            [
                "name" => $request->input("name"),
                "pri_host" => $request->input("pri_host"),
                "pub_host" => $request->input("pub_host"),
            ]
        );

        return response()->json([
            "vm" => $vm,
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $vm)
    {
        //
    }
}
