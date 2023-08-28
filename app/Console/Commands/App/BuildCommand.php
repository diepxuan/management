<?php

namespace App\Console\Commands\App;

use Symfony\Component\Console\Output\OutputInterface;
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\File;
use Clue\PharComposer\Phar\Packager;
use App\Console\Commands\Command;
use Illuminate\Process\Pipe;

class BuildCommand extends Command
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
    protected $description = 'Build a single app executable';

    /**
     * The binary file path.
     */
    private const BINARY_FILE = __DIR__ . DIRECTORY_SEPARATOR . 'stubs' . DIRECTORY_SEPARATOR . 'artisan';

    /**
     * The builder phar package.
     *
     * @var Packager
     */
    private $packager;

    public function __construct(Packager $packager = null)
    {
        parent::__construct();

        if ($packager === null) {
            $packager = new Packager();
        }
        $this->packager = $packager;
    }

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $buildPath = $this->build_path();
        $lstSrcPath = [
            'app',
            'bootstrap',
            'config',
            'routes',
            'composer.json',
        ];

        $this->title(
            sprintf('Building %s Application', config('app.name'))
        );

        $this->task(
            '  Create <fg=green>build</> folder.',
            function () use ($buildPath) {
                File::makeDirectory($buildPath, 0755, true, true);
                File::cleanDirectory($buildPath);
            }
        );

        foreach ($lstSrcPath as $s) {
            $this->task(
                "  Copy source from <fg=green>$s</> to build folder.",
                function () use ($s) {
                    $source = base_path($s);
                    $target = $this->build_path($s);
                    if (File::isFile($source))
                        File::copy($source, $target);
                    elseif (File::isDirectory($source))
                        File::copyDirectory($source, $target);
                }
            );
        }

        $this->task(
            "  Remove <fg=green>app:</> commands from build.",
            function () use ($s) {
                File::deleteDirectory($this->build_path("app/Console/Commands/App/"));
            }
        );

        $this->task(
            "  Copy <fg=green>artisan custom</> to build folder.",
            function () {
                return File::copy(
                    static::BINARY_FILE,
                    $this->build_path('artisan')
                );
            }
        );

        $this->task(
            "  Success process <fg=green>Composer install</> in build folder.",
            function () use ($buildPath) {
                return Process::path($buildPath)->run('composer install --no-dev', function (string $type, string $output) {
                    $this->output->write($output);
                });
            },
            false
        );

        $this->task(
            "    Success build <fg=green>phar</> executable.",
            function () {
                $this->packager->setOutput($this->output);
                $this->packager->coerceWritable();

                $pharer = $this->packager->getPharer($this->build_path());
                $pharer->setTarget('ductn');
                $pharer->build();
            }
        );

        $this->task(
            "  Cleanup build folder.",
            function () {
                File::deleteDirectory($this->build_path());
            }
        );
    }

    function build_path($path = null): string
    {
        if ($path)
            return base_path('build' . DIRECTORY_SEPARATOR . trim($path, DIRECTORY_SEPARATOR));
        return base_path('build');
    }
}
