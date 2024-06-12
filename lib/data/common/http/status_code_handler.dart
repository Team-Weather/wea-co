import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/core/exception/custom_business_exception.dart';
import 'package:weaco/core/exception/internal_server_exception.dart';

import '../../../core/exception/not_found_exception.dart';

/// 상태코드 이용하여 특정 Exception 받환하는 핸들러
CustomBusinessException statusCodeHandler({int? code, String? message}) {
  return switch (code) {
    404 => NotFoundException(
        code: ExceptionCode.unknownException, message: message ?? 'Data Not Found Error'),
    _ => InternalServerException(
        code: ExceptionCode.internalServerException, message: message ?? 'Internal Server Error'),
  };
}
