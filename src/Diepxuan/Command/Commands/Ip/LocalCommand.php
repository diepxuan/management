<?php

namespace Diepxuan\Command\Commands\Ip;

use Diepxuan\System\OperatingSystem as OS;
use Diepxuan\Command\Commands\Command;

class WanCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'ip:local';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Get private local ip of vm';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->line(OS::getIpLocalAll());
    }
}
