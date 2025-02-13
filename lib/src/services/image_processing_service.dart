import 'dart:io';

import 'package:image/image.dart' as img;

class ImageProcessingService {
  Future<File> processImage(
    File file, {
    String operation = 'resize',
    Map<String, dynamic>? params,
  }) async {
    try {
      // خواندن تصویر
      final image = img.decodeImage(await file.readAsBytes());
      if (image == null) throw Exception('Could not decode image');

      late img.Image processedImage;

      switch (operation) {
        case 'resize':
          processedImage = img.copyResize(
            image,
            width: params?['width'] ?? 800,
            height: params?['height'] ?? 600,
          );
          break;

        case 'compress':
          processedImage = image; // کیفیت در هنگام ذخیره تنظیم می‌شود
          break;

        case 'grayscale':
          processedImage = img.grayscale(image);
          break;

        default:
          throw Exception('Unknown operation');
      }

      // ذخیره تصویر پردازش شده
      final outputPath = '${file.parent.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(img.encodeJpg(processedImage, quality: params?['quality'] ?? 90));

      return outputFile;
    } catch (e) {
      throw Exception('Image processing failed: $e');
    }
  }
}
