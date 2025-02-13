<?php
namespace App\Services;

class CacheService {
    private $cache = [];
    private $ttls = [];  // برای نگهداری زمان انقضا

    public function get($key) {
        if (isset($this->ttls[$key]) && time() > $this->ttls[$key]) {
            $this->delete($key);
            return null;
        }
        return $this->cache[$key] ?? null;
    }

    public function set($key, $value, $ttl = 3600) {
        $this->cache[$key] = $value;
        $this->ttls[$key] = time() + $ttl;
    }

    public function delete($key) {
        unset($this->cache[$key], $this->ttls[$key]);
    }
} 