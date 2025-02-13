<?php
namespace App\Middlewares;

use App\Services\CacheService;
use App\Traits\ResponseTrait;

class RateLimitMiddleware {
    use ResponseTrait;

    private $cache;
    private $maxRequests = 100; // تعداد درخواست مجاز
    private $timeWindow = 3600; // بازه زمانی (1 ساعت)

    public function __construct() {
        $this->cache = new CacheService();
    }

    public function handle($request) {
        $ip = $_SERVER['REMOTE_ADDR'];
        $key = "rate_limit:$ip";

        $requests = (int)$this->cache->get($key) ?? 0;

        if ($requests >= $this->maxRequests) {
            return $this->jsonMsg(
                false, 
                "تعداد درخواست‌های شما از حد مجاز بیشتر شده است. لطفاً کمی صبر کنید.", 
                HTTP_TooManyRequests
            );
        }

        $this->cache->set($key, $requests + 1, $this->timeWindow);
        return true;
    }
} 