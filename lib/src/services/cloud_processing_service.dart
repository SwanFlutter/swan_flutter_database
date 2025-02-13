import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ProcessingResponse<T> {
  final bool success;
  final T? result;
  final String? error;

  ProcessingResponse({
    required this.success,
    this.result,
    this.error,
  });
}

class CloudProcessingService {
  final String baseUrl;
  final String? token;

  CloudProcessingService(this.baseUrl, {this.token});

  // پردازش تصویر
  Future<ProcessingResponse<String>> processImage(
    File image, {
    required String operation, // resize, compress, filter, etc.
    Map<String, dynamic>? params,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/process/image'));

      // اضافه کردن فایل
      final imageStream = http.ByteStream(image.openRead());
      final length = await image.length();
      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        length,
        filename: image.path.split('/').last,
      );
      request.files.add(multipartFile);

      // اضافه کردن پارامترها
      request.fields['operation'] = operation;
      if (params != null) {
        request.fields['params'] = json.encode(params);
      }
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      return ProcessingResponse(
        success: true,
        result: jsonResponse['url'],
      );
    } catch (e) {
      return ProcessingResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  // پردازش ویدیو
  Future<ProcessingResponse<String>> processVideo(
    File video, {
    required String operation,
    Map<String, dynamic>? params,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/process/video'));

      // اضافه کردن فایل ویدیو
      final videoStream = http.ByteStream(video.openRead());
      final length = await video.length();
      final multipartFile = http.MultipartFile(
        'video',
        videoStream,
        length,
        filename: video.path.split('/').last,
      );
      request.files.add(multipartFile);

      // اضافه کردن پارامترها
      request.fields['operation'] = operation;
      if (params != null) {
        request.fields['params'] = json.encode(params);
      }
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // ارسال درخواست
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ProcessingResponse(
          success: true,
          result: jsonResponse['url'],
        );
      } else {
        return ProcessingResponse(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ProcessingResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Move examples into a method
  Future<void> examples(File videoFile) async {
    // برای فشرده‌سازی ویدیو
    final compressResult = await processVideo(
      videoFile,
      operation: 'compress',
      params: {
        'quality': 'medium',
        'format': 'mp4',
        'bitrate': '1000k',
      },
    );

    // برای برش ویدیو
    final trimResult = await processVideo(
      videoFile,
      operation: 'trim',
      params: {
        'start': '00:00:10',
        'duration': '00:00:30',
      },
    );

    // برای تبدیل فرمت
    final convertResult = await processVideo(
      videoFile,
      operation: 'convert',
      params: {
        'format': 'webm',
        'codec': 'vp9',
      },
    );

    // برای اضافه کردن واترمارک
    final watermarkResult = await processVideo(
      videoFile,
      operation: 'watermark',
      params: {
        'image_url': 'https://example.com/logo.png',
        'position': 'bottom-right',
        'opacity': 0.8,
      },
    );

    // برای استخراج فریم
    final frameResult = await processVideo(
      videoFile,
      operation: 'extract_frame',
      params: {
        'time': '00:00:15',
        'format': 'jpg',
      },
    );
  }

  // اجرای محاسبات پیچیده
  Future<ProcessingResponse<Map<String, dynamic>>> compute(
    String function,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/compute'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'function': function,
          'data': data,
        }),
      );

      final jsonResponse = json.decode(response.body);
      return ProcessingResponse(
        success: true,
        result: jsonResponse['result'],
      );
    } catch (e) {
      return ProcessingResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}
