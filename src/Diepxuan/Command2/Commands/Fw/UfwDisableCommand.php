<?php

namespace Diepxuan\Command\Commands\Fw;

use Symfony\Component\Console\Output\OutputInterface;
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\File;
use Clue\PharComposer\Phar\Packager;
use Diepxuan\Command\Commands\Command;
use Illuminate\Process\Pipe;

class UfwDisableCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:ufw:disable';

    /**
     * The console command name aliases.
     *
     * @var array
     */
    protected $aliases = 'app:ufw:uninstall';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Disable Uncomplicated Firewall (UFW)';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->task(
            "  [i] Disable <fg=green>UFW</> success.",
            function () {
                return Process::run(
                    'sudo ufw disable',
                    function (string $type, string $output) {
                        $this->output->writeln(trim($output));
                    }
                );
            },
            false
        );
    }
}
