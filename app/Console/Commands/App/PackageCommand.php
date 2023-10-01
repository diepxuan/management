<?php

namespace App\Console\Commands\App;

use Diepxuan\Command\Commands\Command;
use Symfony\Component\Console\Output\OutputInterface;
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\File;
use Symfony\Component\Finder\Finder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use Illuminate\Process\Pipe;
use Illuminate\Process\Pool;

class PackageCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:package';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Build debian package';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->ask('Do you want to build app libraries before create package (y/N)', 'y', function ($answer) {
            if (Str::of($answer)->isMatch('/[yY]/')) {
                $this->call('app:build');
            }
        });

        $this->task(
            '  [i] Update time into <fg=green>debian/changelog</>',
            function () {
                $date = Carbon::now()->toRssString(); // Sat, 19 Aug 2023 19:01:36 +0700
                $log = File::get(base_path('debian/changelog'));
                $log = preg_replace('/<ductn@diepxuan.com>  .*/', "<ductn@diepxuan.com>  $date", $log, 1);
                File::put(base_path('debian/changelog'), $log);
            }
        );

        $this->task(
            '  [i] Build <fg=green>app executable</>',
            function () {
                $source = base_path('ductn.sh');
                $target = base_path('ductn');
                File::copy($source, $target);
            }
        );

        $this->task(
            '  [i] Build <fg=green>package</> success',
            function () {
                Process::timeout(0)->run(
                    'dpkg-buildpackage',
                    function (string $type, string $output) {
                        $this->output->writeln(trim($output));
                    }
                );
            }
        );

        $this->task(
            '  [i] Build <fg=green>source</> success',
            function () {
                Process::timeout(0)->run(
                    'dpkg-buildpackage -S',
                    function (string $type, string $output) {
                        $this->output->writeln(trim($output));
                    }
                );
            }
        );

        $ppaPath = realpath(base_path('..' . DIRECTORY_SEPARATOR . 'ppa'));

        $this->ask('Do you want to push package to ppa (y/N)', 'y', function ($answer) use ($ppaPath) {
            if (!Str::of($answer)->isMatch('/[yY]/'))
                return;

            $this->task(
                '  [i] Move <fg=green>package</> to ppa folder success',
                function () use ($ppaPath) {
                    foreach (File::files(realpath(base_path('..')), 1) as $file) {
                        $filename = $file->getRelativePathname();
                        $source   = $file->getRealPath();
                        $target   = $ppaPath . DIRECTORY_SEPARATOR . 'ductn' . DIRECTORY_SEPARATOR . $file->getRelativePathname();
                        File::move($source, $target);
                        $this->output->writeln("    Move <fg=green>$filename</> to ppa");
                    }
                }
            );

            $this->task(
                "  [i] Create <fg=green>Packages</>, <fg=green>Release</> file in ppa folder.",
                function () use ($ppaPath) {
                    return Process::pool(
                        function (Pool $pool) use ($ppaPath) {
                            $pool->timeout(0)->path($ppaPath)->command('dpkg-scanpackages --multiversion ./ductn >Packages');
                            $pool->timeout(0)->path($ppaPath)->command('gzip -k -f Packages');
                            $pool->timeout(0)->path($ppaPath)->command('apt-ftparchive release . >Release');
                            $pool->timeout(0)->path($ppaPath)->command('gpg --default-key "ductn@diepxuan.com" -abs -o - Release >Release.gpg');
                            $pool->timeout(0)->path($ppaPath)->command('gpg --default-key "ductn@diepxuan.com" --clearsign -o - Release >InRelease');
                            $pool->timeout(0)->path($ppaPath)->command('git add -A');
                            $pool->timeout(0)->path($ppaPath)->command('git commit -m update');
                        },
                        function (string $type, string $output) {
                            $this->output->writeln(trim($output));
                        }
                    );
                },
                false
            );
        });

        $this->ask('Do you want to push package to packagist (y/N)', 'y', function ($answer) use ($ppaPath) {
            if (!Str::of($answer)->isMatch('/[yY]/'))
                return;

            $this->task(
                "  [i] Put <fg=green>Packages</> to ppa success.",
                function () use ($ppaPath) {
                    $packagePath = Process::path($ppaPath)
                        ->run(
                            'dpkg-scanpackages ductn/ 2>/dev/null | grep "Filename:" | sed "s|Filename: ||g"'
                        )->output();
                    $packagePath = Str::of($packagePath)->trim()
                        ->replace('_amd64.deb', '_source.changes')
                        ->explode("\n")
                        ->map(fn ($package) => Process::path($ppaPath)->timeout(0)->run(
                            "dput ductn-ppa $package",
                            function (string $type, string $output) {
                                $this->output->writeln(trim($output));
                            }
                        ));
                },
                false
            );
        });
    }
}
