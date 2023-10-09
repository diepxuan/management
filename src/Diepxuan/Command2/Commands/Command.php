<?php

namespace Diepxuan\Command\Commands;

use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Input\InputInterface;
use Illuminate\Console\Command as BaseCommand;
use Illuminate\Support\Arr;

abstract class Command extends BaseCommand
{
    /**
     * Holds the command original output.
     */
    protected OutputInterface $originalOutput;

    /**
     * Time format when command will be execute.
     */
    public string $scheduleTimeFormat = '';

    /**
     * Create a new console command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
        config(['app.commands' => Arr::add(config('app.commands', []), $this->name, [
            'timeFormat' => $this->scheduleTimeFormat ?: '',
            'lastRunAt'  => null,
        ])]);
    }

    /**
     * Performs the given task, outputs and
     * returns the result.
     */
    public function task(string $title = '', $task = null, $skip = false): mixed
    {
        try {
            if (!is_null($task) && !$skip)
                $callback = call_user_func($task);
            $this->output->writeln($title);
            return $callback;
        } catch (\Throwable $th) {
            throw $th;
        }
    }

    /**
     * Prompt the user for input.
     *
     * @param  string  $question
     * @param  string|null  $default
     * @return mixed
     */
    public function ask($question, $default = null, $callback = null)
    {
        if (is_null($callback)) {
            return parent::ask($question, $default);
        }
        try {
            $answer = parent::ask($question, $default);
            call_user_func($callback, $answer);
            return $this;
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

    /**
     * Call another console command as schedule.
     *
     * @param  \Symfony\Component\Console\Command\Command|string  $command
     * @param  array  $arguments
     * @return int
     */
    public function scheduleCall($command, array $arguments = [])
    {
        $now = time();
        if (config("app.commands.$command.lastRunAt") == date(config("app.commands.$command.timeFormat"), $now))
            return 0;
        if (strtotime(config("app.commands.$command.lastRunAt")) >= $now)
            return 0;
        if (!$this->getApplication()->has($command))
            return 0;
        config(["app.commands.$command.lastRunAt" => date(config("app.commands.$command.timeFormat"), $now)]);
        return parent::call($command, $arguments);
    }
}
