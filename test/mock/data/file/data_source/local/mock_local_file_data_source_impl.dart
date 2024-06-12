import 'dart:io';
import 'package:weaco/core/enum/image_type.dart';
import 'package:weaco/data/file/data_source/local/local_file_data_source.dart';

class MockLocalFileDataSourceImpl implements LocalFileDataSource {
  final Map<String, int> methodCallCount = {};
  final Map<String, dynamic> methodResult = {};
  final Map<String, dynamic> methodParameter = {};

  void initMockData() {
    methodResult.clear();
    methodParameter.clear();
    methodCallCount.clear();
    methodResult['getImage'] = File('test/mock/assets/origin.png');
  }

  @override
  Future<File> getImage({required ImageType imageType}) async {
    methodCallCount['getImage'] = (methodCallCount['getImage'] ?? 0) + 1;
    methodParameter['isOrigin'] = imageType;
    return methodResult['getImage'];
  }

  @override
  Future<bool> saveImage({required bool isOrigin, required File file, List<int>? compressedImage}) async {
    methodCallCount['saveImage'] = (methodCallCount['saveImage'] ?? 0) + 1;
    methodParameter['isOrigin'] = isOrigin;
    methodParameter['file'] = file;
    return methodResult['saveImage'];
  }

  @override
  Future<File> getCompressedImage() {
    methodCallCount['getImage'] = (methodCallCount['getImage'] ?? 0) + 1;
    return methodResult['getImage'];
  }

  @override
  Future<void> saveCompressedImage({required List<int> image}) async{
    return;
  }
}
