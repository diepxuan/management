<?php

namespace Diepxuan\Command\Commands\Vpn\WireGuard;

use Diepxuan\System\OperatingSystem\WireGuard;
use Illuminate\Console\Command;

class Install extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vpn:wireguard:install';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'install missing package for WireGuard';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info($this->getDescription());
        $wg = new WireGuard;
        $wg->install();
    }
}
