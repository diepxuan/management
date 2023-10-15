<?php

namespace Diepxuan\Magento\Builders;

use Diepxuan\Magento\Models\Product;

class ProductBuilder extends Builder
{
    protected $entity = 'products';
    protected $model  = Product::class;
}