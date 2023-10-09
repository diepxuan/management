<?php

if (!function_exists("PharConsoleRunning")) {
    function PharConsoleRunning(): bool
    {
        return \Phar::running() != "";
    }
}
