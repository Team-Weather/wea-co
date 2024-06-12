import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/weather/model/daily_location_weather.dart';

abstract interface class FeedRepository {
  /// [마이페이지/유저페이지 화면]
  /// 유저의 피드를 가져옵니다.
  Future<List<Feed>> getUserFeedList({
    required String email,
    required DateTime? createdAt,
    required int? limit,
  });

  /// 피드의 상세 정보를 가져옵니다.
  Future<Feed> getFeed({required String id});

  /// [홈 하단]
  /// 추천 OOTD 목록을 불러옵니다.
  Future<List<Feed>> getRecommendedFeedList({
    required DailyLocationWeather dailyLocationWeather,
  });

  /// 입력된 조건 값에 맞는 피드 목록을 불러옵니다.
  Future<List<Feed>> getSearchFeedList({
    DateTime? createdAt,
    int? limit,
    int? seasonCode,
    int? weatherCode,
    int? minTemperature,
    int? maxTemperature,
  });

  /// OOTD 피드를 최신 순으로 가져옵니다.
  Future<List<Feed>> getOotdFeedList({
    required DateTime createdAt,
    required DailyLocationWeather dailyLocationWeather,
  });
}
