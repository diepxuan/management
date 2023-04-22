<?php

namespace App\Http\Controllers\Catalog;

use App\Repositories\Catalog\ProductRepositoryInterface;
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
    public function index(Request $request, ProductRepositoryInterface $productRepository)
    {
        $data['products'] = $productRepository->load($request)->getProducts();
        $data['apis']     = Api::all();

        return view('catalog/products', $data);
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
    public function store(Request $request, ProductRepositoryInterface $productRepository)
    {
        $request->session()->put('is_all', $request->get('is_all', 0));
        $productRepository->import();

        return redirect()->route("catalog.product.index");
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