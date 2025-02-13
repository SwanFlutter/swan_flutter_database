<?php

namespace App\Database;

use Symfony\Component\Dotenv\Dotenv;
use PDO;
use PDOException;

// App/Database/Connection.php

class Connection {
    protected static $instance = null;
    protected $pdo;

    public function __construct() {
        if (self::$instance === null) {
            $this->initializeConnection();
        }
        return self::$instance;
    }

    /**
     * @throws \Exception
     */
    protected function initializeConnection() {
        // بارگذاری متغیرهای محیطی از فایل .env
        $dotenv = new Dotenv(true);
        $dotenv->load(__DIR__ . '/../../.env');

        try {
            $this->pdo = new PDO(
                $_ENV['DB_TYPE'] . ":host=" . $_ENV['DB_HOST'] . ";dbname=" . $_ENV['DB_NAME'],
                $_ENV['DB_USERNAME'],
                $_ENV['DB_PASSWORD'],
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
                ]
            );

            self::$instance = $this;
        } catch (PDOException $e) {
            throw new \Exception("Connection failed: " . $e->getMessage());
        }
    }

    public function getPdo(): PDO {
        return $this->pdo;
    }
}
