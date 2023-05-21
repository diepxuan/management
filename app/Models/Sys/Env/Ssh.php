<?php

namespace App\Models\Sys\Env;

use App\Models\Sys\Vm as Model;
use Illuminate\Support\Facades\Log;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Ssh extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = "vms";

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [];

    /**
     * Make attributes available in the json response.
     *
     * @var array
     */
    protected $appends = [];

    /**
     * The model's default values for attributes.
     *
     * @var array
     */
    protected $attributes = [];

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = true;


    public function getHostAttribute($host)
    {
        $host = $this->name;
        return $host;
    }

    public function getHostNameAttribute($hostName)
    {
        if ($this->parent->name != "none")
            $hostName = collect(explode(' ', trim($this->pri_host)))->last();
        else
            $hostName = $this->pub_host;
        return  $hostName;
    }

    public function getProxyJumpAttribute($proxyJump)
    {
        if ($this->parent->name != "none")
            $proxyJump = $this->parent->name;
        return  $proxyJump;
    }
}