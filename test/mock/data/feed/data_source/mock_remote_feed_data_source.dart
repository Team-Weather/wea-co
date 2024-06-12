// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weaco/data/feed/data_source/remote_feed_data_source.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/weather/model/daily_location_weather.dart';

class MockRemoteFeedDataSource implements RemoteFeedDataSource {
  List<Feed> feedList = [];
  bool saveFeedReturnValue = false;
  bool deleteFeedReturnValue = false;
  String deleteFeedParamId = '';
  Map<String, dynamic> paramMap = {};
  String getFeedId = '';
  int saveFeedMethodCallCount = 0;
  int deleteFeedMethodCallCount = 0;

  void cleanUpMockData() {
    feedList = [];
    saveFeedReturnValue = false;
    deleteFeedParamId = '';
    deleteFeedReturnValue = false;
    getFeedId = '';
    paramMap.clear();
    saveFeedMethodCallCount = 0;
    deleteFeedMethodCallCount = 0;
  }

  @override
  Future<void> deleteFeed({
    required Transaction transaction,
    required String id,
  }) async {
    deleteFeedParamId = id;
    deleteFeedMethodCallCount++;
  }

  @override
  Future<Feed> getFeed({required String id}) async {
    getFeedId = id;
    return feedList.first;
  }

  @override
  Future<List<Feed>> getRecommendedFeedList(
      {required DailyLocationWeather dailyLocationWeather, createdAt}) async {
    return feedList;
  }

  @override
  Future<List<Feed>> getSearchFeedList({
    DateTime? createdAt,
    required int limit,
    int? seasonCode,
    int? weatherCode,
    int? minTemperature,
    int? maxTemperature,
  }) async {
    paramMap['createdAt'] = createdAt;
    paramMap['limit'] = limit;
    paramMap['seasonCode'] = seasonCode;
    paramMap['weatherCode'] = weatherCode;
    paramMap['minTemperature'] = minTemperature;
    paramMap['maxTemperature'] = maxTemperature;

    return feedList;
  }

  @override
  Future<List<Feed>> getUserFeedList({
    DateTime? createdAt,
    required String email,
    required int limit,
  }) async {
    return feedList;
  }

  @override
  Future<void> saveFeed({
    required Transaction transaction,
    required Feed feed,
  }) async {
    saveFeedMethodCallCount++;

    paramMap['saveFeedParam'] = feed;

    if (saveFeedReturnValue) {
      feedList.add(feed);
    }
  }
}
