<?php

namespace Diepxuan\Command\Commands\Log;

use Illuminate\Support\Facades\Process;
use Diepxuan\Command\Commands\Command;

class Watch extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'log:watch';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Watch log';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $result = Process::run('sudo journalctl -u ductnd.service -f', function (string $type, string $output) {
            echo $output;
        });
    }
}
