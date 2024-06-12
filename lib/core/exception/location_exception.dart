import 'package:weaco/core/exception/custom_business_exception.dart';

/// GPS 정보에 접근할 수 없음 예외
class LocationException extends CustomBusinessException {
  LocationException({required super.code, required super.message});
}
