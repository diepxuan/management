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
                            'expiredDateTime' => DateTime::createFromFormat('Y-m-d H:i:s', $response['expiredDateTime'])->format(Nhanh::DATETIMEFORMAT),
                            'businessId' => $response['businessId'],
                            'depotIds' => implode(" ", $response['depotIds']),
                            'permissions' => $response['permissions'],
                        ]);
                    } catch (\Throwable $th) {
                        // throw $th;
                        return redirect()->route('admin.api.index');
                    }

                break;

            case 'magento2':
                try {
                    $url         = $request->input("url", "https://www.diepxuan.com") . "/rest/V1/integration/admin/token";
                    $username    = $request->input("username", "admin");
                    $password    = $request->input("password", "Ductn@7691");
                    $accessToken = Http::asJson()->post($url, [
                        'username' => $username,
                        'password' => $password,
                    ]);

                    if ($accessToken) {
                        $api = Api::updateOrCreate([
                            'type'        => $type,
                            'accessToken' => $accessToken,
                            'expiredDateTime' => (new DateTime())->modify("+4 hours"),
                        ]);
                        Log::info($api);
                    }
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