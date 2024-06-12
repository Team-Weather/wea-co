import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/core/enum/image_type.dart';
import 'package:weaco/core/path_provider/path_provider_service.dart';
import 'local_file_data_source.dart';

class LocalFileDataSourceImpl implements LocalFileDataSource {
  final _originImageFileName = 'origin.png';
  final _croppedImageFileName = 'cropped.png';
  final _compressedImageFileName = 'compressed.png';
  final PathProviderService _pathProvider;

  LocalFileDataSourceImpl({required PathProviderService pathProvider})
      : _pathProvider = pathProvider;

  @override
  Future<File> getImage({required ImageType imageType}) async {
    try {
      final directory = await _pathProvider.getCacheDirectory();
      String fileName = switch (imageType) {
        ImageType.origin => _originImageFileName,
        ImageType.cropped => _croppedImageFileName,
        ImageType.compressed => _compressedImageFileName,
      };
      if (!await File('$directory/$fileName').exists()) throw ExceptionCode.notFoundException;

      return File('$directory/$fileName');
    } catch (e) {
      throw _exceptionHandling(e);
    }
  }

  @override
  Future<void> saveImage({required bool isOrigin, required File file}) async {
    try {
      final directory = await _pathProvider.getCacheDirectory();
      String fileName = isOrigin ? _originImageFileName : _croppedImageFileName;
      if (await File('$directory/$fileName').exists()) {
        await File('$directory/$fileName').delete();
      }
      await File('$directory/$fileName').writeAsBytes(await file.readAsBytes());
    } catch (e) {
      _exceptionHandling(e);
    }
  }

  @override
  Future<File> getCompressedImage() async {
    try {
      final directory = await _pathProvider.getCacheDirectory();
      await File('$directory/$_compressedImageFileName').exists();

      return File('$directory/$_compressedImageFileName');
    } catch (e) {
      throw _exceptionHandling(e);
    }
  }

  @override
  Future<void> saveCompressedImage({required List<int> image}) async {
    try {
      final directory = await _pathProvider.getCacheDirectory();
      if (await File('$directory/$_compressedImageFileName').exists()) {
        await File('$directory/$_compressedImageFileName').delete();
      }
      await File('$directory/$_compressedImageFileName').writeAsBytes(image);
    } catch (e) {
      _exceptionHandling(e);
    }
  }

  ExceptionCode _exceptionHandling(Object e) {
    return switch (e) {
      FirebaseException _ => ExceptionCode.internalServerException,
      DioException _ => ExceptionCode.internalServerException,
      ExceptionCode _ => e,
      _ => ExceptionCode.unknownException,
    };
  }
}
