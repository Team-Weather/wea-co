import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/data/user/data_source/remote_user_profile_data_source.dart';
import 'package:weaco/data/user/data_source/remote_user_profile_date_source_impl.dart';
import 'package:weaco/domain/user/model/user_profile.dart';

import '../../../mock/core/firebase/mock_firebase_auth_service.dart';

void main() async {
  final instance = FakeFirebaseFirestore();
  final firebaseService = MockFirebaseAuthService();

  final RemoteUserProfileDataSource dataSource =
      RemoteUserProfileDataSourceImpl(
          firestore: instance, firebaseService: firebaseService);

  group(
    'RemoteUserProfileDataSource 클래스',
    () {
      setUp(() => firebaseService.initMockData());

      test('saveUserProfile()은 firebase storage에 파라미터로 받은 유저 프로필 정보를 저장한다.',
          () async {
        // Given
        final expectedUserProfile = UserProfile(
          email: 'test@gmail.com',
          nickname: '테스트',
          gender: 1,
          profileImagePath:
              'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
          feedCount: 0,
          createdAt: DateTime.parse('2024-05-01 13:27:00'),
        );

        // When
        await dataSource.saveUserProfile(userProfile: expectedUserProfile);

        final actual = await instance
            .collection('user_profiles')
            .where('email', isEqualTo: 'test@gmail.com')
            .get();

        final data = actual.docs.first.data()['email'];

        // Then
        expect(data, expectedUserProfile.email);
      });
      test(
          'getUserProfile()은 firebase storage에서 파라미터로 받은 이메일과 동일한 유저 프로필 정보를 반환한다.',
          () async {
        // Given
        await instance.collection('user_profiles').add({
          'created_at': DateTime.parse('2024-05-01 13:27:00'),
          'deleted_at': null,
          'email': 'hoogom87@gmail.com',
          'feed_count': 0,
          'gender': 1,
          'nickname': '호구몬',
          'profile_image_path':
              'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg'
        });

        // When
        final UserProfile res =
            await dataSource.getUserProfile(email: 'hoogom87@gmail.com');

        final expectProfile = UserProfile(
          email: 'hoogom87@gmail.com',
          nickname: '호구몬',
          gender: 1,
          profileImagePath:
              'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
          feedCount: 0,
          createdAt: DateTime.parse('2024-05-01 13:27:00'),
          deletedAt: null,
        );

        // Then
        expect(res, expectProfile);
      });

      test(
        'getUserProfile() email 이 null 일 경우, 현재 유저 프로필 정보를 반환한다.',
        () async {
          // Given
          await instance.collection('user_profiles').add({
            'created_at': DateTime.parse('2024-05-08 02:27:00'),
            'deleted_at': null,
            'email': firebaseService.user?.email,
            'feed_count': 0,
            'gender': 1,
            'nickname': '호구몬',
            'profile_image_path':
                'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg'
          });

          final expectProfile = UserProfile(
            email: 'bob@somedomain.com',
            nickname: '호구몬',
            gender: 1,
            profileImagePath:
                'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
            feedCount: 0,
            createdAt: DateTime.parse('2024-05-08 02:27:00'),
            deletedAt: null,
          );

          // When
          final result = await dataSource.getUserProfile();

          // Then
          expect(result, expectProfile);
        },
      );
      test(
        'removeUserProfile()은 firebase storage에서 파라미터로 받은 이메일과 동일한 유저 프로필 정보를 삭제한다.',
        () async {
          // Given
          const email = 'test@gmail.com';
          await instance.collection('user_profiles').add({
            'created_at': '2024-05-01 13:27:00',
            'deleted_at': null,
            'email': email,
            'feed_count': 0,
            'gender': 1,
            'nickname': '호구몬',
            'profile_image_path':
                'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg'
          });

          // When
          await dataSource.removeUserProfile(email: email);
          final actual = await instance
              .collection('user_profiles')
              .where('email', isEqualTo: 'test@gmail.com')
              .get();

          final data = actual.docs.first.data()['deleted_at'];

          // Then
          expect(data != null, true);
        },
      );

      test(
        'removeUserProfile()은 userProfile 이 null 일 경우, 현재 유저 프로필 정보를 삭제한다.',
        () async {
          // Given
          await instance.collection('user_profiles').add({
            'created_at': '2024-05-08 02:27:00',
            'deleted_at': null,
            'email': firebaseService.user?.email,
            'feed_count': 0,
            'gender': 1,
            'nickname': '호구몬',
            'profile_image_path':
                'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg'
          });

          // When
          await dataSource.removeUserProfile();
          final actual = await instance
              .collection('user_profiles')
              .where('email', isEqualTo: firebaseService.user?.email)
              .get();

          final data = actual.docs.first.data()['deleted_at'];

          // Then
          expect(data != null, true);
        },
      );
    },
  );
}
