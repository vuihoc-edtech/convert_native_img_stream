import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'convert_native_img_stream_platform_interface.dart';

/// An implementation of [ConvertNativeImgStreamPlatform] that uses method channels.
class MethodChannelConvertNativeImgStream extends ConvertNativeImgStreamPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('convert_native_img_stream');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Uint8List?> convert(
      Uint8List imgBytes,
      int width,
      int height,
      int quality
    ) async {
    if(Platform.isIOS) {
      throw UnimplementedError('convert(*) has not been implemented for iOS');
    }
    final result = await methodChannel.invokeMethod('convert', {
      "bytes": imgBytes,
      "width": width,
      "height": height,
      "quality": quality
    });
    return result;
  }
}
