<?php

namespace App\Helpers\Pagination;

use Illuminate\Pagination\LengthAwarePaginator as Helper;

class LengthAwarePaginator extends Helper
{
    /**
     * Get the total number of items being paginated.
     *
     * @return int
     */
    public function setTotal($total)
    {
        $this->total = $total;
    }
}