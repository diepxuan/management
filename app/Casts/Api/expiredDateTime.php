<?php

namespace App\Casts\Api;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Arr;
use App\Models\Admin\Api;
use DateTime;

class expiredDateTime
{
    /**
     * Cast the given value.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function get(Api $model, string $key, mixed $value, array $attributes)
    {
        return DateTime::createFromFormat(Api::DATETIMEFORMAT, $value) ?: $value;
    }

    /**
     * Prepare the given value for storage.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function set(Api $model, string $key, mixed $value, array $attributes)
    {
        if (is_string($value)) {
            $value = new DateTime($value);
        }
        if ($value instanceof DateTime) {
            return $value->format(Api::DATETIMEFORMAT);
        }
        return $value->format(Api::DATETIMEFORMAT);
    }
}