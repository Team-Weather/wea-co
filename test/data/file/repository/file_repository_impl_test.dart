import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/core/enum/image_type.dart';
import 'package:weaco/data/file/repository/file_repository_impl.dart';
import 'package:weaco/domain/file/repository/file_repository.dart';

import '../../../mock/data/file/data_source/local/mock_local_file_data_source_impl.dart';
import '../../../mock/data/file/data_source/remote/mock_remote_file_data_source_impl.dart';

void main() {
  group('FileRepositoryImpl 클래스', () {
    final mockLocalFileDataSource = MockLocalFileDataSourceImpl();
    final mockRemoteFileDataSource = MockRemoteFileDataSourceImpl();
    final FileRepository fileRepository = FileRepositoryImpl(
        localFileDataSource: mockLocalFileDataSource,
        remoteFileDataSource: mockRemoteFileDataSource);

    setUp(() {
      mockRemoteFileDataSource.initMockData();
      mockLocalFileDataSource.initMockData();
    });

    group('getImage 메서드는', () {
      test('인자를 LocalFileDataSource.getImage()에 파라미터로 그대로 전달한다.', () async {
        // Given
        const ImageType imageType = ImageType.origin;

        // When
        await fileRepository.getImage(imageType: imageType);

        // Then
        expect(mockLocalFileDataSource.methodParameter['isOrigin'], imageType);
      });

      test('LocalFileDataSource.getImage()을 한번 호출한다.', () async {
        // Given
        const ImageType imageType = ImageType.origin;

        // When
        await fileRepository.getImage(imageType: imageType);

        // Then
        expect(mockLocalFileDataSource.methodCallCount['getImage'], 1);
      });

      test('LocalFileDataSource.getImage()의 반환 값을 그대로 반환한다.', () async {
        // Given
        const ImageType imageType = ImageType.origin;
        final File expectResult = File('test/mock/assets/test_image.png');
        mockLocalFileDataSource.methodResult['getImage'] = expectResult;

        // When
        await fileRepository.getImage(imageType: imageType);

        // Then
        expect(mockLocalFileDataSource.methodResult['getImage'], expectResult);
      });
    });

    group('saveImage 메서드는', () {

      test('인자를 LocalFileDataSource.saveImage()에 파라미터로 그대로 전달한다.', () async {
        // Given
        const bool isOrigin = true;
        final File file = File('test/mock/assets/test_image.png');
        mockLocalFileDataSource.methodResult['saveImage'] = true;

        // When
        await fileRepository.saveImage(isOrigin: isOrigin, file: file, compressedImage: file.readAsBytesSync());

        // Then
        expect(mockLocalFileDataSource.methodParameter['isOrigin'], isOrigin);
        expect(mockLocalFileDataSource.methodParameter['file'], file);
      });

      test('LocalFileDataSource.saveImage()을 한번 호출한다.', () async {
        // Given
        const bool isOrigin = true;
        final File file = File('test/mock/assets/test_image.png');
        mockLocalFileDataSource.methodResult['saveImage'] = true;

        // When
        await fileRepository.saveImage(isOrigin: isOrigin, file: file, compressedImage: file.readAsBytesSync());

        // Then
        expect(mockLocalFileDataSource.methodCallCount['saveImage'], 1);
      });

      test('LocalFileDataSource.getImage()의 반환 값을 그대로 반환한다.', () async {
        // Given
        const bool isOrigin = true;
        final File file = File('test/mock/assets/test_image.png');
        const bool expectResult = false;
        mockLocalFileDataSource.methodResult['saveImage'] = expectResult;

        // When
        await fileRepository.saveImage(isOrigin: isOrigin, file: file, compressedImage: file.readAsBytesSync());

        // Then
        expect(mockLocalFileDataSource.methodResult['saveImage'], expectResult);
      });
    });

    group('saveOotdImage 메서드는', () {
      test('LocalFileDataSource.getImage()의 imageType 파라미터 값으로 ImageType.compressed를 전달한다.',
          () async {
        // Given
        const ImageType expectedParameter = ImageType.compressed;
        mockLocalFileDataSource.methodResult['getImage'] = File('test/mock/assets/test_image.png');
        mockRemoteFileDataSource.methodResult['saveImage'] = ['test/mock/assets/test_image.png', 'test/mock/assets/test_image.png'];

        // When
        await fileRepository.saveOotdImage();

        // Then
        expect(mockLocalFileDataSource.methodParameter['isOrigin'],
            expectedParameter);
      });

      test('LocalFileDataSource.getImage()을 두번 호출한다.', () async {
        // Given
        mockLocalFileDataSource.methodResult['getImage'] = File('test/mock/assets/test_image.png');
        mockRemoteFileDataSource.methodResult['saveImage'] = ['test/mock/assets/test_image.png', 'test/mock/assets/test_image.png'];

        // When
        await fileRepository.saveOotdImage();

        // Then
        expect(mockLocalFileDataSource.methodCallCount['getImage'], 2);
      });

      test('RemoteFileDataSource.saveImage()의 반환 값을 그대로 반환한다.', () async {
        // Given
        const List<String> expectResult = ['test/mock/assets/test_image.png', 'test/mock/assets/test_image.png'];
        mockLocalFileDataSource.methodResult['getImage'] = File('test/mock/assets/test_image.png');
        mockRemoteFileDataSource.methodResult['saveImage'] = expectResult;

        // When
        final result = await fileRepository.saveOotdImage();

        // Then
        expect(result, expectResult);
      });
    });
  });
}
