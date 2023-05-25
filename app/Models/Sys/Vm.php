<?php

/**
 * @copyright © 2023 DiepXuan. All rights reserved.
 * @author Tran Ngoc Duc <caothu91@gmail.com>
 *
 * Created on Thu May 25 2023 16:29:59
 */

namespace App\Models\Sys;

use App\Helpers\Str;
use App\Models\Admin\Ddns;
use App\Models\Sys\Env\Domain;
use Illuminate\Support\Facades\Log;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

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
        'port',
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
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'csf'         => \App\Casts\Vm\Csf::class,
        'port'        => \App\Casts\Vm\Port::class,
        'portopen'    => \App\Casts\Vm\Portopen::class,
        'portforward' => \App\Casts\Vm\Portforward::class,
    ];

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

    public function getNameAttribute($name)
    {
        $name = $name ?: $this->vm_id;
        return $name;
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
            $sshdConfig .= "Host $vm->host\n";
            $sshdConfig .= "  User ductn\n";
            $sshdConfig .= "  HostName $vm->hostName\n";
            if ($vm->proxyJump)
                $sshdConfig .= "  ProxyJump $vm->proxyJump\n";
            $sshdConfig .= "\n";
        }
        $sshdConfig = trim($sshdConfig);
    }

    /**
     * The roles that belong to the ddns.
     */
    public function ddnses(): BelongsToMany
    {
        return $this->belongsToMany(Ddns::class, 'ddns_vm', 'vm', 'ddns');
    }

    public function dnsUpdate()
    {
        $identifier = $this->vm_id;
        $content    = $this->pub_host;
        $this->ddnses->each(function ($item, int $key) use ($identifier, $content) {
            $item = $item->castAs();

            $item->dnsUpdate(null, $identifier, $content);
        });
    }
}