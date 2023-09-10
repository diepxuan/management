<?php

namespace App\Console\Commands\Vpn;

use Diepxuan\System\OperatingSystem as OS;
use Illuminate\Support\Facades\Log;
use App\Models\Sys\Vm as Model;
use Illuminate\Console\Command;

class Tailscale extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vpn:tailscale';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'VPN Tailscale configuration';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info($this->getDescription());
    }
}
