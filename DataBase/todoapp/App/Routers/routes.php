<?php
use App\Routers\Router as Router;
use App\Middlewares\AuthMiddleware;
use App\Auth\JWTAuth;

// use Controllers
use App\Controllers\AuthController;
use App\Controllers\DataBaseController;
use App\Controllers\MediaController;
use App\Controllers\WebSocketController;

// ایجاد یک نمونه از میدلور
$authMiddleware = new AuthMiddleware(new JWTAuth());
$request = (object) [
    "headers" => $_SERVER['HTTP_TOKEN'] ?? null,
    "query"   => $_GET['token'] ?? null,
    "body"    => getPostDataInput()->token ?? null
];

$response = $authMiddleware->handle($request);

if(!$response) exit();

$router = new Router();

// Define routes
$router->post('v1','/login', AuthController::class, 'login');
$router->post('v1','/register', AuthController::class, 'register');
$router->post('v1','/verify', AuthController::class, 'verify');

// Database routes
$router->post('v1', '/database/create_table', DataBaseController::class, 'createTable');
$router->post('v1', '/database/insert', DataBaseController::class, 'insert');
$router->post('v1', '/database/update', DataBaseController::class, 'update');
$router->post('v1', '/database/delete', DataBaseController::class, 'delete');
$router->post('v1', '/database/select', DataBaseController::class, 'select');
$router->post('v1', '/database/query', DataBaseController::class, 'query');

// روت‌های پردازش رسانه
$router->post('v1', '/process/image', MediaController::class, 'processImage');
$router->post('v1', '/process/video', MediaController::class, 'processVideo');

// روت‌های وب‌سوکت
$router->get('v1', '/ws', WebSocketController::class, 'handle');