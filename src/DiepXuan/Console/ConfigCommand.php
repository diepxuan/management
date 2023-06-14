<?php

namespace DiepXuan\Console;

use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Exception\LogicException;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Symfony\Component\Process\Process;

class ConfigCommand extends Command
{
    protected static $configFile = 'ductn.conf';
    protected static $defaultName = 'sys:config';
    protected static $defaultDescription = 'Config database connect to server';

    /**
     * Configure the command
     */
    protected function configure()
    {
        $dbHost     = getenv('DB_HOST');
        $dbPort     = getenv('DB_PORT');
        $dbDatabase = getenv('DB_DATABASE');
        $dbUsername = getenv('DB_USERNAME');
        $dbPassword = getenv('DB_PASSWORD');

        $this->addArgument(
            'dbHost',
            $dbHost ? InputArgument::OPTIONAL : InputArgument::REQUIRED,
            'Database hostname or ip address'
        );

        $this->addArgument(
            'dbPort',
            $dbPort ? InputArgument::OPTIONAL : InputArgument::REQUIRED,
            'Database openport'
        );
    }

    /**
     * @param InputInterface  $input
     * @param OutputInterface $output
     *
     * @return void
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $dbHost = $input->getArgument('dbHost');

        $output->writeln("Hostname: $dbHost");

        // exec('ifconfig', $results);

        // $ifconfig = implode("\n", $results);
        // $regex = '/eth[0-1][\sA-z:0-9]+inet addr:([0-9.]+)/';
        // preg_match_all($regex, $ifconfig, $ips);

        // $output->writeln('<info>=== Begin IPs ===</info>');
        // $output->writeln('<comment>Public IP:  ' . $ips[1][0] . '</comment>');
        // $output->writeln('<comment>Private IP: ' . $ips[1][1] . '</comment>');
        $output->writeln('<comment>            The Cake is a Lie           </comment>');
        $output->writeln('<info>=== End of Output ===</info>');
        return self::SUCCESS;
    }
}
