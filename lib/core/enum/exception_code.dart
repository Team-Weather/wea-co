enum ExceptionCode implements Exception {
  unknownException(
    code: '500',
    errorMessage: '알 수 없는 오류 발생',
    alertMessage: '알 수 없는 오류가 발생했습니다.',
  ),
  internalServerException(
    code: '400',
    errorMessage: '서버 내부 오류',
    alertMessage: '',
  ),
  notFoundException(
    code: '404',
    errorMessage: '데이터 조회 실패',
    alertMessage: '',
  ),
  networkException(
    code: '400',
    errorMessage: '네트워크 요청 오류',
    alertMessage: '네트워크 연결을 확인해주세요.',
  ),
  userNotFoundException(
    code: 'user-not-found',
    errorMessage: '존재하지 않는 유저입니다.',
    alertMessage: '',
  ),
  wrongPasswordException(
    code: 'wrong-password',
    errorMessage: '비밀번호가 맞지 않습니다.',
    alertMessage: '',
  ),
  emailAlreadyInUseException(
    code: 'email-already-in-use',
    errorMessage: '이미 가입된 이메일입니다.',
    alertMessage: '',
  ),
  invalidEmailException(
    code: 'invalid-email',
    errorMessage: '이메일 형식이 올바르지 못합니다.',
    alertMessage: '',
  ),
  weakPasswordException(
    code: 'weak-password',
    errorMessage: '비밀번호 형식이 안전하지 않습니다.',
    alertMessage: '',
  ),
  networkRequestFailedException(
    code: 'network-request-failed',
    errorMessage: '네트워크가 불안정 합니다.',
    alertMessage: '',
  ),
  userDisabledException(
    code: 'user-disabled',
    errorMessage: '이미 탈퇴한 회원입니다.',
    alertMessage: '',
  ),
  invalidCredentialException(
      code: 'invalid-credential',
      errorMessage: '이메일과 비밀번호를 확인해주세요.',
      alertMessage: ''),

  authenticationNotExistException(
      code: 'authentication-not-exist',
      errorMessage: 'FirebaseAuth 로그인 정보 없음',
      alertMessage: notShowingMessage),

  locationException(
    code: 'no-location',
    errorMessage: '위치 정보를 가져올 수 없습니다.',
    alertMessage: notShowingMessage,
  ),

  kakaoGeoCoderApiException(
    code: 'kakao-geo-coder-api-error',
    errorMessage: 'Kakao Api 처리 오류',
    alertMessage: notShowingMessage,
  );

  final String code;
  final String errorMessage;
  final String alertMessage;
  static const String notShowingMessage = '';

  const ExceptionCode({
    required this.code,
    required this.alertMessage,
    required this.errorMessage,
  });

  static ExceptionCode fromStatus(String status) {
    if (int.tryParse(status) != null) return ExceptionCode.internalServerException;
    return switch (status) {
      'user-not-found' => ExceptionCode.userNotFoundException,
      'wrong-password' => ExceptionCode.wrongPasswordException,
      'email-already-in-use' => ExceptionCode.emailAlreadyInUseException,
      'invalid-email' => ExceptionCode.invalidEmailException,
      'weak-password' => ExceptionCode.weakPasswordException,
      'network-request-failed' => ExceptionCode.networkRequestFailedException,
      'user-disabled' => ExceptionCode.userDisabledException,
      'invaild-credential' => ExceptionCode.invalidCredentialException,
      'authentication-not-exist' => ExceptionCode.authenticationNotExistException,
      'no-location' => ExceptionCode.locationException,
      'kakao-geo-coder-api-error' => ExceptionCode.kakaoGeoCoderApiException,
      _ => ExceptionCode.unknownException,
    };
  }
}
