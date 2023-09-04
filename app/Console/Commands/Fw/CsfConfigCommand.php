<?php

namespace App\Console\Commands\Fw;

use Symfony\Component\Console\Output\OutputInterface;
use Diepxuan\System\ConfigServerSecurityFirewall as CSF;
use Diepxuan\System\Vm;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\File;
use Clue\PharComposer\Phar\Packager;
use App\Console\Commands\Command;
use Illuminate\Process\Pipe;
use Illuminate\Support\Str;

class CsfConfigCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:csf:config';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Configuration ConfigServer Security & Firewall (CSF)';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        if (!CSF::isInstalled()) {
            $this->call('app:csf:install');
        }
        CSF::apply();
    }
}
