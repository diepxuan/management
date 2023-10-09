<?php

namespace Diepxuan\Command\Commands;

use Illuminate\Console\Command;

class HideCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'hide-command {cmd}';

    /**
     * The console command description.
     *
     * @var string|null
     */
    protected $description = 'Hide a Laravel command';

    /**
     * Indicates whether the command should be shown in the Artisan command list.
     *
     * @var bool
     */
    protected $hidden = true;

    public function handle()
    {
        $command = $this->argument('cmd');

        $this->laravel['config']->set('app.hidden', [
            $command,
        ]);

        $this->info('The command `' . $command . '` has been hidden');
    }
}
