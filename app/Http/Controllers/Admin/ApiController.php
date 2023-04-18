<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use App\Models\Admin\Api;
use App\Models\Api\Nhanh;

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
        switch ($type) {
            case 'nhanh':
                $accessCode = $request->input("accessCode");
                $response = Http::asForm()->post(Nhanh::access_url, [
                    'version'    => Nhanh::version,
                    'appId'      => Nhanh::appId,
                    'accessCode' => $accessCode,
                    'secretKey'  => Nhanh::secretKey,
                ]);
                if ($response['code'])
                    try {
                        Api::updateOrCreate([
                            'type' => $type,
                            'accessToken' => $response['accessToken'],
                            'expiredDateTime' => $response['expiredDateTime'],
                            'businessId' => $response['businessId'],
                            'depotIds' => implode(" ", $response['depotIds']),
                            'permissions' => $response['permissions'],
                        ]);
                    } catch (\Throwable $th) {
                        // throw $th;
                        return redirect()->route('admin.api.index');
                    }

                break;

            default:
                return redirect()->route('admin.api.index');
                break;
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
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Api $api)
    {
        //
    }
}