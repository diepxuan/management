<?php

namespace App\Support\Api;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Support\Facades\Http;
use Illuminate\Http\Request;
use DateTime;

trait Magento2
{
    const MODEL_TYPE = "magento2";
    const PATH_TOKEN = "/rest/V1/integration/admin/token";

    protected function apiUrl(): Attribute
    {
        return Attribute::make(
            get: fn (mixed $value, array $attributes) => trim($value ?: array_replace([null, null, null], explode('|', $this->permissions))[0], " \\/") . '/',
        );
    }

    protected function oauthConsumerKey(): Attribute
    {
        return Attribute::make(
            get: fn (mixed $value, array $attributes) => $value ?: array_replace([null, null, null], explode('|', $this->permissions))[1],
        );
    }

    protected function oauthConsumerSecret(): Attribute
    {
        return Attribute::make(
            get: fn (mixed $value, array $attributes) => $value ?: array_replace([null, null, null], explode('|', $this->permissions))[2],
        );
    }

    protected function oauthAccessToken(): Attribute
    {
        return Attribute::make(
            get: fn (mixed $value, array $attributes) => $value ?: array_replace([null, null], explode('|', $this->accessToken))[0],
        );
    }

    protected function oauthAccessSecret(): Attribute
    {
        return Attribute::make(
            get: fn (mixed $value, array $attributes) => $value ?: array_replace([null, null], explode('|', $this->accessToken))[1],
        );
    }

    public function new(Request $request)
    {
        // Create Magento 2 Oauth
        $url                   = $request->input("url");
        $url                   = trim($url, " \\/");
        $oauth_consumer_key    = $request->input("oauth_consumer_key");
        $oauth_consumer_secret = $request->input("oauth_consumer_secret");
        $oauth_access_token    = $request->input("oauth_access_token");
        $oauth_access_secret   = $request->input("oauth_access_secret");

        $this->type            = self::MODEL_TYPE;
        $this->accessToken     = implode('|', [$oauth_access_token, $oauth_access_secret]);
        $this->permissions     = implode('|', [$url, $oauth_consumer_key, $oauth_consumer_secret]);
        $this->expiredDateTime = new DateTime("now +1 yaer");

        $this->save();
        return redirect()->route('admin.api.index');
    }

    /** @deprecated */
    public function newAdminToken(Request $request)
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
            $this->permissions   = "$url|$username|$password";
        }
        $this->save();
    }
}