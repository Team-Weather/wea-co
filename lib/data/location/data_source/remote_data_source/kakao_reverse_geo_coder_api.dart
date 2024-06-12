import 'package:dio/dio.dart';
import 'package:weaco/core/config/kakao_config.dart';
import 'package:weaco/core/dio/base_dio.dart';
import 'package:weaco/core/dio/base_response.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/data/location/data_source/remote_data_source/remote_location_data_source.dart';

class KakaoReverseGeoCoderApi implements RemoteLocationDataSource {
  final BaseDio _dio;
  final String _apiKey = KakaoConfig.apiKey;
  final String _basePath =
      'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json';

  KakaoReverseGeoCoderApi({required BaseDio dio}) : _dio = dio;

  /// 위도, 경도를 동주소로 변경 요청
  /// @param lat: 위도
  /// @param lng: 경도
  /// @return String: 변환된 동주소
  @override
  Future<String> getDong({required double lat, required double lng}) async {
    try {
      BaseResponse result = await _dio.get(
          path: _basePath,
          queryParameters: {'x': lng.toString(), 'y': lat.toString()},
          headers: {'Authorization': 'KakaoAK $_apiKey'},
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 2));
      if (result.statusCode == 200) {
        if (result.body['meta']['total_count'] == 0) {
          throw ExceptionCode.notFoundException;
        } else {
          return '${result.body['documents'][0]['region_1depth_name']} ${result.body['documents'][0]['region_2depth_name']}';
        }
      }
      throw ExceptionCode.kakaoGeoCoderApiException;
    } catch (e) {
      throw switch (e) {
        DioException _ => ExceptionCode.networkException,
        _ => e,
      };
    }
  }
}
