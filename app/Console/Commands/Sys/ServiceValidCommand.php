<?php

namespace App\Console\Commands\Sys;

use Diepxuan\System\OperatingSystem\Service;
use Illuminate\Console\Command;

class ServiceValidCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'sys:service:valid';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Valid and restart services running in this system.';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->output->writeln(Service::valid());
    }
}
