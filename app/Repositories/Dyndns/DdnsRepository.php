<?php

/**
 * Copyright © DiepXuan, Ltd. All rights reserved.
 */

namespace App\Repositories\Dyndns;

use Illuminate\Support\Facades\Log;
use App\Models\Dyndns\Ddns;

class DdnsRepository implements DdnsRepositoryInterface
{

    /** @App\Models\Dyndns\Ddns */
    private $ddns;

    /** @App\Repositories\Dyndns\Services\BaseService */
    private $service;

    public function __construct()
    {
    }

    public function getDdns()
    {
        if (!$this->ddns) {
            $this->ddns = Ddns::firstOrNew();
        }
        return $this->ddns;
    }

    public function getService()
    {
        if (!$this->service) {
            $service = ucfirst(strtolower($this->getDdns()->service));
            $repository = __NAMESPACE__ . "\\Services\\${service}Service";
            $repository = new $repository($this->ddns);
            $this->service = $repository;
        }
        return $this->service;
    }

    public function getZones()
    {
        return $this->getService()->zones();
    }
}