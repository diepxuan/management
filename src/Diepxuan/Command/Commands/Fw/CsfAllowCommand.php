<?php

namespace Diepxuan\Command\Commands\Fw;

use Diepxuan\System\OperatingSystem\Csf;
use Diepxuan\Command\Commands\Command;

class CsfAllowCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:csf:allow';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Show CSF Allow list';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info(Csf::getCsfAllowIpLst()->implode("\n"));
    }
}
