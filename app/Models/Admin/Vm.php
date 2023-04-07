<?php

namespace App\Models\Admin;

use App\Models\Sys\Vm as Model;
use Illuminate\Support\Facades\Log;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Vm extends Model
{
    use HasFactory;

    public static function all($columns = ['*'])
    {
        $vms = parent::all(
            is_array($columns) ? $columns : func_get_args()
        );

        return $vms;
    }

    /**
     * The "booting" method of the model.
     *
     * @return void
     */
    protected static function boot()
    {
        parent::boot();

        static::addGlobalScope("vm.admin", function (Builder $builder) {
            // $hostname = trim(shell_exec("ductn host:fullname"));
            // $builder->whereNull("parent_id");
        });
    }
}