import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/core/exception/not_found_exception.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/feed/use_case/get_user_page_feeds_use_case.dart';
import 'package:weaco/domain/user/model/user_profile.dart';
import 'package:weaco/domain/user/use_case/get_user_profile_use_case.dart';

class UserPageViewModel with ChangeNotifier {
  final String _email;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final GetUserPageFeedsUseCase _getUserPageFeedsUseCase;

  UserPageViewModel({
    required String email,
    required GetUserProfileUseCase getUserProfileUseCase,
    required GetUserPageFeedsUseCase getUserPageFeedsUseCase,
  })  : _email = email,
        _getUserProfileUseCase = getUserProfileUseCase,
        _getUserPageFeedsUseCase = getUserPageFeedsUseCase {
    initializeUserPageData();
  }

  static const _fetchCount = 21;
  static const _fetchMoreCount = 9;

  UserProfile? _userProfile;
  List<Feed> _userFeedList = [];

  bool _isPageLoading = false;
  bool _isFeedListLoading = false;
  bool _isFeedListReachEnd = false;

  DateTime _lastFeedDateTime = DateTime.now();

  UserProfile? get userProfile => _userProfile;

  List<Feed> get userFeedList => _userFeedList;

  bool get isPageLoading => _isPageLoading;

  bool get isFeedListLoading => _isFeedListLoading;

  Future<void> initializeUserPageData() async {
    changePageLoadingStatus(true);

    // 유저 프로필 결과(null, deletedAt)에 따라 피드 리스트 요청을 차단
    // 피드 리스트 요청 후에 페이지네이션에 사용하는 날짜 갱신
    await getUserProfile(_email);

    if (_userProfile != null && _userProfile!.deletedAt == null) {
      await getInitialUserFeedList(_email);

      setLastFeedDateTime();
    }

    changePageLoadingStatus(false);
  }

  void changePageLoadingStatus(bool status) {
    _isPageLoading = status;
    notifyListeners();
  }

  void changeFeedListLoadingStatus(bool status) {
    _isFeedListLoading = status;
    notifyListeners();
  }

  void changeIsFeedListReachEndStatus(bool status) {
    _isFeedListReachEnd = status;
    notifyListeners();
  }

  void setLastFeedDateTime() {
    if (_userFeedList.isNotEmpty) {
      _lastFeedDateTime = _userFeedList[_userFeedList.length - 1].createdAt;
      notifyListeners();
    }
  }

  // 유저 프로필 요청
  Future<void> getUserProfile(String email) async {
    try {
      final result = await _getUserProfileUseCase.execute(email: email);

      if (result == null) {
        throw NotFoundException(
          code: ExceptionCode.notFoundException,
          message: '이메일과 일치하는 사용자가 없습니다.',
        );
      }

      _userProfile = result;
    } on Exception catch (e) {
      log(e.toString(), name: 'UserPageViewModel.getUserProfile()');
    }
    notifyListeners();
  }

  // 최초 화면 진입시 기본 갯수의 피드 리스트 요청
  Future<void> getInitialUserFeedList(String email) async {
    try {
      final result = await _getUserPageFeedsUseCase.execute(
        email: email,
        createdAt: null,
        limit: _fetchCount,
      );

      _userFeedList = result;
    } on Exception catch (e) {
      log(e.toString(), name: 'UserPageViewModel.getInitialUserFeedList()');
    }
    notifyListeners();
  }

  Future<void> fetchFeed() async {
    // 모든 피드를 다 불러왔음을 확인하는 플래그값 true 일 때
    // 유저 프로필의 feedCount 와 현재 피드 리스트의 길이가 같을 때
    // -> 피드 페이지네이션 요청 차단
    if (_isFeedListReachEnd ||
        _userProfile!.feedCount == _userFeedList.length) {
      return;
    }

    try {
      // 피드 리스트 로딩중이 아닐때 요청
      if (!_isFeedListLoading) {
        changeFeedListLoadingStatus(true);

        final result = await _getUserPageFeedsUseCase.execute(
          email: _email,
          createdAt: _lastFeedDateTime,
          limit: _fetchMoreCount,
        );

        if (result.length < _fetchCount) {
          changeIsFeedListReachEndStatus(true);
          log('feed list reaches end!', name: 'UserPageViewModel.fetchFeed()');
        }

        _userFeedList.addAll(result);

        changeFeedListLoadingStatus(false);

        setLastFeedDateTime();
        notifyListeners();
      }
    } on Exception catch (e) {
      log(e.toString(), name: 'MyPageViewModel.removeSelectedFeed()');
    }
  }
}
