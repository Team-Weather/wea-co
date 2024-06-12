import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/weather/model/daily_location_weather.dart';

abstract interface class RemoteFeedDataSource {
  /// OOTD 피드 작성 성공 시 : 피드 업로드 요청(Feed) -> / 업로드 완료(bool) ← 파베
  /// OOTD 편집 완료 후 [상세 페이지]:  위와 동일.
  /// OOTD 편집 완료 후 [마이 페이지]: 위와 동일.*피드 업데이트

  Future<void> saveFeed({
    required Transaction transaction,
    required Feed feed,
  });

  /// OOTD 피드 [상세 페이지] : 피드 데이터 요청 (id) -> 파베 / 피드 데이터 반환(json) ← 파베
  Future<Feed> getFeed({required String id});

  /// [유저 페이지/마이 페이지] :  피드 데이터 요청 (email) -> 파베 / 피드 데이터 반환(List<Feed>)← 파베
  Future<List<Feed>> getUserFeedList({
    required String email,
    DateTime? createdAt,
    required int limit,
  });

  /// [마이페이지] 피드 삭제: 피드 삭제 요청(id) -> 파베/ 삭제 완료 (bool) from FB
  Future<void> deleteFeed({
    required Transaction transaction,
    required String id,
  });

  /// [홈 화면] 하단 OOTD 추천 목록:
  ///
  /// 유저의 위치와 기온을 기반으로 피드 목록을 불러옵니다.
  /// @param city: 유저 위치의 도시명
  /// @param temperature: 날씨 온도
  Future<List<Feed>> getRecommendedFeedList(
      {required DailyLocationWeather dailyLocationWeather,
      DateTime? createdAt});

  /// [검색 페이지] 피드 검색:
  ///
  /// 유저가 선택한 검색 조건으로 피드 목록을 불러옵니다.
  /// @param createAt: 페이징을 위한 피드의 생성날짜. 이 값을 기준으로 다음 목록을 가져온다.
  /// @param limit: 한 페이지당 불러올 피드 갯수
  /// @param seasonCode: 계절 코드
  /// @param weatherCode: 날씨 코드
  /// @param minTemperature: 검색을 위한 최소 온도
  /// @param maxTemperature: 검색을 위한 최대 온도
  Future<List<Feed>> getSearchFeedList({
    DateTime? createdAt,
    required int limit,
    int? seasonCode,
    int? weatherCode,
    int? minTemperature,
    int? maxTemperature,
  });
}
