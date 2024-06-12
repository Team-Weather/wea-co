import 'dart:io';
import 'package:weaco/core/enum/image_type.dart';
import 'package:weaco/data/file/data_source/local/local_file_data_source.dart';
import 'package:weaco/data/file/data_source/remote/remote_file_data_source.dart';
import 'package:weaco/domain/file/repository/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final LocalFileDataSource _localFileDataSource;
  final RemoteFileDataSource _remoteFileDataSource;

  FileRepositoryImpl(
      {required LocalFileDataSource localFileDataSource,
      required RemoteFileDataSource remoteFileDataSource})
      : _localFileDataSource = localFileDataSource,
        _remoteFileDataSource = remoteFileDataSource;

  @override
  Future<File> getImage({required ImageType imageType}) async {
    return await _localFileDataSource.getImage(imageType: imageType);
  }

  @override
  Future<void> saveImage({required bool isOrigin, required File file, required List<int> compressedImage}) async {
    await _localFileDataSource.saveCompressedImage(image: compressedImage);
    await _localFileDataSource.saveImage(isOrigin: isOrigin, file: file);
  }


  @override
  Future<List<String>> saveOotdImage() async {
    final File croppedImage = await _localFileDataSource.getImage(imageType: ImageType.cropped);
    final File compressedImage = await _localFileDataSource.getImage(imageType: ImageType.compressed);
    return await _remoteFileDataSource.saveImage(croppedImage: croppedImage, compressedImage: compressedImage);
  }
}
