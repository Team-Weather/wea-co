import 'package:weaco/core/exception/custom_business_exception.dart';

class NetworkException extends CustomBusinessException {
  NetworkException({required super.code, required super.message});
}
