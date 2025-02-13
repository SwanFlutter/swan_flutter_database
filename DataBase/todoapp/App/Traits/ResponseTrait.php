<?php
namespace App\Traits;

trait ResponseTrait {

    protected function jsonMsg(bool $success, string $message, int $status = 200, $data = null): void {
        // Set HTTP status code
        http_response_code($status);

        // Prepare response array
        $response = [
            'success' => $success,
            'message' => $message,
            'status' => $status
        ];

        // Add data if provided
        if ($data !== null) {
            $response['data'] = $data;
        }

        // Log the response for debugging
        error_log("Sending response: " . print_r($response, true));

        // Send JSON response and exit
        echo json_encode($response);
        exit();
    }
    protected function handleResult($result, string $successMessage, string $errorMessage): string {
        if (is_string($result)) {
            return $this->jsonMsg(false, "Error: $result", HTTP_BadREQUEST);
        }

        return $result
            ? $this->jsonMsg(true, $successMessage, HTTP_OK, $result)
            : $this->jsonMsg(false, $errorMessage, HTTP_BadREQUEST);
    }

    public function sanitizeInput($input): array|string
    {
        if (is_array($input)) {
            return array_map([$this, 'sanitizeValue'], $input);
        } else {
            return $this->sanitizeValue($input);
        }
    }

    public function sanitizeValue($value) {
        // Step 1: Trim whitespace from the input
        $sanitizedValue = trim($value);

        // Step 2: Apply a default filter to the input
        $sanitizedValue = filter_var($sanitizedValue, FILTER_DEFAULT);

        // Step 3: Convert special characters to HTML entities
        $sanitizedValue = htmlspecialchars($sanitizedValue, ENT_QUOTES, 'UTF-8');

        // Return the sanitized value
        return $sanitizedValue;
    }
}