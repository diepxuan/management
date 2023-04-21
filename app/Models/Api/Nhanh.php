<?php

namespace App\Models\Api;

use Illuminate\Http\Request;
use App\Models\Catalog\Product;
use App\Models\Admin\Api as Model;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Casts\Attribute;
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

    // protected $currentPage;
    // protected $totalPages;
    // protected $isAll = false;

    public function getProducts(array $args = [])
    {
        $products = new Collection;
        try {
            $args = array_replace([
                'icpp' => 50,
                'page' => 1,
                'sort' => ['code' => 'asc']
            ], $args);
            if ($this->totalPages > 0 && $args['page'] > $this->totalPages) {
                return $products;
            }
            $products = $this->post(self::PRODUCT, $args);
        } catch (\Throwable $th) {
        }
        $products = collect($products)->map(function ($product) {
            try {
                $p = new Product($product);
                $p->nhanh_id         = $product['idNhanh'];
                $p->nhanh_parentId   = $product['parentId'];
                $p->nhanh_categoryId = $product['categoryId'];

                return Product::updateOrCreate($p->toArray());
            } catch (\Throwable $th) {
                return $product;
            }
        });

        if ($this->isAll) {
            return $products->merge($this->getProducts(
                array_replace($args, [
                    'page' => $this->currentPage + 1
                ])
            ));
        }

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

    protected function isAll(): Attribute
    {
        return Attribute::make(
            get: fn (mixed $value) => session('is_all', 0),
            // set: fn (mixed $value, array $attributes) => $value ?: Str::sanitizeString($attributes['name'])
        );
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