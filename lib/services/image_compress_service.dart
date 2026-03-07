import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Görsel sıkıştırma servisi.
/// Firebase Storage'a yüklemeden önce görseli küçülterek
/// bant genişliği ve depolama alanı tasarrufu sağlar.
class ImageCompressService {
  ImageCompressService._();

  /// Verilen [File]'ı sıkıştırır ve [Uint8List] olarak döndürür.
  ///
  /// - [minWidth] / [minHeight]: Maksimum boyut (px), oran korunur.
  /// - [quality]: 0–100 arası JPEG kalitesi (varsayılan 80).
  ///
  /// Sıkıştırma başarısız olursa [null] dönebilir.
  static Future<Uint8List?> compressFile(
    File file, {
    int minWidth = 1080,
    int minHeight = 1080,
    int quality = 80,
  }) async {
    final Uint8List? result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );
    return result;
  }
}
