abstract interface class UserAuthDataSource {
  // 회원가입
  Future<void> signUp({
    required String email,
    required String password,
  });

  // 로그인
  Future<void> signIn({
    required String email,
    required String password,
  });

  // 로그아웃
  Future<void> logOut();

  // 회원탈퇴
  Future<void> signOut();

  // 로그인 체크 email 반환
  String? signInCheck();
}
