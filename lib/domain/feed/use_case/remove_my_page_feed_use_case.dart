import 'package:weaco/domain/feed/repository/ootd_feed_repository.dart';

class RemoveMyPageFeedUseCase {
  final OotdFeedRepository _ootdFeedRepository;

  RemoveMyPageFeedUseCase({required OotdFeedRepository ootdFeedRepository})
      : _ootdFeedRepository = ootdFeedRepository;

  /// id를 통해 특정 피드를 삭제
  /// @param id: 삭제할 피드의 id
  /// @return: null
  Future<void> execute({required String id}) async {
    await _ootdFeedRepository.removeOotdFeed(id: id);
  }
}
