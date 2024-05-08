import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weaco/data/feed/data_source/remote_feed_data_source.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/weather/model/daily_location_weather.dart';

class RemoteFeedDataSourceImpl implements RemoteFeedDataSource {
  final FirebaseFirestore _fireStore;

  const RemoteFeedDataSourceImpl({
    required FirebaseFirestore fireStore,
  }) : _fireStore = fireStore;

  /// OOTD 피드 작성 성공 시 : 피드 업로드 요청(Feed) -> / 업로드 완료(bool) ← 파베
  /// OOTD 편집 완료 후 [상세 페이지]:  위와 동일.
  /// OOTD 편집 완료 후 [마이 페이지]: 위와 동일.*피드 업데이트
  @override
  Future<bool> saveFeed({required Feed feed}) async {
    return await _fireStore.collection('feeds').add({
      'id': feed.id,
      'image_path': feed.imagePath,
      'user_email': feed.userEmail,
      'description': feed.description,
      'season_code': feed.seasonCode,
      'created_at': feed.createdAt,
      'deleted_at': feed.deletedAt,
      'weather': feed.weather.toJson(),
      'location': feed.location.toJson(),
    }).then((value) => true);
  }

  /// [OOTD 피드 상세 페이지]:
  /// 피드 데이터 요청 (id) -> 파베 / 피드 데이터 반환(json) ← 파베
  @override
  Future<Feed> getFeed({required String id}) async {
    final docSnapshot = await _fireStore.collection('feeds').doc(id).get();

    return Feed.fromJson(docSnapshot.data()!);
  }

  /// [유저 페이지/마이 페이지]:
  /// 피드 데이터 요청 (email) -> 파베 / 피드 데이터 반환(List<Feed>)← 파베
  @override
  Future<List<Feed>> getUserFeedList({
    required String email,
    required DateTime createdAt,
    required int limit,
  }) async {
    final querySnapshot = await _fireStore
        .collection('feeds')
        .where('user_email', isEqualTo: email)
        .orderBy(createdAt, descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((e) => Feed.fromJson(e.data())).toList();
  }

  /// [마이페이지] 피드 삭제:
  /// 피드 삭제 요청(id) -> 파베/ 삭제 완료 (bool) <- 파베
  @override
  Future<bool> deleteFeed({required String id}) async {
    await _fireStore.collection('feeds').doc(id).delete();
    return true;
  }

  /// [홈 페이지] 하단 OOTD 추천:
  /// 피드 데이터 요청 (위치, 날씨) -> 파베
  /// 피드 데이터 반환(List<Feed>) <- 파베
  @override
  Future<List<Feed>> getRecommendedFeedList({
    required DailyLocationWeather dailyLocationWeather,
  }) async {
    final weather = dailyLocationWeather.weatherList[0];
    final querySnapshot = await _fireStore
        .collection('feeds')
        .where('weather.season_code', isEqualTo: weather.code)
        .where('weather.season_code', isEqualTo: weather.code)
        .where(
          'weather.temperature',
          isLessThanOrEqualTo: dailyLocationWeather.highTemperature,
          isGreaterThanOrEqualTo: dailyLocationWeather.lowTemperature,
        )
        .where('deleted_at', isEqualTo: null)
        .orderBy('created_at', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs.map((e) => Feed.fromJson(e.data())).toList();
  }

  /// [검색 페이지] 피드 검색:
  /// 피드 데이터 요청(계절,날씨,온도) -> FB
  /// 피드 데이터 반환(List<Feed>) <- FB

  @override
  Future<List<Feed>> getSearchFeedList({
    required DateTime createdAt,
    required int limit,
    int? seasonCode,
    int? weatherCode,
    int? minTemperature,
    int? maxTemperature,
  }) async {
    Query<Map<String, dynamic>> query = _fireStore.collection('feeds');
    // 날씨 코드 필터링
    if (weatherCode != null) {
      query = query.where('weather.code', isEqualTo: weatherCode);
    }

    // 온도 범위 필터링
    if (minTemperature != null && maxTemperature != null) {
      query = query
          .where('weather.temperature', isLessThanOrEqualTo: maxTemperature)
          .where('weather.temperature', isGreaterThanOrEqualTo: minTemperature);
    }

    // 계절 코드 필터링
    if (seasonCode != null) {
      query = query.where('season_code', isEqualTo: seasonCode);
    }

    // 생성일 기준으로 정렬하여 제한된 수의 문서 가져오기
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await query
        .orderBy(
          'created_at',
          descending: true,
        )
        .limit(limit)
        .get();

    return querySnapshot.docs.map((e) => Feed.fromDocumentSnapshot(e)).toList();
  }
}
