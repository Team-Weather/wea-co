import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/data/user/repository/user_auth_repository_impl.dart';
import 'package:weaco/domain/user/model/user_auth.dart';
import 'package:weaco/domain/user/model/user_profile.dart';
import 'package:weaco/domain/user/repository/user_auth_repository.dart';

import '../../../mock/data/user/data_source/mock_remote_user_profile_data_source.dart';
import '../../../mock/data/user/data_source/mock_user_auth_data_source.dart';

void main() {
  final MockUserAuthDataSourceImpl userAuthDataSource =
      MockUserAuthDataSourceImpl();
  final MockRemoteUserProfileDataSourceImpl userProfileDataSource =
      MockRemoteUserProfileDataSourceImpl();

  final UserAuthRepository userAuthRepository = UserAuthRepositoryImpl(
    userAuthDataSource: userAuthDataSource,
    remoteUserProfileDataSource: userProfileDataSource,
  );

  final userAuth = UserAuth(
    email: 'qoophon@gmail.com',
    password: 'password',
  );
  final userProfile = UserProfile(
    email: 'qoophon@gmail.com',
    nickname: '김동혁',
    gender: 1,
    profileImagePath: '/test/assets/image.jpg',
    feedCount: 0,
    createdAt: DateTime(2024, 05, 09),
  );

  group('UserAuthRepositoryImpl 클래스', () {
    setUp(() {
      userAuthDataSource.initMockData();
      userProfileDataSource.initMockData();
    });

    group('signUp() 메소드는', () {
      test('UserAuthDataSource.signUp() 메소드를 무조건 1회 호출한다.', () async {
        // given
        int expectCallCount = 1;

        // when
        await userAuthRepository.signUp(
          userAuth: userAuth,
          userProfile: userProfile,
        );

        // then
        expect(userAuthDataSource.signUpCallCount, expectCallCount);
      });

      test(
          'UserAuthDataSource.signUp() 이 성공하면'
          'RemoteUserProfileDataSource.saveUserProfile() 메소드를'
          '1회 호출한다.', () async {
        // given
        int expectCallCount = 1;

        userAuthDataSource.returnValue = true;

        // when
        await userAuthRepository.signUp(
          userAuth: userAuth,
          userProfile: userProfile,
        );

        // then
        expect(userProfileDataSource.saveUserProfileMethodCallCount,
            expectCallCount);
      });

      test(
          '인자로 받은 값을 각각 '
          'UserAuthDataSource.signUp(),'
          'RemoteUserProfileDataSource.saveUserProfile() 메소드에 그대로 전달한다.',
          () async {
        // given
        final expectUserAuth = userAuth.copyWith();
        final expectUserProfile = userProfile.copyWith();

        final expectUserAuthParameter = {
          'email': expectUserAuth.email,
          'password': expectUserAuth.password,
        };

        userAuthDataSource.returnValue = true;
        userProfileDataSource.isSaved = true;

        // when
        await userAuthRepository.signUp(
          userAuth: expectUserAuth,
          userProfile: expectUserProfile,
        );

        // then
        expect(userAuthDataSource.methodParameter, expectUserAuthParameter);
        expect(userProfileDataSource.methodUserProfileParameter,
            expectUserProfile);
      });

      group('signIn() 메소드는', () {
        test('UserAuthDataSource.signIn() 메소드를 1회 호출한다.', () async {
          // given
          int expectCallCount = 1;

          // when
          await userAuthRepository.signIn(
            userAuth: userAuth,
          );

          // then
          expect(userAuthDataSource.signInCallCount, expectCallCount);
        });

        test('인자로 받은 값을 UserAuthDataSource.signIn() 메소드에 그대로 전달한다.', () async {
          // given
          final expectUserAuth = userAuth.copyWith();

          final expectUserAuthParameter = {
            'email': expectUserAuth.email,
            'password': expectUserAuth.password,
          };

          // when
          await userAuthRepository.signIn(
            userAuth: expectUserAuth,
          );

          // then
          expect(userAuthDataSource.methodParameter, expectUserAuthParameter);
        });
      });

      group('logOut() 메소드는', () {
        test('UserAuthDataSource.logOut() 메소드를 1회 호출한다.', () async {
          // given
          int expectCallCount = 1;

          // when
          await userAuthRepository.logOut();

          // then
          expect(userAuthDataSource.logOutCallCount, expectCallCount);
        });
      });

      group('signOut() 메소드는', () {
        test('UserAuthDataSource.signOut() 메소드를 1회 호출한다.', () async {
          // given
          int expectCallCount = 1;

          // when
          await userAuthRepository.signOut();

          // then
          expect(userAuthDataSource.signOutCallCount, expectCallCount);
        });
      });
    });
  });
}
