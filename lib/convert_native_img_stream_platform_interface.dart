import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'convert_native_img_stream_method_channel.dart';

abstract class ConvertNativeImgStreamPlatform extends PlatformInterface {
  /// Constructs a ConvertNativeImgStreamPlatform.
  ConvertNativeImgStreamPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConvertNativeImgStreamPlatform _instance = MethodChannelConvertNativeImgStream();

  /// The default instance of [ConvertNativeImgStreamPlatform] to use.
  ///
  /// Defaults to [MethodChannelConvertNativeImgStream].
  static ConvertNativeImgStreamPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ConvertNativeImgStreamPlatform] when
  /// they register themselves.
  static set instance(ConvertNativeImgStreamPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Uint8List?> convert(
      Uint8List imgBytes,
      int width,
      int height,
      int quality
  ) {
    throw UnimplementedError('convert(*) has not been implemented.');
  }
}
