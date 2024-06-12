import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/core/exception/not_found_exception.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/feed/use_case/get_my_page_feeds_use_case.dart';
import 'package:weaco/domain/feed/use_case/remove_my_page_feed_use_case.dart';
import 'package:weaco/domain/user/model/user_profile.dart';
import 'package:weaco/domain/user/use_case/get_my_profile_use_case.dart';

class MyPageViewModel with ChangeNotifier {
  final GetMyPageUserProfileUseCase _getMyPageUserProfileUseCase;
  final GetMyPageFeedsUseCase _getMyPageFeedsUseCase;
  final RemoveMyPageFeedUseCase _removeMyPageFeedUseCase;

  MyPageViewModel({
    required GetMyPageUserProfileUseCase getMyPageUserProfileUseCase,
    required GetMyPageFeedsUseCase getMyPageFeedsUseCase,
    required RemoveMyPageFeedUseCase removeMyPageFeedUseCase,
  })  : _getMyPageUserProfileUseCase = getMyPageUserProfileUseCase,
        _getMyPageFeedsUseCase = getMyPageFeedsUseCase,
        _removeMyPageFeedUseCase = removeMyPageFeedUseCase;

  static const _fetchCount = 21;
  static const _fetchMoreCount = 9;

  UserProfile? _profile;
  List<Feed> _feedList = [];

  bool _isPageLoading = false;
  bool _isFeedListLoading = false;
  bool _isFeedListReachEnd = false;

  DateTime _lastFeedDateTime = DateTime.now();

  UserProfile? get profile => _profile;

  List<Feed> get feedList => _feedList;

  bool get isPageLoading => _isPageLoading;

  Future<void> initializePageData() async {
    _changePageLoadingStatus(true);

    // 초기 프로필, 피드 데이터 요청
    await getProfile().then(
      (_) async => await getInitialFeedList(profile!.email).then(
        (_) => setLastFeedDateTime(),
      ),
    );

    _changePageLoadingStatus(false);
  }

  void _changePageLoadingStatus(bool status) {
    _isPageLoading = status;
    notifyListeners();
  }

  void _changeFeedListLoadingStatus(bool status) {
    _isFeedListLoading = status;
    notifyListeners();
  }

  void _changeIsFeedListReachEndStatus(bool status) {
    _isFeedListReachEnd = status;
    notifyListeners();
  }

  void setLastFeedDateTime() {
    // 현재 피드 리스트가 비어있지 않을 때 마지막 피드 날짜 갱신
    if (_feedList.isNotEmpty) {
      _lastFeedDateTime = _feedList[_feedList.length - 1].createdAt;
    }

    notifyListeners();
  }

  // 내 프로필 데이터 요청
  Future<void> getProfile() async {
    try {
      await _getMyPageUserProfileUseCase.execute().then(
        (result) {
          if (result == null) {
            throw NotFoundException(
              code: ExceptionCode.notFoundException,
              message: '이메일과 일치하는 사용자가 없습니다.',
            );
          }

          _profile = result;
        },
      );
    } on Exception catch (e) {
      log(e.toString(), name: 'MyPageViewModel.getUserProfile()');
    }
    notifyListeners();
  }

  // 내 피드 데이터 요청
  Future<void> getInitialFeedList(String email) async {
    try {
      await _getMyPageFeedsUseCase
          .execute(
            email: email,
            createdAt: null,
            limit: _fetchCount,
          )
          .then((result) => _feedList = result);
    } on Exception catch (e) {
      log(e.toString(), name: 'MyPageViewModel.getInitialUserFeedList()');
    }
    notifyListeners();
  }

  // 피드 페이지네이션
  Future<void> fetchFeed() async {
    // 모든 피드를 다 불러왔음을 확인하는 플래그값 true 일 때
    // 유저 프로필의 feedCount 와 현재 피드 리스트의 길이가 같을 때
    // -> 피드 페이지네이션 요청 차단
    if (_isFeedListReachEnd || _profile!.feedCount == _feedList.length) return;

    try {
      // 피드 리스트 로딩중이 아닐때 요청
      if (!_isFeedListLoading) {
        _changeFeedListLoadingStatus(true);

        await _getMyPageFeedsUseCase
            .execute(
          email: profile!.email,
          createdAt: _lastFeedDateTime,
          limit: _fetchMoreCount,
        )
            .then((result) {
          if (result.length < _fetchCount) {
            _changeIsFeedListReachEndStatus(true);
            log('feed list reaches end!', name: 'MyPageViewModel.fetchFeed()');
          }

          _feedList.addAll(result);

          _changeFeedListLoadingStatus(false);

          notifyListeners();
        }).then((_) => setLastFeedDateTime());
      }
    } on Exception catch (e) {
      log(e.toString(), name: 'MyPageViewModel.fetchFeed()');
    }
  }

  // Feed 리스트에서 특정 피드 삭제
  Future<void> removeSelectedFeed(String feedId) async {
    try {
      await _removeMyPageFeedUseCase.execute(id: feedId);

      _decreaseFeedCount();
      _removeFeedFromList(feedId);

      notifyListeners();
    } on Exception catch (e) {
      log(e.toString(), name: 'MyPageViewModel.removeSelectedFeed()');
    }
  }

  // 피드 리스트에서 선택한 피드 삭제
  void _removeFeedFromList(String id) {
    _feedList.removeWhere((e) => e.id == id);
  }

  // 프로필에서 feedCount - 1
  void _decreaseFeedCount() {
    if (_profile != null) {
      _profile = _profile!.copyWith(feedCount: _profile!.feedCount - 1);
    }
  }

  void clearMyPageViewModelState() {
    _profile = null;
    _feedList.clear();

    notifyListeners();
  }
}
