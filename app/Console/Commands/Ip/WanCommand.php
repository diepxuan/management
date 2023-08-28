<?php

namespace App\Console\Commands\Ip;

use App\Models\OperatingSystem as OS;
use Illuminate\Console\Command;

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
        $os = new OS();
        $this->line("$os->ipWan");
    }
}
