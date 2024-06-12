import 'package:weaco/domain/user/repository/user_auth_repository.dart';

class LogOutUseCase {
  final UserAuthRepository _userAuthRepository;

  LogOutUseCase({
    required UserAuthRepository userAuthRepository,
  }) : _userAuthRepository = userAuthRepository;

  Future<void> execute() async {
    await _userAuthRepository.logOut();
  }
}
