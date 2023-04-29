<?php

namespace App\Models\Admin;

use Illuminate\Http\Request;
use App\Models\Sys\Env\Domain;
use Illuminate\Support\Facades\Log;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Api extends Model
{
    use HasFactory;

    const DATETIMEFORMAT = 'Y-m-d H:i:s';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'type',
        'accessToken',
        'expiredDateTime', // Y-m-d H:i:s
        'businessId',
        'depotIds',
        'permissions',
        'enable',
    ];

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

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'expiredDateTime' => \App\Casts\Api\expiredDateTime::class,
    ];

    public function castAs(mixed $className = null)
    {
        if ($className == null) {
            $className = $this->type;
            $className = ucfirst(strtolower($this->type));
            $className = "\App\Models\Api\\$className";
        }

        $obj = new $className($this->toArray());
        // foreach (get_object_vars($this) as $key => $name) {
        // $obj->$key = $name;
        // }
        return $obj;
    }

    public function new(Request $request)
    {
        //
    }

    public function renew(Request $request)
    {
        //
    }

    public static function scopeEnable(Builder $query, $arg = 1)
    {
        return $query->where('enable', $arg);
    }
}