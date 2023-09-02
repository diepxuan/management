<?php

namespace App\Console\Commands\Fw;

use Symfony\Component\Console\Output\OutputInterface;
use Diepxuan\System\ConfigServerSecurityFirewall as CSF;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\File;
use Clue\PharComposer\Phar\Packager;
use App\Console\Commands\Command;
use Illuminate\Process\Pipe;
use Illuminate\Support\Str;

class CsfInstallCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:csf:install';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Install and configuration ConfigServer Security & Firewall (CSF)';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $csf = new CSF;

        $this->call('app:ufw:uninstall');

        if ($csf->isInstall) {
            $this->output->writeln(sprintf("  [i] CSF version <fg=green>%s</> installed.", $csf->version));
        }

        // Process::run(
        //     'sudo csf -v',
        //     function (string $type, string $output) {
        //         $this->output->writeln(trim($output));
        //     }
        // );
    }
}
