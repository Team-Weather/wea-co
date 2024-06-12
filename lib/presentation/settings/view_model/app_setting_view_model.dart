import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:weaco/domain/user/use_case/log_out_use_case.dart';
import 'package:weaco/domain/user/use_case/sign_out_use_case.dart';

class AppSettingViewModel with ChangeNotifier {
  final LogOutUseCase _logOutUseCase;
  final SignOutUseCase _signOutUseCase;

  AppSettingViewModel({
    required LogOutUseCase logOutUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _logOutUseCase = logOutUseCase,
        _signOutUseCase = signOutUseCase;

  PackageInfo? _packageInfo;
  String? _errorMessage;
  bool _isLoading = true;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;

  PackageInfo? get packageInfo => _packageInfo;

  /// 패키지 정보를 가져오는 메서드
  Future<void> getPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _packageInfo = info;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 로그아웃 성공 시, true 반환
  Future<void> logOut() async {
    return await _logOutUseCase.execute();
  }

  /// 회원탈퇴 성공 시, true 반환
  Future<void> signOut() async {
    return await _signOutUseCase.execute();
  }
}
