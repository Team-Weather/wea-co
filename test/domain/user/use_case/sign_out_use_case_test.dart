import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/domain/user/use_case/sign_out_use_case.dart';

import '../../../mock/data/user/repository/mock_user_auth_repository_impl.dart';

void main() {
  group('SignOutUseCase 클래스', () {
    final userAuthRepository = MockUserAuthRepositoryImpl();
    final SignOutUseCase useCase =
        SignOutUseCase(userAuthRepository: userAuthRepository);

    group('execute() 메서드는', () {
      setUp(() => userAuthRepository.initMockData());

      test('userAuthRepository.signOut() 메서드를 1회 호출한다.', () async {
        // Given
        const int expectedResult = 1;

        // When
        await useCase.execute();
        final actual = userAuthRepository.signOutCallCount;

        // Then
        expect(actual, expectedResult);
      });
    });
  });
}
