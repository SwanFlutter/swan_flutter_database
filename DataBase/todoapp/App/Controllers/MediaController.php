<?php

namespace App\Controllers;

use App\Traits\ResponseTrait;

class MediaController {
    use ResponseTrait;

    public function processImage($request) {
        // TODO: Implement image processing
        return $this->jsonMsg(true, "Image processing endpoint", HTTP_OK);
    }

    public function processVideo($request) {
        // TODO: Implement video processing
        return $this->jsonMsg(true, "Video processing endpoint", HTTP_OK);
    }
} 