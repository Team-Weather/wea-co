import 'dart:io';
import 'package:weaco/domain/common/util/image_compressor.dart';
import 'package:weaco/domain/file/repository/file_repository.dart';

class SaveImageUseCase {
  final FileRepository _fileRepository;
  final ImageCompressor _imageCompressor;

  SaveImageUseCase(
      {required FileRepository fileRepository,
      required ImageCompressor imageCompressor})
      : _fileRepository = fileRepository,
        _imageCompressor = imageCompressor;

  /// 레포지토리에 이미지 파일 데이터를 전달하여 저장을 요청
  /// @param isOrigin: 원본 이미지 = true, 크롭된 이미지 = false
  /// @param file: 저장할 이미지 데이터
  /// @return: 데이터 저장 성공 여부 반환
  Future<void> execute({required bool isOrigin, required File file}) async {
    final List<int> compressedImage = await _imageCompressor.compressImage(file: file);
    await _fileRepository.saveImage(isOrigin: isOrigin, file: file, compressedImage: compressedImage);
  }
}
