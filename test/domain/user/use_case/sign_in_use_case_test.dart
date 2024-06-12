import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/domain/user/model/user_auth.dart';
import 'package:weaco/domain/user/use_case/sign_in_use_case.dart';

import '../../../mock/data/user/repository/mock_user_auth_repository_impl.dart';

void main() {
  final mockUserAuthRepositoryImpl = MockUserAuthRepositoryImpl();

  final SignInUseCase signInUseCase =
      SignInUseCase(userAuthRepository: mockUserAuthRepositoryImpl);

  setUp(() {
    mockUserAuthRepositoryImpl.initMockData();
  });

  group('SignInUseCase 클래스', () {
    group('execute() 메소드는', () {
      test('UserAuthRepository.signIn() 메소드를 1회 호출한다.', () async {
        int expectCallCount = 1;

        final expectParameter = UserAuth(
          email: 'qoophon@gmail.com',
          password: 'password',
        );

        await signInUseCase.execute(userAuth: expectParameter);

        expect(mockUserAuthRepositoryImpl.signInCallCount, expectCallCount);
      });
      test('전달받은 인자를 그대로 UserAuthRepository.signIn() 로 전달한다.', () async {
        final expectParameter = UserAuth(
          email: 'qoophon@gmail.com',
          password: 'password',
        );

        await signInUseCase.execute(userAuth: expectParameter);

        expect(mockUserAuthRepositoryImpl.methodParameter, expectParameter);
      });
    });
  });
}
