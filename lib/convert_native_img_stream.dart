import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'convert_native_img_stream_platform_interface.dart';

class ConvertNativeImgStream {
  Future<String?> getPlatformVersion() {
    return ConvertNativeImgStreamPlatform.instance.getPlatformVersion();
  }

  Future<File?> convertImg(
    Uint8List imgBytes,
    int width,
    int height,
    String pathToSave, {
    int rotationFix = 90,
    int quality = 100,
  }) async {
    final converted = convertImgToBytes(imgBytes, width, height,
        rotationFix: rotationFix, quality: quality);
    return compute((List<dynamic> params) async {
      final bytes = params[0];
      final path = params[1];
      return await _saveImageToFile(bytes, path);
    }, [converted, pathToSave]);
  }

  Future<Uint8List?> convertImgToBytes(
    Uint8List imgBytes,
    int width,
    int height, {
    int rotationFix = 90,
    int quality = 100,
  }) async {
    if (imgBytes.isEmpty) {
      throw Exception("imgBytes are empty");
    }
    if (width == 0 || height == 0) {
      throw Exception("width or height cant be zero");
    }
    Uint8List? jpegData = imgBytes;
    if (Platform.isAndroid) {
      jpegData = await ConvertNativeImgStreamPlatform.instance
          .convert(imgBytes, width, height, quality);
    }

    if (Platform.isAndroid) {
      img.Image? image = img.decodeJpg(jpegData!);
      final rotated = img.copyRotate(image!, angle: rotationFix);
      return img.encodeJpg(rotated, quality: quality);
    } else {
      return compute((List<dynamic> params) async {
        final int w = params[0];
        final int h = params[1];
        final Uint8List bytes = params[2];
        final int rotate = params[3];

        img.Image im = img.Image.fromBytes(
            height: h.toInt(),
            width: w.toInt(),
            bytes: bytes.buffer,
            format: img.Format.uint8,
            order: img.ChannelOrder.bgra);
        final rotated = img.copyRotate(im, angle: rotate);
        final imgData = img.encodeJpg(rotated, quality: quality);
        return imgData;
      }, [width, height, jpegData, rotationFix]);
    }
  }

  Future<File?> _saveImageToFile(Uint8List? jpegData, String appDir) async {
    if (jpegData == null) {
      return null;
    }
    try {
      // Get the temporary directory path
      final String fileName = '${DateTime.now().toIso8601String()}.jpg';
      final String newPath = '$appDir/$fileName';

      // Save the image to the specified path
      final File imageFile = File(newPath);
      await imageFile.writeAsBytes(jpegData);
      return imageFile;
    } catch (e) {
      return null;
    }
  }
}
