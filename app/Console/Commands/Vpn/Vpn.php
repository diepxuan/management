<?php

namespace App\Console\Commands\Vpn;

use Diepxuan\System\OperatingSystem as OS;
use Illuminate\Support\Facades\Log;
use App\Models\Sys\Vm as Model;
use Illuminate\Console\Command;

class Vpn extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vpn:connect';

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
