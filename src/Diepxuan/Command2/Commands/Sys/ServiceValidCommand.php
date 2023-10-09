<?php

namespace Diepxuan\Command\Commands\Sys;

use Diepxuan\System\OperatingSystem\Service;
use Diepxuan\Command\Commands\Command;

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
     * Time format when command will be execute.
     */
    public string $scheduleTimeFormat = 'H:i';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->output->writeln(Service::valid());
    }
}
