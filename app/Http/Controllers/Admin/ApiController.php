<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use App\Models\Admin\Api;
use App\Models\Api\Nhanh;
use DateTime;

class ApiController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return view('admin/api/index', [
            'apis' => Api::all()
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return view('admin/api/new');
    }

    public function getToken()
    {
        return redirect()->route('admin.api.index');
    }

    public function token(Request $request, $type)
    {
        $api       = new Api;
        $api->type = $type;
        $api       = $api->castAs();

        try {
            $api->new($request);
        } catch (\Throwable $th) {
            // throw $th;
            return redirect()->route('admin.api.index');
        }
        return redirect()->route('admin.api.index');
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
    public function show(Api $api)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Api $api)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Api $api)
    {
        if ($request->input('renew', 0))
            try {
                $api = $api->castAs();
                $api->renew($request);
            } catch (\Throwable $th) {
                // throw $th;
                return redirect()->route('admin.api.index');
            }

        return redirect()->route("admin.api.index");
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Api $api)
    {
        $api->delete();

        return redirect()->route("admin.api.index");
    }
}