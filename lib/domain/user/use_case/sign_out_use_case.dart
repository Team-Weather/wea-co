import 'package:weaco/domain/user/repository/user_auth_repository.dart';

class SignOutUseCase {
  final UserAuthRepository _userAuthRepository;

  SignOutUseCase({
    required UserAuthRepository userAuthRepository,
  }) : _userAuthRepository = userAuthRepository;

  /// 설정 화면의 회월 탈퇴를 위한 Use Case
  Future<void> execute() async {
    await _userAuthRepository.signOut();
  }
}
