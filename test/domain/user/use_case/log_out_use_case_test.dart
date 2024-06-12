import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/domain/user/use_case/log_out_use_case.dart';

import '../../../mock/data/user/repository/mock_user_auth_repository_impl.dart';

void main() {
  group('LogOutUseCase 클래스', () {
    final userAuthRepository = MockUserAuthRepositoryImpl();
    final LogOutUseCase useCase =
        LogOutUseCase(userAuthRepository: userAuthRepository);

    setUp(() => userAuthRepository.initMockData());

    group('logOut 메서드는', () {
      test('한 번 호출 된다.', () async {
        // Given
        int expectedResult = 1;

        // When
        await useCase.execute();
        final actual = userAuthRepository.logOutCallCount;

        // Then
        expect(actual, expectedResult);
      });
    });
  });
}
