<?php

namespace Diepxuan\Command\Commands\Vpn;

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
