import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weaco/core/db/transaction_service.dart';
import 'package:weaco/data/feed/data_source/remote_feed_data_source.dart';
import 'package:weaco/data/user/data_source/remote_user_profile_data_source.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/feed/repository/ootd_feed_repository.dart';
import 'package:weaco/domain/file/repository/file_repository.dart';

class OotdFeedRepositoryImpl implements OotdFeedRepository {
  final FileRepository _fileRepository;

  final RemoteFeedDataSource _remoteFeedDataSource;
  final RemoteUserProfileDataSource _remoteUserProfileDataSource;

  final TransactionService _firestoreService;

  const OotdFeedRepositoryImpl({
    required FileRepository fileRepository,
    required RemoteFeedDataSource remoteFeedDataSource,
    required RemoteUserProfileDataSource remoteUserProfileDataSource,
    required TransactionService firestoreService,
  })  : _fileRepository = fileRepository,
        _remoteFeedDataSource = remoteFeedDataSource,
        _remoteUserProfileDataSource = remoteUserProfileDataSource,
        _firestoreService = firestoreService;

  /// 피드 저장 및 수정
  @override
  Future<void> saveOotdFeed({required Feed feed}) async {
    await _firestoreService.run((Transaction transaction) async {
      feed.id == null
          ? await _save(transaction: transaction, feed: feed)
          : await _update(transaction: transaction, feed: feed);
    });
  }

  /// 피드 저장
  Future<void> _save({
    required Transaction transaction,
    required Feed feed,
  }) async {
    final List<String> path = await _fileRepository.saveOotdImage();

    await _remoteFeedDataSource.saveFeed(
      transaction: transaction,
      feed: feed.copyWith(imagePath: path[0], thumbnailImagePath: path[1]),
    );

    await _updateMyFeedCount(
      transaction: transaction,
      count: 1,
    );
  }

  /// 피드 수정
  Future<void> _update({
    required Transaction transaction,
    required Feed feed,
  }) async {
    await _remoteFeedDataSource.saveFeed(
      transaction: transaction,
      feed: feed,
    );
  }

  /// 피드 삭제
  @override
  Future<void> removeOotdFeed({required String id}) async {
    await _firestoreService.run((Transaction transaction) async {
      await _remoteFeedDataSource.deleteFeed(
        transaction: transaction,
        id: id,
      );

      await _updateMyFeedCount(
        transaction: transaction,
        count: -1,
      );
    });
  }

  /// 유저 피드 카운트 업데이트
  Future<void> _updateMyFeedCount({
    required Transaction transaction,
    required int count,
  }) async {
    final myProfile = await _remoteUserProfileDataSource.getUserProfile();

    await _remoteUserProfileDataSource.updateUserProfile(
      transaction: transaction,
      userProfile: myProfile.copyWith(feedCount: myProfile.feedCount + count),
    );
  }
}
