import 'package:weaco/domain/user/model/user_auth.dart';
import 'package:weaco/domain/user/model/user_profile.dart';
import 'package:weaco/domain/user/repository/user_auth_repository.dart';

class SignUpUseCase {
  final UserAuthRepository _userAuthRepository;

  const SignUpUseCase({
    required UserAuthRepository userAuthRepository,
  }) : _userAuthRepository = userAuthRepository;

  /// 회원 가입 화면에서 정보기입 후 가입 요청을 보내는 Use Case
  /// [userAuth] : 회원 가입을 위한 이메일, 비밀번호 정보
  /// [userProfile] : 회원 가입을 위한 프로필 정보
  /// 회원 가입 성공시 true 반환, 실패시 false 반환
  Future<void> execute(
      {required UserAuth userAuth, required UserProfile userProfile}) async {
    await _userAuthRepository.signUp(
        userAuth: userAuth, userProfile: userProfile);
    await _userAuthRepository.signIn(userAuth: userAuth);
  }
}
