<?php

namespace Diepxuan\Command\Commands;

use Illuminate\Support\Facades\Artisan;
use Diepxuan\Command\Commands\Command;
use Illuminate\Support\Arr;

class run_as_service extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'run_as_service';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Package run as service';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->timer();
    }

    protected function timer($timer = 0)
    {
        collect(config('app.commands', []))
            ->map(function ($timer, $command) {
                try {
                    $this->scheduleCall($command);
                } catch (\Throwable $th) {
                }
            });

        sleep(10 / 1000);

        $this->timer();
    }
}
