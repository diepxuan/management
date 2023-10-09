<?php

namespace Diepxuan\Command\Commands\Vpn;

use Illuminate\Console\Command;

class WireGuard extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vpn:wireguard';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'VPN WireGuard configuration';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info($this->getDescription());
    }
}
