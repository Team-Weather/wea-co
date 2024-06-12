import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/domain/feed/use_case/remove_my_page_feed_use_case.dart';
import '../../../mock/data/feed/repository/mock_ootd_feed_repository_impl.dart';

void main() {
  group('RemoveMyPageFeedUseCase 클래스', () {
    final mockOotdFeedRepository = MockOotdFeedRepositoryImpl();
    final RemoveMyPageFeedUseCase useCase =
        RemoveMyPageFeedUseCase(ootdFeedRepository: mockOotdFeedRepository);
    setUp(() => mockOotdFeedRepository.initMockData());
    group('execute 메소드는', () {
      test('파라미터로 전달받은 id를 OotdFeedRepository에 그대로 전달한다.', () async {
        // Given
        const expected = 'id';
        // mockOotdFeedRepository.

        // When
        await useCase.execute(id: expected);

        // Then
        expect(mockOotdFeedRepository.removeOotdFeedParamId, expected);
      });

      test('OotdFeedRepository.removeOotdFeed를 한번 호출한다.', () async {
        // Given
        const expected = 1;

        // When
        await useCase.execute(id: 'id');

        // Then
        expect(mockOotdFeedRepository.removeOotdFeedCallCount, expected);
      });
    });
  });
}
