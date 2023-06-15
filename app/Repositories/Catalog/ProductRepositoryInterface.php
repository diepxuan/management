<?php

namespace App\Repositories\Catalog;

use Illuminate\Support\Collection;
use App\Models\Admin\Api;

interface ProductRepositoryInterface
{
    public function getProducts(mixed $options = []);
}