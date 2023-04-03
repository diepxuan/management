<?php

namespace App\Models\Admin;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Models\Sys\Vm as Model;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Log;

class Vm extends Model
{
    use HasFactory;

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
            // $builder->where("vm_id", $hostname);
        });
    }
}
