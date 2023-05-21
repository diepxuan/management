<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Models\Admin;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;
use Laravel\Sanctum\HasApiTokens;

class Ddns extends Model
{
    use HasFactory;
    use HasApiTokens;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'ddns';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'email',
        'api',
        'apiUrl',
        'service',
    ];

    /**
     * Make attributes available in the json response.
     *
     * @var array
     */
    protected $appends = [];

    /**
     * The model's default values for attributes.
     *
     * @var array
     */
    protected $attributes = [
        'service' => 'CloudFlare'
    ];

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = true;

    private $zoneLst = [];
    private $dnsLst = [];

    public function userDetail($fields = null)
    {
        if (isset($fields) && !empty($fields) && null != $fields) {
            return $this->curlRequest('/user', $fields, 'PATCH');
        }

        return $this->curlRequest('/user');
    }

    public function userBilling()
    {
        return $this->curlRequest('/user/billing/profile');
    }

    public function userBillingHistory()
    {
        return $this->curlRequest('/user/billing/history');
    }

    public function userBillingApp()
    {
        return $this->curlRequest('/user/billing/subscriptions/apps');
    }

    public function userBillingAppZone()
    {
        return $this->curlRequest('/user/billing/subscriptions/zones');
    }

    public function dns($zone_identifier = '', $identifier = '')
    {
        if (isset($zone_identifier) && !empty($zone_identifier) && '' != $zone_identifier) {
            if (isset($identifier) && !empty($identifier) && '' != $identifier) {
                $dns_record = $this->curlRequest("/zones/{$zone_identifier}/dns_records/{$identifier}");
                return [$dns_record->result->id => $dns_record->result];
            }

            $dns_records = $this->curlRequest("/zones/{$zone_identifier}/dns_records");
            $dns_records = $dns_records->result;
            $result = [];
            foreach ($dns_records as $key => $dns_record) {
                $identifier = $dns_record->id;
                $result[$identifier] = $dns_record;
            }

            return $result;
        }
        $zones = $this->zone();
        $this->zoneLst = $zones->result;
        foreach ($this->zoneLst as $key => $zone) {
            $zone_identifier = $zone->id;
            $dnsLst = $this->dns($zone_identifier);
            foreach ($dnsLst as $key => $dns) {
                $this->dnsLst[$key] = $dns;
            }
        }

        return $this->dnsLst;
    }

    public function dnsUpdate($zone_identifier = null, $identifier = null, $content = null)
    {
        return $this->curlRequest("/zones/{$zone_identifier}/dns_records/{$identifier}", $content, 'PATCH');
    }

    public function run()
    {
        $this->zoneLst = $this->dns();
        $results = [];
        foreach ($this->zoneLst as $zone_identifier => $identifiers) {
            foreach ($identifiers as $identifier => $fields) {
                $_content_old = $fields->content;
                $_content_new = urlencode(trim($this->getCurrentIp(), " \t\n\r\0\x0B"));
                if ($_content_old != $_content_new) {
                    $fields->content = $_content_new;
                    $fields->data = new \stdClass();
                    unset($fields->meta);
                    $result = $this->curlRequest(sprintf('/zones/%s/dns_records/%s', $zone_identifier, $identifier), $fields, 'PUT');
                    $results[$fields->name . '->' . $_content_old] = $result;
                }
            }
        }

        return $results;
    }
}