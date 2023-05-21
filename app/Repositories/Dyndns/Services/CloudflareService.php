<?php

namespace App\Repositories\Dyndns\Services;

use Illuminate\Support\Facades\Log;

class CloudflareService extends \App\Repositories\Dyndns\Services\BaseService
{
    /** @var App\Models\Admin\Ddns */
    private $ddns;

    public function __construct(\App\Models\Admin\Ddns $ddns)
    {
        $this->ddns = $ddns;
    }

    public function curlRequest($url, $fields = null, $method = 'POST')
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->ddns->apiUrl . $url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            "X-Auth-Email: {$this->ddns->email}",
            "X-Auth-Key: {$this->ddns->api}",
            'Content-Type: application/json',
        ]);

        if (isset($fields) && !empty($fields)) {
            $fields_string = json_encode($fields);

            if ('POST' != $method) {
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
            } else {
                curl_setopt($ch, CURLOPT_POST, count($fields));
            }
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
        }

        $result = curl_exec($ch);
        if (curl_errno($ch)) {
            Log::debug(curl_error($ch));
        }
        curl_close($ch);

        return json_decode($result);
    }
}