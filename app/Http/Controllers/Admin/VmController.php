<?php

namespace App\Http\Controllers\Admin;

use App\Models\Sys\Vm;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class VmController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return view('admin/vm/index', [
            'vms' => Vm::all(),
            'DdnsLst' => \App\Models\Admin\Ddns::all(),
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
    public function store(Request $request)
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
    public function update(Request $request, string $vm)
    {
        if ($vm == 'new') {
            Vm::updateOrCreate([
                "vm_id"     => $request->input("vm_id"),
            ], [
                "pri_host"  => $request->input("pri_host"),
                "parent_id" => $request->input("parent_id"),
                "is_allow"  => $request->input("is_allow"),
                "port"      => $request->input("port"),
            ]);
            return redirect()->route("admin.vm.index");
        }

        $vm = Vm::updateOrCreate(["vm_id" => $vm]);
        $vm->parent_id  = $request->input("parent_id", $vm->parent_id);
        $vm->is_allow   = $request->input("is_allow", $vm->is_allow);
        $vm->port       = $request->input("port", $vm->port);
        $vm->save();
        $vm->ddnses()->sync($request->input("ddnses"));

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