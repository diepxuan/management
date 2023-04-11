<?php

namespace App\Http\Controllers\Admin;

use App\Models\Admin\Vm;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Http\Requests\StoreVmRequest;
use App\Http\Requests\UpdateVmRequest;

class VmController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return view('admin/vm/index', [
            'vms' => Vm::all()
        ]);
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
        return view('admin/vm/index', [
            'vm' => $vm
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateVmRequest $request, Vm $vm)
    {
        $vm->is_allow = $request->exists("is_allow") ? $request->input("is_allow") : $vm->is_allow;
        $vm->parent_id = $request->exists("parent_id") ? $request->input("parent_id") : $vm->parent_id;
        $vm->save();

        return redirect()->route("admin.vm.index");
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Vm $vm)
    {
        $vm->delete();

        return redirect()->route("admin.vm.index");
    }
}