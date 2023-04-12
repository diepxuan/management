<?php

namespace App\Http\Controllers\Catalog;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\Catalog\Product;
use Illuminate\Http\Request;
use App\Models\Admin\Api;

class ProductController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return view('catalog/products', [
            'products' => Product::all(),
            'apis' => Api::all(),
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

    public function sync(Request $request, Api $api)
    {
        // $api = Api::get($api);
        // $apis = Api::all();
        // Log::info($apis);
        Log::info($api);

        // echo $api;

        // dd(Api::first());
        // Log::info(Api::all());
        // dd($api);

        return view('catalog/products', [
            'apis' => Api::all(),
            'products' => Product::all(),
        ]);

        // return redirect()->route('admin.product.index');
    }
}
