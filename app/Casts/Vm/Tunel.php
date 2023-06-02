<?php

namespace App\Casts\Vm;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;
use App\Models\Sys\Vm;
use App\Helpers\Str;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Symfony\Component\Process\Process;
use File;

class Tunel
{
    const WIREGUARD_PORT = 17691;

    /**
     * Cast the given value.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function get(Vm $model, string $key, mixed $value, array $attributes)
    {
        if ($model->parent->name != "none") return;

        $listenPort = self::WIREGUARD_PORT;

        $addr1 = floor($model->id / 255);
        $addr2 = $model->id % 255;
        $wg0 = <<<EOL
[Interface]
# [$model->id] $model->vm_id
PrivateKey = $model->wg_pri
Address = 10.10.$addr1.$addr2/31
ListenPort = $listenPort
EOL;

        $vms = Vm::all();

        $allowIp = collect([
            "10.10.0.0/30",
            "10.10.0.0/31",
            "10.10.$addr1.0/24",
            "10.10.$addr1.0/31",
        ]);

        $allowIp = $vms->reject(function (Vm $vm) {
            return $vm->parent->name !== "none";
        })->reject(function (Vm $vm) use ($model) {
            return $vm->vm_id == $model->vm_id;
        })->map(function (Vm $vm, int $key) {
            return $vm->gw_subnet;
        })->merge($allowIp)->filter()->unique()->implode(",");

        $wg0 = $vms->reject(function (Vm $vm) {
            return $vm->parent->name !== "none";
        })->reject(function (Vm $vm) use ($model) {
            return $vm->vm_id == $model->vm_id;
        })->map(function (Vm $vm, int $key) use ($allowIp, $listenPort) {
            return <<<EOL
[Peer]
# [$vm->id] $vm->vm_id
PublicKey = $vm->wg_pub
AllowedIPs = $allowIp
Endpoint = $vm->pub_host:$listenPort
EOL;
        })->prepend($wg0)->implode("\n\n");

        return $wg0;
    }

    /**
     * Prepare the given value for storage.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function set(Vm $model, string $key, mixed $value, array $attributes)
    {
        return $value;
    }
}