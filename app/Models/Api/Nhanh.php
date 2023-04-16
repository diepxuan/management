<?php

namespace App\Models\Api;

use App\Models\Catalog\Product;
use App\Models\Admin\Api as Model;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Nhanh extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = "apis";

    const access_url = "https://nhanh.vn/oauth/access_token";
    const secretKey = "MFxQFTrhUFotuZ2l9SxDkn03S2YXPllbWoMT2B5NrHlRDrdStEmAhnwW3CrtdkIz2dyUQxlfVgQvGhmF4WcZJE22CxaC3Fn90QDYSTkYHz3kcLE8HB2AvsllIux7dJNt";
    const version = "2.0";
    const appId = "72370";

    const api_url = "https://open.nhanh.vn";
    const PRODUCT = self::api_url . "/api/product/search";

    protected $currentPage;
    protected $totalPages;

    /**
     * Create a new Eloquent model instance.
     *
     * @param  array  $attributes
     * @return void
     */
    public function __construct(array $attributes = [])
    {
        parent::__construct($attributes = []);
    }

    public function getProducts(array $Arg = [])
    {

        $products = new Collection;
        try {
            $products = $this->post(self::PRODUCT, $Arg);
        } catch (\Throwable $th) {
        }
        $products = collect($products)->map(function ($product) {
            // unset($product['inventory']);
            // unset($product['attributes']);
            // unset($product['units']);

            $_product = new Product($product);
            // $product->save();
            // return $product;

            try {
                return Product::updateOrCreate($_product->toArray());
            } catch (\Throwable $th) {
                Log::info($product['code']);
                Log::info($product);
                throw $th;
                return $product;
            }
        });
        return $products;
    }

    public function post($url, array $data = [])
    {
        $response = Http::asForm()->post($url, [
            'version'     => self::version,
            'appId'       => self::appId,
            'businessId'  => $this->businessId,
            'accessToken' => $this->accessToken,
            'data'        => json_encode($data),
        ]);
        if ($response['code'] == 0) return array();

        $data = $response['data'];
        $this->currentPage = $data['currentPage'];
        $this->totalPages = $data['totalPages'];

        return $data['products'];
    }

    public function getTotalPagesAttribute($totalPages)
    {
        return $this->totalPages;
    }

    public function setTotalPagesAttribute($totalPages)
    {
        $this->totalPages = $totalPages;
    }

    public function getCurrentPageAttribute($currentPage)
    {
        return $this->currentPage;
    }

    public function setCurrentPageAttribute($currentPage)
    {
        $this->currentPage = $currentPage;
    }

    /**
     * The "booting" method of the model.
     *
     * @return void
     */
    protected static function boot()
    {
        parent::boot();

        static::addGlobalScope("api.nhanh", function (Builder $builder) {
            $builder->where("type", "nhanh");
        });
    }
}