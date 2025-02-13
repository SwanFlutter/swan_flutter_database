<?php

namespace App\Controllers;

use App\Auth\JWTAuth;
use App\Database\QueryBuilder;
use App\Traits\ResponseTrait;
use App\Validations\ValidateData;

class AuthController {
    use ResponseTrait;
    use ValidateData;

    protected $queryBuilder;
    protected $jwtAuth;

    public function __construct() {
        $this->queryBuilder = new QueryBuilder();
        $this->jwtAuth = new JWTAuth();
    }

    public function login($request) {
        // Validate required fields
        $this->validate([
            "identifier||required|string",
            "password||required|string|min:6"
        ], $request);

        try {
            // Find user by email or username
            $user = $this->queryBuilder->table('users')
                ->where("email = '{$request->identifier}' OR username = '{$request->identifier}'")
                ->get()
                ->execute();

            if (!$user || !password_verify($request->password, $user['password'])) {
                return $this->jsonMsg(false, "نام کاربری یا رمز عبور اشتباه است", HTTP_Unauthorized);
            }

            // Generate JWT token
            $token = $this->jwtAuth->generateToken([
                'user_id' => $user['id'],
                'email' => $user['email']
            ]);

            return $this->jsonMsg(true, "ورود موفقیت آمیز بود", HTTP_OK, ['token' => $token]);

        } catch (\Exception $e) {
            return $this->jsonMsg(false, $e->getMessage(), HTTP_BadREQUEST);
        }
    }

    public function register($request) {
        // Validate dynamic fields structure
        if (!isset($request->fields) || !is_array($request->fields)) {
            return $this->jsonMsg(false, "ساختار فیلدهای ثبت نام نامعتبر است", HTTP_BadREQUEST);
        }

        try {
            // Start transaction
            $this->queryBuilder->getPdo()->beginTransaction();

            // Default required fields for users table
            $columns = [
                'id' => 'INT AUTO_INCREMENT PRIMARY KEY',
                'created_at' => 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
                'updated_at' => 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
            ];

            // Add dynamic fields to columns
            foreach ($request->fields as $field => $value) {
                // Skip if field is empty
                if (empty($value)) continue;

                // Determine field type based on value
                $type = $this->getFieldType($value);
                $columns[$field] = $type;
            }

            // Create or update users table
            $this->createOrUpdateUsersTable($columns);

            // Sanitize and validate input data
            $sanitizedData = [];
            foreach ($request->fields as $field => $value) {
                // Skip empty fields
                if (empty($value)) continue;

                $sanitizedData[$field] = $this->sanitizeInput($value);

                // Additional validation for specific fields
                if ($field === 'email') {
                    if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                        throw new \Exception("فرمت ایمیل نامعتبر است");
                    }
                    $this->checkUnique('users', 'email', $value);
                }

                if ($field === 'username') {
                    $this->checkUnique('users', 'username', $value);
                }

                if ($field === 'password') {
                    if (strlen($value) < 6) {
                        throw new \Exception("رمز عبور باید حداقل 6 کاراکتر باشد");
                    }
                    $sanitizedData[$field] = password_hash($value, PASSWORD_BCRYPT);
                }
            }

            // Insert user data
            $result = $this->queryBuilder->table('users')
                ->insert($sanitizedData)
                ->execute();

            if (!$result) {
                throw new \Exception("خطا در ایجاد کاربر");
            }

            $this->queryBuilder->getPdo()->commit();
            return $this->jsonMsg(true, "ثبت نام با موفقیت انجام شد", HTTP_OK);

        } catch (\Exception $e) {
            $this->queryBuilder->getPdo()->rollBack();
            return $this->jsonMsg(false, $e->getMessage(), HTTP_BadREQUEST);
        }
    }

    public function verify($request) {
        if (!isset($request->token)) {
            return $this->jsonMsg(false, "توکن یافت نشد", HTTP_BadREQUEST);
        }

        $decodedToken = $this->jwtAuth->verifyToken($request->token);

        if (!$decodedToken) {
            return $this->jsonMsg(false, "توکن نامعتبر است", HTTP_Unauthorized);
        }

        return $this->jsonMsg(true, "توکن معتبر است", HTTP_OK, [
            'user_id' => $decodedToken->user_id,
            'email' => $decodedToken->email
        ]);
    }

    private function getFieldType($value) {
        switch (gettype($value)) {
            case 'integer':
                return 'INT';
            case 'double':
                return 'DECIMAL(10,2)';
            case 'boolean':
                return 'BOOLEAN';
            case 'string':
                return strlen($value) > 255 ? 'TEXT' : 'VARCHAR(255)';
            default:
                return 'VARCHAR(255)';
        }
    }

    private function createOrUpdateUsersTable($columns) {
        $sql = "CREATE TABLE IF NOT EXISTS users (";
        $sql .= implode(', ', array_map(
            fn($name, $type) => "$name $type",
            array_keys($columns),
            array_values($columns)
        ));
        $sql .= ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";

        $statement = $this->queryBuilder->getPdo()->prepare($sql);
        return $statement->execute();
    }
}