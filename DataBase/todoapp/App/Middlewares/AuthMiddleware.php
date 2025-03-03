<?php
namespace App\Middlewares;

use App\Auth\JWTAuth;
use App\Traits\ResponseTrait;

class AuthMiddleware {
    use ResponseTrait;

    private JWTAuth $jwtAuth;

    public function __construct(JWTAuth $jwtAuth) {
        $this->jwtAuth = $jwtAuth;
    }

    public function handle($request) {
        // Check if the request path is public
        if ($this->isPublicPath(getPath())) {
            return true; // Allow public paths
        }

        // Check if the request has a JWT token
        $token = $this->getTokenFromRequest($request);
        if (!$token) {
            return $this->jsonMsg(false, "Unauthorized!", true, 401);
        }

        // Verify the JWT token
        if (!$this->jwtAuth->verifyToken($token)) {
            return $this->jsonMsg(false, "Unauthorized Token!", true, 401);
        }

        return true;
    }

    private function isPublicPath($path) {
        // Define public paths
        $publicPaths = ['v1/login' ,'v1/verify', 'v1/register']; // Add more public paths if needed

        // Check if the requested path is public
        return in_array($path, $publicPaths);
    }

    private function getTokenFromRequest($request) {
        // Get token from headers, query string, or request body
        $token = $request->headers['token'] ?? $request->query['token'] ?? $request->body['token'] ?? null;
        return $token;
    }
}
