<?php
namespace App\Middlewares;

use App\Traits\ResponseTrait;
use ErrorException;

class ErrorHandlingMiddleware {
    use ResponseTrait;

    public function handle($request, callable $next) {
        try {
            // Set custom error handler
            set_error_handler(function($severity, $message, $file, $line) {
                throw new ErrorException($message, 0, $severity, $file, $line);
            });

            // Execute the next middleware/request handler
            return $next($request);

        } catch (\PDOException $e) {
            error_log("Database Error: " . $e->getMessage());
            return $this->jsonMsg(false, "خطا در ارتباط با پایگاه داده", HTTP_BadREQUEST);

        } catch (\Exception $e) {
            error_log("General Error: " . $e->getMessage());
            return $this->jsonMsg(false, "خطای داخلی سرور", HTTP_InternalServerError);

        } finally {
            restore_error_handler();
        }
    }
} 