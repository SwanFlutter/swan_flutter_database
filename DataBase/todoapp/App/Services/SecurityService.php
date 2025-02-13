<?php
namespace App\Services;

class SecurityService {
    private $encryptionKey;

    public function __construct() {
        $this->encryptionKey = getenv('ENCRYPTION_KEY');
    }

    public function encrypt($data) {
        $iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length('AES-256-CBC'));
        $encrypted = openssl_encrypt($data, 'AES-256-CBC', $this->encryptionKey, 0, $iv);
        return base64_encode($encrypted . '::' . $iv);
    }

    public function decrypt($data) {
        list($encrypted_data, $iv) = explode('::', base64_decode($data), 2);
        return openssl_decrypt($encrypted_data, 'AES-256-CBC', $this->encryptionKey, 0, $iv);
    }

    public function validateToken($token) {
        // کد اعتبارسنجی توکن
    }

    public function sanitizeInput($data) {
        if (is_array($data)) {
            return array_map([$this, 'sanitizeInput'], $data);
        }
        return htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
    }
} 