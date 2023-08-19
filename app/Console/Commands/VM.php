<?php

namespace App\Console\Commands;

use App\Models\OperatingSystem as OS;
use Illuminate\Support\Facades\Log;
use App\Models\Sys\Vm as Model;
use Illuminate\Console\Command;

class VM extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vm:update';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Update this vm info';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info("  Vm informations");
        $os = new OS();
        $vm = Model::updateOrCreate(["vm_id" => $os->hostFullName]);
        $vm->name = $os->hostName;
        $vm->pri_host = $os->ipLocal;
        $vm->pub_host = $os->ipWan;
        $vm->version  = $os->appVersion;

        // $gateway      = explode(" ", $request->input("gateway"));
        // $vm->gateway  = count($gateway) > 0 ? $gateway : $vm->gateway;

        // $wg_key       = explode(" ", $request->input("wg_key"));
        // $vm->wgkey    = count($wg_key) > 0 ? $wg_key : $vm->wgkey;

        // dd($vm);
        $vm->touch();
        $vm->save();
    }
}
