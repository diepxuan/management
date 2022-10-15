<?php

namespace App\Repositories\Dyndns\Services;

class BaseService extends \App\Repositories\Dyndns\DdnsRepository
{
    public function __construct(\App\Models\Dyndns\Ddns $ddns)
    {
    }

    public function curlRequest($url, $fields = null, $method = 'POST')
    {
    }

    public function zones($identifier = '')
    {
        if (isset($identifier) && !empty($identifier) && '' != $identifier) {
            $result = $this->curlRequest("/zones/{$identifier}");
        } else {
            $result = $this->curlRequest('/zones');
        }

        return $result;
    }
}
