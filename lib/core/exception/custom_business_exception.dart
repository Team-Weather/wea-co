import 'package:weaco/core/enum/exception_code.dart';

/// 어플리케이션 비지니스상 의도한 예외를 정의한 클래스
class CustomBusinessException implements Exception {
  final ExceptionCode code;
  final String message;

  CustomBusinessException({required this.code, required this.message});
}
