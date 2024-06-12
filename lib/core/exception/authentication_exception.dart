import 'package:weaco/core/exception/custom_business_exception.dart';

class AuthenticationException extends CustomBusinessException {
  AuthenticationException(
      {required super.code, required super.message});
}
