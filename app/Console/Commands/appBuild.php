<?php

namespace App\Console\Commands;

use Illuminate\Support\Facades\Process;
use Illuminate\Console\Command;
use Illuminate\Process\Pipe;

class appBuild extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:build';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Build this app';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        Process::pipe([
            'composer run build',
            'cat debian/changelog | sed -e "0,/<ductn@diepxuan.com>  .*/ s/<ductn@diepxuan.com>  .*/<ductn@diepxuan.com>  $(date -R)/g" >debian/changelog',
            'dpkg-buildpackage',
            'dpkg-buildpackage -S',
            'mv ../ductn* ../ppa/ductn/',
        ], function (string $type, string $output) {
            $output ?? $this->line(trim($output));
        });

        collect([
            'dpkg-scanpackages --multiversion ./ductn >Packages',
            'dpkg-scanpackages --multiversion ./ductn >Packages',
            'gzip -k -f Packages',
            'apt-ftparchive release . >Release',
            'gpg --default-key "ductn@diepxuan.com" -abs -o - Release >Release.gpg',
            'gpg --default-key "ductn@diepxuan.com" --clearsign -o - Release >InRelease',
            'git add -A',
            'git commit -m update',

            'dput ductn-ppa $(ls /var/www/ppa/*/*source.changes | sort -V | tail -n 1)',
        ])->map(function (string $cmd) {
            Process::path('../ppa/')->run($cmd, function (string $type, string $output) {
                $output ?? $this->line(trim($output));
            });
        });
    }
}
