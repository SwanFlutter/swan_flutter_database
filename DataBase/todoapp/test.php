<?php

error_log("Request received at: " . date('Y-m-d H:i:s'));
error_log("Request method: " . $_SERVER['REQUEST_METHOD']);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept, Authorization');

// برای دیباگ
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'php_errors.log');

try {
    // دریافت داده‌های ورودی
    $rawInput = file_get_contents('php://input');
    error_log("Raw input received: " . $rawInput);

    $data = json_decode($rawInput);

    // اتصال به دیتابیس
    $pdo = new PDO(
        "mysql:host=localhost;dbname=todo_app;charset=utf8mb4",
        "root",
        "",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    if ($data && isset($data->table_name) && isset($data->columns)) {
        // ساخت کوئری SQL
        $sql = "CREATE TABLE IF NOT EXISTS `{$data->table_name}` (";
        $columnDefs = [];

        foreach ($data->columns as $name => $type) {
            $columnDefs[] = "`$name` $type";
        }

        $sql .= implode(', ', $columnDefs);
        $sql .= ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

        error_log("Executing SQL: " . $sql);

        // اجرای کوئری
        $result = $pdo->exec($sql);

        if ($result !== false) {
            $response = [
                'success' => true,
                'message' => "Table {$data->table_name} created successfully",
                'sql' => $sql
            ];
        } else {
            $error = $pdo->errorInfo();
            $response = [
                'success' => false,
                'message' => "Failed to create table",
                'error' => $error[2]
            ];
        }
    } else {
        $response = [
            'success' => false,
            'message' => "Invalid input data",
            'raw_input' => $rawInput,
            'parsed_data' => $data
        ];
    }

    error_log("Sending response: " . json_encode($response));
    echo json_encode($response);

} catch (PDOException $e) {
    $error = [
        'success' => false,
        'message' => "Database error: " . $e->getMessage(),
        'error_code' => $e->getCode()
    ];
    error_log("Database error: " . $e->getMessage());
    echo json_encode($error);
} catch (Exception $e) {
    $error = [
        'success' => false,
        'message' => "Error: " . $e->getMessage()
    ];
    error_log("General error: " . $e->getMessage());
    echo json_encode($error);
}