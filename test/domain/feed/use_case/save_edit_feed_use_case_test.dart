import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/feed/use_case/save_edit_feed_use_case.dart';
import 'package:weaco/domain/location/model/location.dart';
import 'package:weaco/domain/weather/model/weather.dart';
import '../../../mock/data/feed/repository/mock_ootd_feed_repository_impl.dart';

void main() {
  group('SaveEditFeedUseCase 클래스', () {
    final ootdFeedRepository = MockOotdFeedRepositoryImpl();
    final saveEditFeedUseCase =
        SaveEditFeedUseCase(ootdFeedRepository: ootdFeedRepository);

    setUp(() => ootdFeedRepository.initMockData());

    group('execute 메소드는', () {
      test('OotdFeedRepository.saveFeed를 한번 호출한다.', () async {
        // Given
        const int expectedCallCount = 1;

        final mockFeedNew = Feed(
          id: '',
          imagePath: 'imagePath',
          thumbnailImagePath: 'thumbnailImagePath',
          userEmail: 'userEmail',
          description: 'description',
          weather: Weather(
            temperature: 1,
            timeTemperature: DateTime.now(),
            code: 1,
            createdAt: DateTime.now(),
          ),
          seasonCode: 1,
          location: Location(
            lat: 1,
            lng: 1,
            city: 'city',
            createdAt: DateTime.now(),
          ),
          createdAt: DateTime.now(),
          deletedAt: null,
        );

        // When
        await saveEditFeedUseCase.execute(feed: mockFeedNew);

        // Then
        expect(ootdFeedRepository.saveOotdFeedCallCount, expectedCallCount);
      });
    });
  });
}
