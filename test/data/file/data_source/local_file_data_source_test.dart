import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/core/enum/image_type.dart';
import 'package:weaco/core/path_provider/path_provider_service.dart';
import 'package:weaco/data/file/data_source/local/local_file_data_source.dart';
import 'package:weaco/data/file/data_source/local/local_file_data_source_impl.dart';

import '../../../mock/core/path_provider/mock_path_provider_service_impl.dart';


void main() {
  group('LocalFileDataSourceImpl 클래스', () {
    final PathProviderService mockPathProvider = MockPathProviderServiceImpl();
    final LocalFileDataSource dataSource =
        LocalFileDataSourceImpl(pathProvider: mockPathProvider);

    group('getImage 메서드는', () {
      setUp(() {
        if (File('test/mock/assets/origin.png').existsSync()) {
          File('test/mock/assets/origin.png').deleteSync();
        }

        if (File('test/mock/assets/cropped.png').existsSync()) {
          File('test/mock/assets/cropped.png').deleteSync();
        }
      });

      test('imageType 인자가 ImageType.origin일 경우, origin.png를 반환한다.', () async {
        // Given
        const imageType = ImageType.origin;
        File('test/mock/assets/origin.png').writeAsBytesSync(
            File('test/mock/assets/test_image.png').readAsBytesSync());

        // When
        File? file = await dataSource.getImage(imageType: imageType);

        // Then
        expect(file.readAsBytesSync(),
            File('test/mock/assets/origin.png').readAsBytesSync());
      });

      test('imageType 인자가 ImageType.cropped일 경우, cropped.png를 반환한다.', () async {
        // Given
        const imageType = ImageType.cropped;
        File('test/mock/assets/cropped.png').writeAsBytesSync(
            File('test/mock/assets/test_image.png').readAsBytesSync());

        // When
        File? file = await dataSource.getImage(imageType: imageType);

        // Then
        expect(file.readAsBytesSync(),
            File('test/mock/assets/cropped.png').readAsBytesSync());
      });

      test('찾으려는 파일이 없는 경우, ExceptionCode.notFoundException 예외를 던진다.', () async {
        // Given
        const imageType = ImageType.cropped;

        // When, Then
        expect(dataSource.getImage(imageType: imageType), throwsA(ExceptionCode.notFoundException));
      });
    });

    group('saveImage 메서드는', () {
      tearDown(() async {
        if (File('test/mock/assets/origin.png').existsSync()) {
          File('test/mock/assets/origin.png').deleteSync();
        }

        if (File('test/mock/assets/cropped.png').existsSync()) {
          File('test/mock/assets/cropped.png').deleteSync();
        }
      });

      test('isOrigin 인자가 true일 경우, file 인자를 origin.png로 저장한다.', () async {
        // Given
        const isOrigin = true;
        File file = File('test/mock/assets/test_image.png');

        // When
        await dataSource.saveImage(isOrigin: isOrigin, file: file);

        // Then
        expect(File('test/mock/assets/origin.png').readAsBytesSync(),
            file.readAsBytesSync());
      });

      test('isOrigin 인자가 false일 경우, file 인자를 cropped.png로 저장한다.', () async {
        // Given
        const isOrigin = false;
        File file = File('test/mock/assets/test_image.png');

        // When
        await dataSource.saveImage(isOrigin: isOrigin, file: file);

        // Then
        expect(File('test/mock/assets/cropped.png').readAsBytesSync(),
            file.readAsBytesSync());
      });

      test('저장하려는 파일명과 동일한 파일이 이미 있는 경우, 해당 파일을 삭제한다.', () async {
        // Given
        const isOrigin = true;
        File('test/mock/assets/origin.png').writeAsBytesSync(
            File('test/mock/assets/test_image2.png').readAsBytesSync());
        File file = File('test/mock/assets/test_image.png');

        // When
        await dataSource.saveImage(isOrigin: isOrigin, file: file);

        // Then
        expect(File('test/mock/assets/origin.png').readAsBytesSync(),
            file.readAsBytesSync());
      });
    });
  });
}
