<?php

namespace App\Helpers;

use Illuminate\Database\Eloquent\Model;

class DomainHelper extends Model
{
    /**
     * Create a new helper instance.
     *
     * @return void
     */
    public function __construct()
    {
        //
    }

    /**
     * Determine if the validation rule passes.
     *
     * @param  mixed  $value
     * @return bool
     */
    public function fqdnCheck($value)
    {
        return preg_match('/^(?!:\/\/)(?=.{1,255}$)((.{1,63}\.){1,127}(?![0-9]*$)[a-z0-9-]+\.?)$/i', $value);
    }
}
