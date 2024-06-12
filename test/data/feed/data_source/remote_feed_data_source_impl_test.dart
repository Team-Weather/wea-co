import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/core/firebase/firestore_dto_mapper.dart';
import 'package:weaco/data/feed/data_source/remote_feed_data_source.dart';
import 'package:weaco/data/feed/data_source/remote_feed_data_source_impl.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/location/model/location.dart';
import 'package:weaco/domain/weather/model/daily_location_weather.dart';
import 'package:weaco/domain/weather/model/weather.dart';

void main() {
  final fakeFirestore = FakeFirebaseFirestore();
  final RemoteFeedDataSource dataSource =
      RemoteFeedDataSourceImpl(fireStore: fakeFirestore);

  tearDown(() {
    fakeFirestore.clearPersistence();
  });

  group(
    'RemoteFeedDataSourceImpl 클래스',
    () {
      group(
        'saveFeed()는',
        () {
          test('Firestore에 Feed를 저장 요청을 보낸다.', () async {
            // Given
            Weather mockWeather = Weather(
              temperature: 31,
              timeTemperature: DateTime.parse('2024-05-06'),
              code: 1,
              createdAt: DateTime.parse('2024-05-06'),
            );
            Location mockLocation = Location(
              lat: 31.23,
              lng: 29.48,
              city: '서울시, 노원구',
              createdAt: DateTime.parse('2024-05-06'),
            );
            final mockFeed = Feed(
              id: 'id',
              imagePath: 'imagePath',
              thumbnailImagePath: 'thumbnailImagePath',
              userEmail: 'test@email.com',
              description: 'This is a test feed',
              weather: mockWeather,
              seasonCode: 2,
              location: mockLocation,
              createdAt: DateTime.parse('2024-05-06'),
            );

            // When
            await fakeFirestore.runTransaction((transaction) async {
              return await dataSource.saveFeed(
                transaction: transaction,
                feed: mockFeed,
              );
            });
            final snapshot =
                await fakeFirestore.collection('feeds').doc(mockFeed.id).get();
            // Then
            expect(mockFeed.userEmail, snapshot['user_email']);
          });

          test(
            'Firestore에 데이터를 추가해야 한다.',
            () async {
              // Given
              Weather mockWeather = Weather(
                temperature: 31,
                timeTemperature: DateTime.parse('2024-05-06'),
                code: 1,
                createdAt: DateTime.parse('2024-05-06'),
              );
              Location mockLocation = Location(
                lat: 31.23,
                lng: 29.48,
                city: '서울시, 노원구',
                createdAt: DateTime.parse('2024-05-06'),
              );
              DateTime dateTime = DateTime.parse('2024-05-06');

              final mockFeed = Feed(
                id: 'gyubro',
                imagePath: 'imagePath',
                thumbnailImagePath: 'thumbnailImagePath',
                userEmail: 'test@email.com',
                description: 'This is a test feed',
                weather: mockWeather,
                seasonCode: 2,
                location: mockLocation,
                createdAt: dateTime,
              );
              await fakeFirestore.runTransaction((transaction) async {
                return await dataSource.saveFeed(
                  transaction: transaction,
                  feed: mockFeed,
                );
              });

              // When
              final snapshot = await fakeFirestore.collection('feeds').get();

              // Then
              expect(snapshot.docs.length, 1);
              expect(
                snapshot.docs.first.data()['user_email'],
                equals(mockFeed.userEmail),
              );
            },
          );
        },
      );
      group('getFeed()는', () {
        test('firestore에 id를 전달하면, firebase는 Json을 반환해야 한다', () async {
          // Given
          const testId = 'testId';
          Weather mockWeather = Weather(
            temperature: 31,
            timeTemperature: DateTime.parse('2024-05-06'),
            code: 1,
            createdAt: DateTime.parse('2024-05-06'),
          );

          Location mockLocation = Location(
            lat: 31.23,
            lng: 29.48,
            city: '서울시, 노원구',
            createdAt: DateTime.parse('2024-05-06'),
          );

          final mockFeed = Feed(
            id: testId,
            imagePath: 'imagePath',
            thumbnailImagePath: 'thumbnailImagePath',
            userEmail: 'test@email.com',
            description: 'This is a test feed',
            weather: mockWeather,
            seasonCode: 2,
            location: mockLocation,
            createdAt: DateTime.now(),
          );

          await fakeFirestore
              .collection('feeds')
              .doc(testId)
              .set(toFeedDto(feed: mockFeed));

          // When
          final result = await dataSource.getFeed(id: testId);

          // Then
          expect(result, mockFeed);
        });
      });
      group('getUserFeedList()는', () {
        test('firestore에 email을 전달하면, firebase는 List<Feed>를 반환해야 한다', () async {
          // Given
          for (int i = 0; i < 3; i++) {
            await fakeFirestore.collection('feeds').add({
              'weather': {
                'code': i, // 날씨 코드
                'temperature': 22.0, // 온도
                'time_temperature':
                    DateTime.parse('2024-05-01 13:27:00').toIso8601String(),
                'created_at':
                    DateTime.parse('2024-05-01 13:27:00').toIso8601String(),
              },
              'location': {
                'lat': 35.234,
                'lng': 131.1,
                'city': '서울시 구로구',
                'created_at':
                    DateTime.parse('2024-05-01 13:27:00').toIso8601String(),
              },
              'created_at': DateTime.parse('2024-05-01 13:27:00'),
              'description': 'desc',
              'image_path':
                  'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
              'thumbnail_image_path':
                  'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
              'season_code': 0,
              'user_email': 'hoogom87@gmail.com',
            });
          }

          // When
          final result = await dataSource.getUserFeedList(
            email: 'hoogom87@gmail.com',
            limit: 20,
            createdAt: DateTime.now(),
          );

          // Then
          expect(result.length, 3);
        });
      });
      group('deletedFeed()는', () {
        test('id값을 전달하면, 특정 Feed를 삭제 요청을 한다.', () async {
          // Given
          const testId = 'testId';

          await fakeFirestore.collection('feeds').doc(testId).set({
            'weather': {
              'code': 0, // 날씨 코드
              'temperature': 22.0, // 온도
              'time_temperature':
                  DateTime.parse('2024-05-01 13:27:00').toIso8601String(),
              'created_at':
                  DateTime.parse('2024-05-01 13:27:00').toIso8601String(),
            },
            'location': {
              'lat': 35.234,
              'lng': 131.1,
              'city': '서울시 구로구',
              'created_at':
                  DateTime.parse('2024-05-01 13:27:00').toIso8601String(),
            },
            'created_at': DateTime.parse('2024-05-01 13:27:00'),
            'description': 'desc',
            'image_path':
                'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
            'thumbnail_image_path':
                'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
            'season_code': 0,
            'user_email': 'hoogom87@gmail.com',
          });

          // When
          await fakeFirestore.runTransaction((transaction) async {
            return await dataSource.deleteFeed(
              transaction: transaction,
              id: testId,
            );
          });
          final docResult =
              await fakeFirestore.collection('feeds').doc(testId).get();

          final feedDeletedAt =
              toFeed(json: docResult.data()!, id: docResult.id).deletedAt;

          // Then
          expect(feedDeletedAt != null, true);
        });
      });
      group('getSearchFeedList()는', () {
        test('Firebase Storage를 통해 파라미터로 받은 조건에 해당하는 값을 받는다.', () async {
          // Given
          for (int i = 0; i < 3; i++) {
            await fakeFirestore.collection('feeds').add({
              'weather': {
                'code': i, // 날씨 코드
                'temperature': 22.0, // 온도
                'time_temperature':
                    DateTime.parse('2024-05-01 13:27:00').toIso8601String(),
                'created_at':
                    DateTime.parse('2024-05-01 13:27:00').toIso8601String(),
              },
              'location': {
                'lat': 35.234,
                'lng': 131.1,
                'city': '서울시 구로구',
                'created_at':
                    DateTime.parse('2024-05-01 13:27:00').toIso8601String(),
              },
              'created_at': DateTime.parse('2024-05-01 13:27:00'),
              'description': 'desc',
              'image_path':
                  'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
              'thumbnail_image_path':
                  'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
              'season_code': 0,
              'user_email': 'hoogom87@gmail.com',
            });
          }

          // When
          final res = await dataSource.getSearchFeedList(
            createdAt: DateTime.now(),
            limit: 20,
            seasonCode: 0,
            weatherCode: 1,
            minTemperature: 20,
            maxTemperature: 25,
          );

          // Then
          expect(res.length, 1);
        });
      });

      group('getRecommendedFeedList()', () {
        test('Firebase Storage를 통해 파라미터로 받은 조건에 해당하는 값을 받는다.', () async {
          Weather mockWeather = Weather(
            temperature: 25,
            timeTemperature: DateTime.parse('2024-05-06'),
            code: 1,
            createdAt: DateTime.parse('2024-05-06'),
          );

          Location mockLocation = Location(
            lat: 31.23,
            lng: 29.48,
            city: '서울시, 노원구',
            createdAt: DateTime.parse('2024-05-06'),
          );

          final mockDailyLocationWeather = DailyLocationWeather(
            seasonCode: 0,
            highTemperature: 30,
            lowTemperature: 20,
            weatherList: List.generate(24, (index) => mockWeather),
            yesterDayWeatherList: List.generate(24, (index) => mockWeather),
            tomorrowWeatherList: List.generate(24, (index) => mockWeather),
            location: mockLocation,
            createdAt: DateTime.now(),
          );

          // Given
          for (int i = 0; i < 3; i++) {
            await fakeFirestore.collection('feeds').add({
              'weather': mockWeather.toJson(),
              'location': mockLocation.toJson(),
              'created_at':
                  Timestamp.fromDate(DateTime.parse('2024-05-01 13:27:00')),
              'description': 'desc',
              'image_path':
                  'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
              'thumbnail_image_path':
                  'https://health.chosun.com/site/data/img_dir/2024/01/22/2024012201607_0.jpg',
              'season_code': 0,
              'user_email': 'hoogom87@gmail.com',
              'deleted_at': null,
            });
          }

          // When
          final res = await dataSource.getRecommendedFeedList(
              dailyLocationWeather: mockDailyLocationWeather);

          // Then
          expect(res.length, 3);
        });
      });
    },
  );
}
