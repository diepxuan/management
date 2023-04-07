<?php

namespace App\Models\Sys;

use Illuminate\Support\Facades\Log;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Models\Sys\Env\Domain;

class Vm extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'vm_id',
        'parent_id',
        'name',
        'pri_host',
        'pub_host',
        'gateway',
        'version',
        'is_allow',
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
     * The primary key associated with the table.
     *
     * @var string
     */
    protected $primaryKey = 'vm_id';

    /**
     * The data type of the auto-incrementing ID.
     *
     * @var string
     */
    protected $keyType = 'string';

    public function getIsRootAttribute($is_root)
    {
        return $this->pri_host = $this->pub_host;
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(
            Vm::class,
            'parent_id',
            'vm_id'
        )->withDefault([
            'name' => 'none',
        ]);
    }

    public function clients(): HasMany
    {
        return $this->hasMany(
            Vm::class,
            "parent_id",
            "vm_id"
        );
    }

    public function getDomainsAttribute($domains)
    {
        $_domains = Domain::all();
        foreach ($_domains as $domain) {
            $domain = $domain->name;
            $domains .= "$domain";
            $domains .= "\n";
        }
        $domains = trim($domains);
        return $domains;
    }

    public function getSshdConfigAttribute($sshdConfig)
    {
        $vms = \App\Models\Sys\Env\Ssh::all();
        foreach ($vms as $vm) {
            // $vm = $vm->host;
            $sshdConfig .= "Host $vm->host\n";
            $sshdConfig .= "  User ductn\n";
            $sshdConfig .= "  HostName $vm->hostName\n";
            if ($vm->proxyJump)
                $sshdConfig .= "  ProxyJump $vm->proxyJump\n";
            $sshdConfig .= "\n";
        }
        $sshdConfig = trim($sshdConfig);
    }
}