import 'dart:io';

import 'package:weaco/core/enum/image_type.dart';

abstract interface class FileRepository {
  Future<File> getImage({required ImageType imageType});

  Future<void> saveImage({required bool isOrigin, required File file, required List<int> compressedImage});

  Future<List<String>> saveOotdImage();
}
