<?php

namespace Diepxuan\Command\Commands\Fw;

use Diepxuan\System\OperatingSystem\ConfigServerSecurityFirewall as CSF;
use Illuminate\Support\Facades\Process;
use Diepxuan\Command\Commands\Command;
use Illuminate\Process\Pipe;

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
            return 0;
        }

        $this->output->writeln("  [i] CSF not <fg=red>installed</>.");

        $this->task(
            sprintf("  [i] CSF version <fg=green>%s</> installed.", $csf->version),
            function () {
                return Process::pipe(
                    function (Pipe $pipe) {
                        $pipe->command('curl http://download.configserver.com/csf.tgz -o /tmp/ductn/csf.tgz');
                        $pipe->command('tar -xzf /tmp/ductn/csf.tgz -C /tmp/ductn');
                        $pipe->path('/tmp/ductn/csf')->command('sudo sh install.sh');
                    },
                    function (string $type, string $output) {
                        $this->output->writeln(trim($output));
                    }
                );
            },
            false
        );

        $this->task(
            sprintf("  [i] Fix missing iptables for CSF command.", $csf->version),
            function () use ($csf) {
                return $csf->iptables();
            },
            false
        );
    }
}
