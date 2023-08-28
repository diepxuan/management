<?php

namespace App\Console\Commands;

use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Input\InputInterface;
use Illuminate\Console\Command as BaseCommand;
use Illuminate\Support\Facades\Process;
use Illuminate\Process\Pipe;

abstract class Command extends BaseCommand
{
    /**
     * Holds the command original output.
     */
    protected OutputInterface $originalOutput;

    /**
     * Performs the given task, outputs and
     * returns the result.
     */
    public function task(string $title = '', $task = null, $skip = false): mixed
    {
        if (is_null($task) || $skip) {
            $this->output->writeln($title);
            return true;
        }
        try {
            $callback = call_user_func($task);
            $this->output->writeln($title);
            return $callback;
        } catch (\Throwable $th) {
            throw $th;
        }
    }

    /*
     * Displays the given string as title.
     */
    public function title(string $title): Command
    {
        $this->output->title($title);
        // $size = strlen($title);
        // $spaces = str_repeat(' ', $size);

        // $this->output->newLine();
        // $this->output->writeln("<bg=blue;fg=white>$spaces$spaces$spaces</>");
        // $this->output->writeln("<bg=blue;fg=white>$spaces$title$spaces</>");
        // $this->output->writeln("<bg=blue;fg=white>$spaces$spaces$spaces</>");
        // $this->output->newLine();

        return $this;
    }

    /**
     * Run the console command.
     *
     * @param  \Symfony\Component\Console\Input\InputInterface  $input
     * @param  \Symfony\Component\Console\Output\OutputInterface  $output
     * @return int
     */
    public function run(InputInterface $input, OutputInterface $output): int
    {
        return parent::run($input, $this->originalOutput = $output);
    }
}
