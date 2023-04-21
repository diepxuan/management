<?php

namespace App\Repositories\Catalog;

use App\Helpers\Pagination\LengthAwarePaginator;
// use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Collection;
use App\Models\Catalog\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use App\Models\Admin\Api;

class ProductRepository implements ProductRepositoryInterface
{
    protected $request;

    protected $products;
    protected $currentPage = 1;
    protected $total = 0;
    protected $perPage = 0;
    protected $options = array();
    protected $isAll = false;

    public function __construct(Request $request)
    {
        $this->request = $request;
    }

    public function load($args)
    {
        $this->isAll = $this->request->session()->get('is_all', $this->isAll);
        $this->request->session()->put('is_all', $this->isAll);
        if ($this->isAll) return $this->loadAll($args);
        else return $this->loadPage($args);
    }

    public function loadPage($args)
    {
        $this->perPage($args['perPage'] ?: 50);
        $this->currentPage($args['page'] ?: 1);

        $products = Product::orderBy('code')->paginate($this->perPage())->toArray();

        $this->setProducts(collect($products['data'])->map(function ($product) {
            $product = new Product($product);
            return $product;
        }));

        $this->total($products['total']);
        $this->options(['path' => $products['path']]);

        foreach (Api::enable()->get() as $api) {
            $className = ucfirst(strtolower($api->type));
            $className = "\App\Models\Api\\$className";
            $api = $className::find($api->id);

            $products = $this->setProducts($api->getProducts([
                'icpp' => $this->perPage(),
                'page' => $this->currentPage(),
                'sort' => ['code' => 'asc']
            ]));

            $this->total($api->totalPages * $this->perPage());
        }

        return $this;
    }

    public function loadAll($args)
    {
        foreach (Api::enable()->get() as $api) {
            $className = ucfirst(strtolower($api->type));
            $className = "\App\Models\Api\\$className";
            $api = $className::find($api->id);

            $this->setProducts($api->getProducts());
        }

        $this->setProducts(Product::all());

        return $this;
    }

    public function perPage($perPage = false)
    {
        return $this->perPage = $perPage ?: $this->perPage;
    }

    public function currentPage($currentPage = false)
    {
        return $this->currentPage = $currentPage ?: $this->currentPage;
    }

    public function total($total = 1)
    {
        return $this->total = max($total, $this->total);
    }

    public function options($options = [])
    {
        return $this->options = array_merge($this->options, $options);
    }

    public function setProducts(Collection $products)
    {
        // return $this->products = ($this->products ?: new Collection)->merge($products);
        return $this->products = ($this->products ?: new Collection)->merge($products)->keyBy('code')->sortBy('code');
    }

    public function getProducts($options = [])
    {
        if ($this->isAll)
            return $this->products;
        else
            return new LengthAwarePaginator($this->products, $this->total(), $this->perPage(), $this->currentPage(), $this->options($options));
    }
}