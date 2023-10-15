<?php

namespace Diepxuan\Magento\Builders;

use Diepxuan\Magento\Models\CustomerGroup;

class CustomerGroupBuilder extends Builder
{
    protected $entity = 'customerGroups';
    protected $model  = CustomerGroup::class;

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