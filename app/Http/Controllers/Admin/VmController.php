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
        return view('admin/vm', [
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
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateVmRequest $request, Vm $vm)
    {
        $vm->is_allow = $request->input("is_allow");
        $vm->save();

        if ($vm->is_allow)
            $mess = "Đã bật <strong>{$vm->name}</strong>.";
        else
            $mess = "Đã tắt <strong>{$vm->name}</strong>.";

        return redirect()
            ->route("admin.vm.index")
            ->with("Thành công", $mess);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Vm $vm)
    {
        Log::info($vm);
        if (!$vm->is_allow) {
            $vm->delete();
        }

        return redirect()->route("admin.vm.index")->with(
            "thành công",
            "Đã xóa <strong>[$vm->name]</strong>."
        );
    }
}