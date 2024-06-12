import 'dart:io';
import 'package:weaco/core/enum/image_type.dart';
import 'package:weaco/domain/file/repository/file_repository.dart';

class MockFileRepositoryImpl implements FileRepository {
  int getImageCallCount = 0;
  int saveImageCallCount = 0;
  int saveOotdImageCallCount = 0;
  final Map<String, dynamic> methodParameterMap = {};
  File getImageResult = File('test/mock/assets/cropped.png');
  List<String> saveOotdImageResult = ['', ''];
  bool saveImageResult = false;

  void initMockData() {
    getImageCallCount = 0;
    saveImageCallCount = 0;
    saveOotdImageCallCount = 0;
    methodParameterMap.clear();
    saveOotdImageResult = ['', ''];
  }

  @override
  Future<File> getImage({required ImageType imageType}) async {
    getImageCallCount++;
    return getImageResult;
  }

  @override
  Future<void> saveImage({required bool isOrigin, required File file, List<int>? compressedImage}) async {
    saveImageCallCount++;
    methodParameterMap['data'] = file;
  }

  @override
  Future<List<String>> saveOotdImage() async {
    saveOotdImageCallCount++;
    return saveOotdImageResult;
  }
}
