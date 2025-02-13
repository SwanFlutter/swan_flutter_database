<?php

namespace App\Controllers;

use App\Traits\ResponseTrait;

class WebSocketController {
    use ResponseTrait;

    public function handle($request) {
        // TODO: Implement WebSocket handling
        return $this->jsonMsg(true, "WebSocket endpoint", HTTP_OK);
    }
} 