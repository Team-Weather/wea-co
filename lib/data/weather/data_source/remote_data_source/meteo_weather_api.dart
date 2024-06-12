import 'dart:developer';

import 'package:weaco/core/config/meteo_config.dart';
import 'package:weaco/core/dio/base_dio.dart';
import 'package:weaco/core/dio/base_response.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/data/weather/data_source/remote_data_source/remote_weather_data_source.dart';
import 'package:weaco/data/weather/dto/weather_dto.dart';

class MeteoWeatherApi implements RemoteWeatherDataSource {
  final BaseDio _dio;

  MeteoWeatherApi({required BaseDio dio}) : _dio = dio;

  /// meteo open api 이용하여 날씨 받아오는 메서드
  /// @param lat: 위도
  /// @param lng: 경도
  @override
  Future<WeatherDto> getWeather({
    required double lat,
    required double lng,
  }) async {
    try {
      final BaseResponse response = await _dio.get(
          path: '${MeteoConfig.baseUrl}/v1/forecast?hourly=temperature_2m,'
              'weathercode&latitude=$lat&longitude=$lng&lang=ko&past_days=1&'
              'forecast_days=2&daily=temperature_2m_max,temperature_2m_min&'
              'timezone=Asia%2FTokyo');

      if (response.statusCode != 200) {
        log('Code: ${response.statusCode}, Body: ${response.body}');
        throw ExceptionCode.fromStatus(response.statusCode.toString());
        // throw InternalServerException(code: ExceptionCode.internalServerException, message: 'sdf');
      }
      return WeatherDto.fromJson(json: response.body);
    } on ExceptionCode catch (_) {
      rethrow;
    } catch (e) {
      throw ExceptionCode.unknownException;
    }
  }
}
