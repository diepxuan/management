<?php

namespace App\Console\Commands;

use Illuminate\Support\Facades\Artisan;
use Illuminate\Console\Command;

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
    protected $description = 'Command description';

    private $timer = [
        'do_every_minute' => ["H:i", null],
        'do_every_second' => ["H:i:s", null],
    ];

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->timer();
    }

    protected function timer($timer = 0)
    {
        $t = time();
        foreach ($this->timer as $methodTodo => $timeTodo) {
            if (!is_callable(__CLASS__ . "::" . $methodTodo)) continue;
            if ($timeTodo[1] == date($timeTodo[0], $t)) continue;

            $this->$methodTodo();
            $this->timer[$methodTodo][1] = date($this->timer[$methodTodo][0], $t);
        }
        sleep(1);
        $this->timer();
    }

    protected function do_every_minute()
    {
        // $this->info(__METHOD__ . $this->timer[__FUNCTION__][1]);

        $this->call('vm:update');
        $this->call('app:csf:config');
        $this->call('sys:service:valid');
    }
    protected function do_every_second()
    {
        // $this->info(__METHOD__ . $this->timer[__FUNCTION__][1]);
        // Artisan::call('vm:update');
    }
}
