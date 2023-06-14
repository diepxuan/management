<?php

namespace DiepXuan\Console;

use Symfony\Component\Console\Command\Command as SymfonyCommand;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Console\Input\ArrayInput;
use Symfony\Component\Console\Output\OutputInterface;

class Command extends SymfonyCommand
{
    const ETCPATH = '/etc/ductn/';

    protected $fileSystem;
    protected static $configFile;

    public function __construct(string $name = null)
    {
        $this->fileSystem = new Filesystem;

        try {
            \Dotenv\Dotenv::createImmutable(self::ETCPATH, self::$configFile)->load();
        } catch (\Throwable $th) {
            //throw $th;
            // $process = new Process(['sudo', 'touch', self::ETCPATH . self::$configFile]);
            // $process->run();
        }

        parent::__construct($name);
    }

    protected function executeSubCommand(string $name, array $parameters, OutputInterface $output)
    {
        return $this->getApplication()
            ->find($name)
            ->run(new ArrayInput($parameters), $output);
    }
}
