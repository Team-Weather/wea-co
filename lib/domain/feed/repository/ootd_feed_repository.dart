import 'package:weaco/domain/feed/model/feed.dart';

abstract interface class OotdFeedRepository {
  Future<void> saveOotdFeed({required Feed feed});

  Future<void> removeOotdFeed({required String id});
}