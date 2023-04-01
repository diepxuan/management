<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Http\Controllers\Sys;

use Illuminate\Support\Facades\Log;
use App\Models\Sys\Vm;

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
    public function show(Vm $vm)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Vm $vm)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateVmRequest $request, Vm $vm)
    {
        // Log::info($vm);
        Log::info('update');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Vm $vm)
    {
        //
    }
}
