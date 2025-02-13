import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class FileResponse {
  final bool success;
  final String? url;
  final String? message;

  FileResponse({
    required this.success,
    this.url,
    this.message,
  });

  factory FileResponse.fromJson(Map<String, dynamic> json) {
    return FileResponse(
      success: json['success'] ?? false,
      url: json['data']?['url'],
      message: json['message'],
    );
  }
}

class FileService {
  final String baseUrl;
  final String? token;

  FileService(this.baseUrl, {this.token});

  Future<FileResponse> upload(File file, {String? folder}) async {
    try {
      final uri = Uri.parse('$baseUrl/v1/upload');
      final request = http.MultipartRequest('POST', uri);

      // اضافه کردن توکن به هدر
      if (token != null) {
        request.headers['token'] = token!;
      }

      // اضافه کردن فایل
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: path.basename(file.path),
      );
      request.files.add(multipartFile);

      // اضافه کردن پوشه (اگر مشخص شده باشد)
      if (folder != null) {
        request.fields['folder'] = folder;
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      return FileResponse.fromJson(jsonResponse);
    } catch (e) {
      return FileResponse(success: false, message: e.toString());
    }
  }

  Future<FileResponse> delete(String fileUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/delete-file'),
        body: json.encode({'url': fileUrl}),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'token': token!,
        },
      );

      return FileResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return FileResponse(success: false, message: e.toString());
    }
  }
}
