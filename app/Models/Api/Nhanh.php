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

    const MODEL_TYPE = "nhanh";

    const access_url = "https://nhanh.vn/oauth/access_token";
    const secretKey = "MFxQFTrhUFotuZ2l9SxDkn03S2YXPllbWoMT2B5NrHlRDrdStEmAhnwW3CrtdkIz2dyUQxlfVgQvGhmF4WcZJE22CxaC3Fn90QDYSTkYHz3kcLE8HB2AvsllIux7dJNt";
    const version = "2.0";
    const appId = "72370";

    const api_url = "https://open.nhanh.vn";
    const PRODUCT = self::api_url . "/api/product/search";

    public function import()
    {
        $this->importProducts();
    }

    protected function importProducts(array $args = [])
    {
        $products = new Collection;
        try {
            $args = array_replace([
                'icpp' => 50,
                'page' => 1,
            ], $args);
            if ($this->totalPages > 0 && $args['page'] > $this->totalPages) {
                return;
            }
            $products = $this->post(self::PRODUCT, $args);
        } catch (\Throwable $th) {
            return;
            throw $th;
        }

        $products = collect($products)->map(function ($product) {
            try {
                $p = new Product($product);
                $p->nhanh_id         = $product['idNhanh'];
                $p->nhanh_parentId   = $product['parentId'];
                $p->nhanh_categoryId = $product['categoryId'];

                $p = Product::updateOrCreate(['code' => $p->code], $p->toArray());
                Product::where('code', $p->code)->where('id', '<>', $p->id)->delete();
            } catch (\Throwable $th) {
                return $product;
                throw $th;
            }
        });

        $this->importProducts(array_replace($args, [
            'page' => $this->currentPage + 1
        ]));
    }

    /** @deprecated */
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

    public function new(Request $request)
    {
        $accessCode = $request->input("accessCode");
        $response = Http::asForm()->post(Nhanh::access_url, [
            'version'    => Nhanh::version,
            'appId'      => Nhanh::appId,
            'accessCode' => $accessCode,
            'secretKey'  => Nhanh::secretKey,
        ]);
        if ($response['code'])
            Api::updateOrCreate([
                'type'            => $this->type,
                'accessToken'     => $response['accessToken'],
                'expiredDateTime' => DateTime::createFromFormat('Y-m-d H:i:s', $response['expiredDateTime'])->format(Nhanh::DATETIMEFORMAT),
                'businessId'      => $response['businessId'],
                'depotIds'        => implode(" ", $response['depotIds']),
                'permissions'     => $response['permissions'],
            ]);

        return redirect()->route('admin.api.index');
    }

    /**
     * The "booting" method of the model.
     *
     * @return void
     */
    protected static function boot()
    {
        parent::boot();

        static::addGlobalScope("api." . self::MODEL_TYPE, function (Builder $builder) {
            $builder->where("type", self::MODEL_TYPE);
        });
    }
}