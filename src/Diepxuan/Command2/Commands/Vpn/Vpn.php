<?php

namespace Diepxuan\Command\Commands\Vpn;

use Illuminate\Console\Command;

class Vpn extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vpn:auto_configuration';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Vpn site to site config';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info($this->getDescription());
    }
}
