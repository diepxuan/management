<?php

namespace App\Models\Api;

use DateTime;
use Illuminate\Http\Request;
use App\Models\Catalog\Product;
use App\Models\Admin\Api as Model;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use App\Support\Api\Magento2 as Support;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;

use GuzzleHttp\Client;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Subscriber\Oauth\Oauth1;


class Magento2 extends Model
{
    use HasFactory, Support;

    // Consumer Key
    // b1lb7h7glitzdbiuifuqzp3ag0wxa8us
    // Consumer Secret
    // kyi46b4cfilwa2pnsqqjyyx2yuhykqqe
    // Access Token
    // hmoknijge5xq7fm0pubuuo9ydsqtbm5f
    // Access Token Secret
    // nk02powcydxpbd790ua3pu4gksgesrnk

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
        // dd($this);
        Log::info($this->api_url);
        $data = $this->client()->get($this->product_url, [
            'searchCriteria' => [
                'PageSize' => 20
            ]
        ]);
        Log::info($data);
    }

    public function client()
    {
        $stack = HandlerStack::create();

        $middleware = new Oauth1([
            'consumer_key'    => $this->oauth_consumer_key,
            'consumer_secret' => $this->oauth_consumer_secret,
            'token'           => $this->oauth_access_token,
            'token_secret'    => $this->oauth_access_secret,
            'signature_method' => Oauth1::SIGNATURE_METHOD_HMACSHA256,
        ]);
        $stack->push($middleware);

        $client = new Client([
            'base_uri' => $this->api_url,
            'handler' => $stack,
            'auth' => 'oauth'
        ]);

        return $client;

        // Now you don't need to add the auth parameter
        $response = $client->get(self::PRODUCT);

        // $response = Http::withBasicAuth($this->oauth_consumer_key, $this->oauth_consumer_secret)
        //     ->withToken($this->oauth_access_token)
        //     // ->withHeaders([
        //     //     'Authorization' => "Bearer " . $this->accessToken,
        //     //     // 'Bearer'        => $this->accessToken,
        //     // ])
        //     ->get($url, $data);

        if ($response->successful())
            return $response;

        $response->throw(function ($response, $e) {
            Log::info($response);
        });
        return [];
    }

    protected function productUrl(): Attribute
    {
        return Attribute::make(
            get: fn (mixed $value, array $attributes) => implode('/', [$this->api_url, ltrim(self::PRODUCT, " \\/")]),
        );
    }

    protected function urlTokenRequest(): Attribute
    {
        return Attribute::make(
            get: fn (mixed $value, array $attributes) =>
            $this->api_url . self::AUTH_TOKEN_REQUEST,
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