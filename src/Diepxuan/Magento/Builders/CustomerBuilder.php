<?php

namespace Diepxuan\Magento\Builders;

use Diepxuan\Magento\Models\Customer;

class CustomerBuilder extends Builder
{
    protected $entity = 'customers';
    protected $model  = Customer::class;

    public function get($filters = [])
    {
        $urlFilters = $this->parseFilters($filters);

        return $this->request->handleWithExceptions(function () use ($urlFilters) {

            $response     = $this->request->client->get("{$this->entity}/search{$urlFilters}");
            $responseData = json_decode((string) $response->getBody());
            $items        = $this->parseResponse($responseData);

            return $items;
        });
    }
}