<?php
namespace App\Auth;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JWTAuth {
    private string $secretKey;

    public function __construct() {
        // Load from environment variable instead of hardcoding
        $this->secretKey = $_ENV['JWT_SECRET'] ?? 'kvpFWQDecn';
    }

    /**
     * Generates a JWT token.
     *
     * @param array $userData An associative array containing user data.
     *                        This data will be included in the token payload.
     *                        Example: ['user_id' => 123, 'role' => 'admin']
     * @param int $expirationTime The token expiration time in seconds. Defaults to 1 week (604800 seconds).
     *
     * @return string The generated JWT token.
     */
    public function generateToken(array $userData, int $expirationTime = 604800): string {
        $payload = [
            'iat' => time(), // Issued at
            'exp' => time() + $expirationTime // Token expiration time
        ];

        // Add user data to payload
        $payload = array_merge($payload, $userData);

        return JWT::encode($payload, $this->secretKey, 'HS256');
    }

    public function verifyToken($token) {
        try {
            return JWT::decode($token, new Key($this->secretKey, 'HS256'));
        } catch (\Exception $e) {
            return false;
        }
    }
}