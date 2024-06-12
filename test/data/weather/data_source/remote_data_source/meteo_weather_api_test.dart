import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weaco/core/config/meteo_config.dart';
import 'package:weaco/core/dio/base_response.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/data/weather/data_source/remote_data_source/meteo_weather_api.dart';
import 'package:weaco/data/weather/dto/daily_dto.dart';
import 'package:weaco/data/weather/dto/hourly_dto.dart';
import 'package:weaco/data/weather/dto/weather_dto.dart';

import '../../../../mock/core/dio/mock_meteo_dio.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  group('MeteoWeatherApi 클래스', () {
    final MockMeteoDio mockMeteoDio = MockMeteoDio();
    final MeteoWeatherApi meteoWeatherApi = MeteoWeatherApi(dio: mockMeteoDio);
    const double lat = 37.27;
    const double lng = 127.27;
    BaseResponse response = BaseResponse(statusCode: 200, body: {});
    setUp(() => mockMeteoDio.initMockData());

    group('getWeather 메서드는', () {
      test('인자로 전달받은 lat과 lng으로 url을 만들어 dio.get에 전달한다.', () async {
        // Given
        final expectedUrl =
            '${MeteoConfig.baseUrl}/v1/forecast?hourly=temperature_2m,'
            'weathercode&latitude=$lat&longitude=$lng&lang=ko&past_days=1&'
            'forecast_days=2&daily=temperature_2m_max,temperature_2m_min&'
            'timezone=Asia%2FTokyo';
        mockMeteoDio.getResponseReturnData = response;

        // When
        await meteoWeatherApi.getWeather(lat: lat, lng: lng);

        // Then
        expect(mockMeteoDio.getPathParameter, expectedUrl);
      });

      test('반환받은 status code가 200이 아니라면 ExceptionCode예외를 던진다.', () async {
        // Given
        mockMeteoDio.getResponseReturnData =
            BaseResponse(statusCode: 404, body: {});

        // When Then
        expect(meteoWeatherApi.getWeather(lat: lat, lng: lng),
            throwsA(ExceptionCode.internalServerException));
      });

      test('반환받은 status code가 500이라면 InternalServerException예외를 던진다.',
          () async {
        // Given
        mockMeteoDio.getResponseReturnData =
            BaseResponse(statusCode: 500, body: {});

        // When Then
        expect(meteoWeatherApi.getWeather(lat: lat, lng: lng),
            throwsA(ExceptionCode.internalServerException));
      });

      test('반환받은 status code가 200이라면 BaseResponse를 반환한다.', () async {
        // Given
        final expected = WeatherDto(
          latitude: lat,
          longitude: lng,
          hourly: HourlyDto(
            time: [
              '2021-10-01T00:00:00+09:00',
              '2021-10-01T01:00:00+09:00',
              '2021-10-01T02:00:00+09:00'
            ],
            temperature2m: [10.0],
            weathercode: [1],
          ),
          daily: DailyDto(
            temperature2mMax: [20.0],
            temperature2mMin: [10.0],
          ),
        );
        mockMeteoDio.getResponseReturnData =
            BaseResponse(statusCode: 200, body: {
          'latitude': lat,
          'longitude': lng,
          'hourly': {
            'time': [
              '2021-10-01T00:00:00+09:00',
              '2021-10-01T01:00:00+09:00',
              '2021-10-01T02:00:00+09:00'
            ],
            'temperature_2m': [10.0],
            'weathercode': [1],
          },
          'daily': {
            'temperature_2m_max': [20.0],
            'temperature_2m_min': [10.0],
          },
        });

        // When
        final result = await meteoWeatherApi.getWeather(lat: lat, lng: lng);

        // Then
        expect(result.latitude, expected.latitude);
        expect(result.longitude, expected.longitude);
        expect(result.hourly?.time, expected.hourly?.time);
        expect(result.hourly?.temperature2m, expected.hourly?.temperature2m);
        expect(result.hourly?.weathercode, expected.hourly?.weathercode);
        expect(
            result.daily?.temperature2mMax, expected.daily?.temperature2mMax);
        expect(
            result.daily?.temperature2mMin, expected.daily?.temperature2mMin);
      });
    });
  });
}
