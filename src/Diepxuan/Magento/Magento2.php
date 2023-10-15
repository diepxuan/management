<?php

namespace Diepxuan\Magento;

use Diepxuan\Magento\Builders\CustomerAddressBuilder;
use Diepxuan\Magento\Builders\CustomerBuilder;
use Diepxuan\Magento\Builders\CustomerGroupBuilder;
use Diepxuan\Magento\Builders\OrderBuilder;
use Diepxuan\Magento\Builders\ProductBuilder;
use Diepxuan\Magento\Utils\Request;

class Magento2
{
    /**
     * @var $request \Diepxuan\Magento\Utils\Request
     */
    protected $request;

    /**
     * Rackbeat constructor.
     *
     * @param null  $token   API token
     * @param array $options Custom Guzzle options
     * @param array $headers Custom Guzzle headers
     */
    public function __construct($token, $options = [], $headers = [])
    {
        $this->initRequest($token, $options, $headers);
    }

    /**
     * @param       $token
     * @param array $options
     * @param array $headers
     */
    private function initRequest($token, $options = [], $headers = []): void
    {
        $this->request = new Request($token, $options, $headers);
    }

    /**
     * @return OrderBuilder
     */
    public function orders(): OrderBuilder
    {
        return new OrderBuilder($this->request);
    }

    /**
     * @return CustomerBuilder
     */
    public function customers(): CustomerBuilder
    {
        return new CustomerBuilder($this->request);
    }

    /**
     * @return CustomerAddressBuilder
     */
    public function customer_addresses(): CustomerAddressBuilder
    {
        return new CustomerAddressBuilder($this->request);
    }

    /**
     * @return ProductBuilder
     */
    public function products(): ProductBuilder
    {
        return new ProductBuilder($this->request);
    }

    /**
     * @return CustomerGroupBuilder
     */
    public function customer_groups(): CustomerGroupBuilder
    {

        return new CustomerGroupBuilder($this->request);
    }
}