import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/feed/use_case/get_detail_feed_detail_use_case.dart';
import 'package:weaco/domain/location/model/location.dart';
import 'package:weaco/domain/weather/model/weather.dart';

import '../../../mock/data/feed/repository/mock_feed_repository_impl.dart';



void main() {
  group('GetDetailFeedDetailUseCase 클래스', () {
    final feedRepository = MockFeedRepositoryImpl();
    final getDetailFeedDetailUseCase =
        GetDetailFeedDetailUseCase(feedRepository: feedRepository);

    setUp(() => feedRepository.initMockData());

    group('getFeed 메소드는', () {
      test('파라미터로 받은 id를 FeedRepository.getFeed에 넘긴다.', () async {
        // Given
        const String expectedId = 'id';
        feedRepository.getFeedResult = Feed(
          id: 'id',
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
        await getDetailFeedDetailUseCase.execute(id: expectedId);

        // Then
        expect(feedRepository.methodParameterMap[expectedId], expectedId);
      });

      test('FeedRepository.getFeed를 호출하고 반환 받은 값을 그대로 반환한다.', () async {
        // Given
        const int expectedCallCount = 1;
        final expectedFeed = Feed(
          id: 'id',
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
        feedRepository.getFeedResult = expectedFeed;

        // When
        final actual = await getDetailFeedDetailUseCase.execute(id: '1');

        // Then
        expect(actual, expectedFeed);
        expect(feedRepository.getFeedCallCount, expectedCallCount);
      });
    });
  });
}
