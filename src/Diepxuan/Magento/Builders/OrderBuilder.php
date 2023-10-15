<?php

namespace Diepxuan\Magento\Builders;

use Diepxuan\Magento\Models\Order;

class OrderBuilder extends Builder
{
    protected $entity = 'orders';
    protected $model  = Order::class;
}