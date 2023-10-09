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
    protected $signature = 'ip:wan';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Get public wanip of vm';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->line(OS::getIpWan());
    }
}
