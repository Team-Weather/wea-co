import 'dart:io';

import 'package:weaco/core/enum/image_type.dart';

abstract interface class LocalFileDataSource {
  Future<File> getImage({required ImageType imageType});

  Future<void> saveImage({required bool isOrigin, required File file});

  Future<File> getCompressedImage();

  Future<void> saveCompressedImage({required List<int> image});


}
