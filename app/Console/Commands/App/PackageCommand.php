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
        $this->ask('Do you want to build app executable before create package (y/N)', 'y', function ($answer) {
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
            '  [i] Build package and source <fg=green>success</>',
            function () {
                Process::pipe(
                    function (Pipe $pipe) {
                        $pipe->command('dpkg-buildpackage');
                        $pipe->command('dpkg-buildpackage -S');
                    },
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
                    return Process::pipe(
                        function (Pipe $pipe) use ($ppaPath) {
                            $pipe->path($ppaPath)->command('dpkg-scanpackages --multiversion ./ductn >Packages');
                            $pipe->path($ppaPath)->command('gzip -k -f Packages');
                            $pipe->path($ppaPath)->command('apt-ftparchive release . >Release');
                            $pipe->path($ppaPath)->command('gpg --default-key "ductn@diepxuan.com" -abs -o - Release >Release.gpg');
                            $pipe->path($ppaPath)->command('gpg --default-key "ductn@diepxuan.com" --clearsign -o - Release >InRelease');
                            $pipe->path($ppaPath)->command('git add -A');
                            $pipe->path($ppaPath)->command('git commit -m update');
                        },
                        function (string $type, string $output) {
                            $this->output->writeln(trim($output));
                        }
                    );
                },
                false
            );
        });

        $this->ask('Do you want to push package to packagist (y/N)', 'n', function ($answer) use ($ppaPath) {
            if (!Str::of($answer)->isMatch('/[yY]/'))
                return;

            $this->task(
                "  [i] Put <fg=green>Packages</> to ppa success.",
                function () use ($ppaPath) {
                    $packagePath = null;
                    Process::path($ppaPath)->run(
                        'dpkg-scanpackages ductn/ 2>/dev/null | grep "Filename:"',
                        function (string $type, string $output) use (&$packagePath) {
                            $packagePath = trim(str_replace('Filename: ', '', trim($output)));
                        }
                    );
                    $packagePath = Str::of($packagePath)->replace('_amd64.deb', '_source.changes');
                    // $this->output->writeln($packagePath);
                    return Process::path($ppaPath)->timeout(0)->run(
                        "dput ductn-ppa $packagePath",
                        function (string $type, string $output) {
                            $this->output->writeln(trim($output));
                        }
                    );
                },
                false
            );
        });
    }
}
