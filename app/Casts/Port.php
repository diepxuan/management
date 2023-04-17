<?php

namespace App\Casts;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;
use App\Models\Sys\Vm;

class Port
{
    /**
     * Cast the given value.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function get(Vm $model, string $key, mixed $value, array $attributes)
    {
        $value = $value ?: '';
        $value = explode(':', $value);
        $value = array_replace(['', ''], $value);
        $tcp = $value[0];
        $udp = $value[1];
        return [
            'tcp' => $tcp,
            'udp' => $udp,
        ];
    }

    /**
     * Prepare the given value for storage.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function set(Vm $model, string $key, mixed $value, array $attributes)
    {
        $value = array_filter($value);
        $value = array_replace($model->port, $value);
        $value = array_replace(['tcp' => '', 'udp' => ''], $value);
        $value = implode(':', $value);
        return $value;
    }
}