<?php

namespace App\Models\Api;

use DateTime;
use Illuminate\Http\Request;
use App\Models\Catalog\Product;
use App\Models\Admin\Api as Model;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use App\Support\Api\Magento2 as Magento2Support;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;

use Diepxuan\Magento\Magento2 as Magento2Api;



class Magento2 extends Model
{
    use HasFactory, Magento2Support;

    const MODEL_TYPE = "magento2";

    const PATH_TOKEN         = "/rest/V1/integration/admin/token";
    const AUTH_TOKEN_REQUEST = "/oauth/token/request";
    const AUTH_TOKEN_ACCESS  = "/oauth/token/access";

    const PRODUCT = "/products";

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = "apis";

    public function import()
    {
        $this->importProducts();
    }

    protected function importProducts(array $args = [])
    {
        $data = $this->request->products()->get();
        // dd($data, $this->request->products());
    }

    protected function request(): Attribute
    {
        return Attribute::make(
            get: fn (mixed $value, array $attributes) => new Magento2Api([
                // 'oauth_consumer_key' => $this->oauth_consumer_key,
                // 'oauth_nonce'        => $this->oauth_consumer_secret,
                // 'oauth_token'        => $this->oauth_access_token,
                // 'oauth_signature'    => $this->oauth_access_secret,
                'consumer_key'    => $this->oauth_consumer_key,
                'consumer_secret' => $this->oauth_consumer_secret,
                'token'           => $this->oauth_access_token,
                'token_secret'    => $this->oauth_access_secret,
            ], [
                'base_uri' => $this->api_url
            ]),
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

        static::addGlobalScope("api." . self::MODEL_TYPE, function (Builder $builder) {
            $builder->where("type", self::MODEL_TYPE);
        });
    }
}