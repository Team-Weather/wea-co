import 'dart:io';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/core/enum/image_type.dart';
import 'package:weaco/core/path_provider/path_provider_service.dart';
import 'package:weaco/data/file/data_source/local/local_file_data_source.dart';
import 'package:weaco/data/file/data_source/local/local_file_data_source_impl.dart';
import 'package:weaco/data/file/data_source/remote/remote_file_data_source.dart';
import 'package:weaco/data/file/data_source/remote/remote_file_data_source_impl.dart';

import '../../../mock/core/firebase/mock_firebase_auth_service.dart';
import '../../../mock/core/path_provider/mock_path_provider_service_impl.dart';

void main() {
  final PathProviderService mockPathProvider = MockPathProviderServiceImpl();
  final LocalFileDataSource localFileDataSource =
      LocalFileDataSourceImpl(pathProvider: mockPathProvider);

  final MockFirebaseAuthService mockFirebaseAuthService = MockFirebaseAuthService();

  final MockFirebaseStorage storage = MockFirebaseStorage();
  final RemoteFileDataSource remoteFileDataSource =
      RemoteFileDataSourceImpl(firebaseStorage: storage, firebaseAuthService: mockFirebaseAuthService);

  group('RemoteFileDataSourceImpl 클래스', () {
    setUp(() => mockFirebaseAuthService.initMockData());
    tearDown(() {
      if (File('test/mock/assets/cropped.png').existsSync()) {
        File('test/mock/assets/cropped.png').deleteSync();
      }
    });

    group('saveImage() 메소드는', () {
      test('File 객체를 인자로 받아 업로드하고 다운로드 경로를 반환한다.', () async {
        // Given
        const email = 'bob@somedomain.com';
        File('test/mock/assets/cropped.png').writeAsBytesSync(
            File('test/mock/assets/test_image.png').readAsBytesSync());
        File('test/mock/assets/compressed.png').writeAsBytesSync(
            File('test/mock/assets/test_image.png').readAsBytesSync());

        final bucketPath = await storage.ref().child('').getDownloadURL();

        // When
        File? croppedImage = await localFileDataSource.getImage(imageType: ImageType.cropped);
        File? compressedImage = await localFileDataSource.getImage(imageType: ImageType.compressed);

        final path =
            await remoteFileDataSource.saveImage(croppedImage: croppedImage, compressedImage: compressedImage);

        expect(path[0].startsWith('${bucketPath}feed_origin_images/$email'), true);
        expect(path[1].startsWith('${bucketPath}feed_thumbnail_images/$email'), true);
            });
    });
  });
}
