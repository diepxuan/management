<?php

namespace App\Console\Commands\Sys;

use Diepxuan\System\OperatingSystem as OS;
use Illuminate\Console\Command;

class SwapOnCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'sys:swap:on';

    /**
     * The console command name aliases.
     *
     * @var array
     */
    protected $aliases = 'sys:swapon';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Enable Swap Storage for vm.';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->output->writeln(OS::sysSwapOn());
    }
}
