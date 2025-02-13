<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept, Authorization');

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/debug.log');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Load required files
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/App/Routers/routes.php';
require_once __DIR__ . '/App/Database/Connection.php';

use App\Services\Logger;
use App\Middlewares\ErrorHandlingMiddleware;
use App\Middlewares\RateLimitMiddleware;

try {
    // Initialize services
    $logger = new Logger();
    $errorHandler = new ErrorHandlingMiddleware();
    $rateLimit = new RateLimitMiddleware();

    // Get raw input
    $rawInput = file_get_contents('php://input');
    $request = json_decode($rawInput);

    // Log request details
    $logger->info("Request Method: " . $_SERVER['REQUEST_METHOD']);
    $logger->info("Request URI: " . $_SERVER['REQUEST_URI']);
    $logger->info("Raw Input: " . $rawInput);

    // Apply rate limiting
    $rateLimitResponse = $rateLimit->handle(null);
    if ($rateLimitResponse !== true) {
        echo json_encode(['success' => false, 'message' => $rateLimitResponse]);
        exit;
    }

    // Handle the request
    $response = $errorHandler->handle(null, function() use ($request, $logger) {
        // Create database connection
        $database = new \App\Database\Connection();
        $pdo = $database->getPdo();

        // Log successful connection
        $logger->info('Database connection established');

        // Get request details
        $requestMethod = $_SERVER["REQUEST_METHOD"];
        $version = getApiVersion();
        $path = getPath(false);

        // Route the request
        $router = new \App\Routers\Router();
        return $router->resolve($version, $requestMethod, $path);
    });

    // Output response
    if (is_string($response)) {
        echo $response;
    } else {
        echo json_encode($response);
    }

} catch (Exception $e) {
    $logger->error("Error: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => "Server error: " . $e->getMessage()
    ]);
}