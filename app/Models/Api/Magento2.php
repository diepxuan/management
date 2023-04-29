<?php

namespace App\Models\Api;

use DateTime;
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

class Magento2 extends Model
{
    use HasFactory;

    const PATH_TOKEN = "/rest/V1/integration/admin/token";

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = "apis";

    // const access_url = "https://nhanh.vn/oauth/access_token";
    // const secretKey = "MFxQFTrhUFotuZ2l9SxDkn03S2YXPllbWoMT2B5NrHlRDrdStEmAhnwW3CrtdkIz2dyUQxlfVgQvGhmF4WcZJE22CxaC3Fn90QDYSTkYHz3kcLE8HB2AvsllIux7dJNt";
    // const version = "2.0";
    // const appId = "72370";

    // const api_url = "https://open.nhanh.vn";
    // const PRODUCT = self::api_url . "/api/product/search";


    // public function import()
    // {
    //     $this->importProducts();
    // }

    // protected function importProducts(array $args = [])
    // {
    //     $products = new Collection;
    //     try {
    //         $args = array_replace([
    //             'icpp' => 50,
    //             'page' => 1,
    //         ], $args);
    //         if ($this->totalPages > 0 && $args['page'] > $this->totalPages) {
    //             return;
    //         }
    //         $products = $this->post(self::PRODUCT, $args);
    //     } catch (\Throwable $th) {
    //         return;
    //         throw $th;
    //     }

    //     $products = collect($products)->map(function ($product) {
    //         try {
    //             $p = new Product($product);
    //             $p->nhanh_id         = $product['idNhanh'];
    //             $p->nhanh_parentId   = $product['parentId'];
    //             $p->nhanh_categoryId = $product['categoryId'];

    //             $p = Product::updateOrCreate(['code' => $p->code], $p->toArray());
    //             Product::where('code', $p->code)->where('id', '<>', $p->id)->delete();
    //         } catch (\Throwable $th) {
    //             return $product;
    //             throw $th;
    //         }
    //     });

    //     $this->importProducts(array_replace($args, [
    //         'page' => $this->currentPage + 1
    //     ]));
    // }

    // /** @deprecated */
    // public function getProducts(array $args = [])
    // {
    //     $products = new Collection;
    //     try {
    //         $args = array_replace([
    //             'icpp' => 50,
    //             'page' => 1,
    //             'sort' => ['code' => 'asc']
    //         ], $args);
    //         if ($this->totalPages > 0 && $args['page'] > $this->totalPages) {
    //             return $products;
    //         }
    //         $products = $this->post(self::PRODUCT, $args);
    //     } catch (\Throwable $th) {
    //     }
    //     $products = collect($products)->map(function ($product) {
    //         try {
    //             $p = new Product($product);
    //             $p->nhanh_id         = $product['idNhanh'];
    //             $p->nhanh_parentId   = $product['parentId'];
    //             $p->nhanh_categoryId = $product['categoryId'];

    //             return Product::updateOrCreate($p->toArray());
    //         } catch (\Throwable $th) {
    //             return $product;
    //         }
    //     });

    //     if ($this->isAll) {
    //         return $products->merge($this->getProducts(
    //             array_replace($args, [
    //                 'page' => $this->currentPage + 1
    //             ])
    //         ));
    //     }

    //     return $products;
    // }

    // public function post($url, array $data = [])
    // {
    //     $response = Http::asForm()->post($url, [
    //         'version'     => self::version,
    //         'appId'       => self::appId,
    //         'businessId'  => $this->businessId,
    //         'accessToken' => $this->accessToken,
    //         'data'        => json_encode($data),
    //     ]);
    //     if ($response['code'] == 0) return array();

    //     $data = $response['data'];
    //     $this->currentPage = $data['currentPage'];
    //     $this->totalPages = $data['totalPages'];

    //     return $data['products'];
    // }

    // protected function isAll(): Attribute
    // {
    //     return Attribute::make(
    //         get: fn (mixed $value) => session('is_all', 0),
    //         // set: fn (mixed $value, array $attributes) => $value ?: Str::sanitizeString($attributes['name'])
    //     );
    // }

    public function new(Request $request)
    {
        $url         = $request->input("url", "https://www.diepxuan.com") ?: "https://www.diepxuan.com";
        $username    = $request->input("username", "admin");
        $password    = $request->input("password", "Ductn@7691");
        $accessToken = Http::asJson()->post($url . self::PATH_TOKEN, [
            'username' => $username,
            'password' => $password,
        ]);

        if ($accessToken) {
            $this->accessToken = $accessToken;
            $this->expiredDateTime = (new DateTime())->modify("+4 hours");
            $this->permissions   = "$username|$password|$url";
        }
        $this->save();
    }

    public function renew(Request $request)
    {
        $permissions = explode('|', $this->permissions);
        $permissions = array_replace([
            'admin',
            'Ductn@7691',
            'https://www.diepxuan.com'
        ], $permissions);
        $permissions = array_replace([
            "url"      => "https://www.diepxuan.com",
            "username" => "admin",
            "password" => "Ductn@7691",
        ], [
            "url"      => $permissions[2],
            "username" => $permissions[0],
            "password" => $permissions[1],
        ]);
        $request->mergeIfMissing($permissions);
        $this->new($request);
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