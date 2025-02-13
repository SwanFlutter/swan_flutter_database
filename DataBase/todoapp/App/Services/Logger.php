<?php
namespace App\Services;

class Logger {
    private $logFile;

    public function __construct() {
        $this->logFile = __DIR__ . '/../../logs/app.log';
        
        // Create logs directory if it doesn't exist
        if (!is_dir(dirname($this->logFile))) {
            mkdir(dirname($this->logFile), 0777, true);
        }
    }

    public function log($level, $message, array $context = []) {
        $date = date('Y-m-d H:i:s');
        $contextStr = !empty($context) ? json_encode($context) : '';
        $logMessage = "[$date] [$level]: $message $contextStr" . PHP_EOL;
        
        file_put_contents($this->logFile, $logMessage, FILE_APPEND);
    }

    public function error($message, array $context = []) {
        $this->log('ERROR', $message, $context);
    }

    public function info($message, array $context = []) {
        $this->log('INFO', $message, $context);
    }

    public function debug($message, array $context = []) {
        $this->log('DEBUG', $message, $context);
    }
} 