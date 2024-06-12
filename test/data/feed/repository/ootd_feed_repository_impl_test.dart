import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/data/feed/repository/ootd_feed_repository_impl.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/location/model/location.dart';
import 'package:weaco/domain/user/model/user_profile.dart';
import 'package:weaco/domain/weather/model/weather.dart';

import '../../../mock/core/firebase/mock_firestore_service_impl.dart';
import '../../../mock/data/feed/data_source/mock_remote_feed_data_source.dart';
import '../../../mock/data/file/repository/mock_file_repository_impl.dart';
import '../../../mock/data/user/data_source/mock_remote_user_profile_data_source.dart';

void main() {
  group('OotdFeedRepositoryImpl 클래스', () {
    final fileRepository = MockFileRepositoryImpl();
    final remoteFeedDataSource = MockRemoteFeedDataSource();
    final remoteUserProfileDatSource = MockRemoteUserProfileDataSourceImpl();
    final mockTransactionService = MockFirestoreServiceImpl();

    final ootdFeedRepository = OotdFeedRepositoryImpl(
      fileRepository: fileRepository,
      remoteFeedDataSource: remoteFeedDataSource,
      remoteUserProfileDataSource: remoteUserProfileDatSource,
      firestoreService: mockTransactionService,
    );
    const String feedId = '1';

    final Weather mockWeather = Weather(
      temperature: 31,
      timeTemperature: DateTime.parse('2024-05-06'),
      code: 1,
      createdAt: DateTime.parse('2024-05-06'),
    );
    final Location mockLocation = Location(
      lat: 31.23,
      lng: 29.48,
      city: '서울시, 노원구',
      createdAt: DateTime.parse('2024-05-06'),
    );
    final mockFeed = Feed(
      id: null,
      imagePath: '',
      thumbnailImagePath: '',
      userEmail: 'test@email.com',
      description: 'This is a test feed',
      weather: mockWeather,
      seasonCode: 2,
      location: mockLocation,
      createdAt: DateTime.parse('2024-05-06'),
    );

    final mockUserProfile = UserProfile(
      email: 'test@email.com',
      nickname: 'nickname',
      gender: 1,
      profileImagePath: 'profileImagePath',
      feedCount: 0,
      createdAt: DateTime.parse('2024-05-06'),
    );

    setUp(() {
      fileRepository.initMockData();
      remoteFeedDataSource.cleanUpMockData();
      remoteUserProfileDatSource.initMockData();
      remoteUserProfileDatSource.getUserProfileResult = mockUserProfile;
    });

    group('saveOotdFeed 메서드는', () {
      test('피드를 저장하기 위해 FileRepository.saveOotdImage()를 한 번 호출한다.', () async {
        // Given
        const expectedCallCount = 1;

        // When
        await ootdFeedRepository.saveOotdFeed(feed: mockFeed);

        // Then
        expect(fileRepository.saveOotdImageCallCount, expectedCallCount);
      });

      test('피드를 저장하기 위해 RemoteFeedDataSourceImpl.saveFeed()를 한 번 호출한다.',
          () async {
        // Given
        const expectedCallCount = 1;

        // When
        await ootdFeedRepository.saveOotdFeed(feed: mockFeed);

        // Then
        expect(remoteFeedDataSource.saveFeedMethodCallCount, expectedCallCount);
      });

      test(
          '파라미터로 받은 feed 에 FileRepository.saveOotdImage()로 받은 path 를 '
          '추가한 새로운 피드를 RemoteFeedDataSourceImpl.saveFeed()에 전달한다.', () async {
        // Given
        const String path = '';
        fileRepository.saveOotdImageResult = [path, path];

        // 예상 값
        final expectedFeed = mockFeed.copyWith(imagePath: path);

        // When
        await ootdFeedRepository.saveOotdFeed(feed: mockFeed);

        // Then
        expect(remoteFeedDataSource.paramMap['saveFeedParam'], expectedFeed);
      });

      test(
          '유저 피드 카운트를 업데이트하기 위해 RemoteUserProfileDataSourceImpl.getUserProfile()를 한 번 호출한다.',
          () async {
        // Given
        const expectedCallCount = 1;

        // When
        await ootdFeedRepository.saveOotdFeed(feed: mockFeed);

        // Then
        expect(remoteUserProfileDatSource.getUserProfileMethodCallCount,
            expectedCallCount);
      });

      test(
          '유저 피드 카운트를 업데이트하기 위해 RemoteUserProfileDataSourceImpl.updateUserProfile()를 한 번 호출한다.',
          () async {
        // Given
        const expectedCallCount = 1;

        // When
        await ootdFeedRepository.saveOotdFeed(feed: mockFeed);

        // Then
        expect(remoteUserProfileDatSource.updateUserProfileMethodCallCount,
            expectedCallCount);
      });

      test(
          '가져온 유저 피드 카운트에 1을 더한 userProfile 을 '
          'RemoteUserProfileDataSourceImpl.updateUserProfile()에 전달한다.',
          () async {
        // Given
        final expectedUseProfile =
            mockUserProfile.copyWith(feedCount: mockUserProfile.feedCount + 1);

        // When
        await ootdFeedRepository.saveOotdFeed(feed: mockFeed);

        // Then
        expect(remoteUserProfileDatSource.methodUserProfileParameter,
            expectedUseProfile);
      });

      test(
          '파라미터로 전달받은 Feed의 id값이 있으면 수정하는 Feed로써'
          'RemoteFeedDataSourceImpl.saveFeed()를 한번 호출한다.', () async {
        // Given
        const int expected = 1;

        // When
        await ootdFeedRepository.saveOotdFeed(feed: mockFeed.copyWith(id: '1'));

        // Then
        expect(remoteFeedDataSource.saveFeedMethodCallCount, expected);
      });

      test(
          '파라미터로 전달받은 Feed의 id값이 있으면 수정하는 Feed로써 FileRepository.saveOotdImage()를 호출하지 않는다.',
          () async {
        // Given
        const int expected = 0;

        // When
        await ootdFeedRepository.saveOotdFeed(feed: mockFeed.copyWith(id: '1'));

        // Then
        expect(fileRepository.saveImageCallCount, expected);
      });

      test(
          '파라미터로 전달받은 Feed의 id값이 있으면 수정하는 Feed로써 RemoteUserProfileDataSourceImpl.getUserProfile()를 호출하지 않는다.',
          () async {
        // Given
        const int expected = 0;

        // When
        await ootdFeedRepository.saveOotdFeed(feed: mockFeed.copyWith(id: '1'));

        // Then
        expect(
            remoteUserProfileDatSource.getUserProfileMethodCallCount, expected);
      });
    });

    group('removeOotdFeed 메서드는', () {
      test('피드를 삭제하기 위해 RemoteFeedDataSourceImpl.deleteFeed()를 한 번 호출한다.',
          () async {
        // Given
        const expectedCallCount = 1;

        // When
        await ootdFeedRepository.removeOotdFeed(id: feedId);

        // Then
        expect(
            remoteFeedDataSource.deleteFeedMethodCallCount, expectedCallCount);
      });

      test(
          '유저 피드 카운트를 업데이트하기 위해 RemoteUserProfileDataSourceImpl.getUserProfile()를 한 번 호출한다.',
          () async {
        // Given
        const expectedCallCount = 1;

        // When
        await ootdFeedRepository.removeOotdFeed(id: feedId);

        // Then
        expect(remoteUserProfileDatSource.getUserProfileMethodCallCount,
            expectedCallCount);
      });

      test(
          '유저 피드 카운트를 업데이트하기 위해 RemoteUserProfileDataSourceImpl.updateUserProfile()를 한 번 호출한다.',
          () async {
        // Given
        const expectedCallCount = 1;

        // When
        await ootdFeedRepository.removeOotdFeed(id: feedId);

        // Then
        expect(remoteUserProfileDatSource.updateUserProfileMethodCallCount,
            expectedCallCount);
      });

      test(
          '가져온 유저 피드 카운트에 1을 뺀 값을 RemoteUserProfileDataSourceImpl.updateUserProfile()에 전달한다.',
          () async {
        // Given
        final expectedUserProfile =
            mockUserProfile.copyWith(feedCount: mockUserProfile.feedCount - 1);

        // When
        // remove 메소드에 run transaction에 await 없었음
        await ootdFeedRepository.removeOotdFeed(id: feedId);

        // Then
        expect(remoteUserProfileDatSource.methodUserProfileParameter,
            expectedUserProfile);
      });
    });
  });
}
