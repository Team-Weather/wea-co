import 'package:get_it/get_it.dart';
import 'package:weaco/core/di/common/common_di_setup.dart';
import 'package:weaco/core/di/feed/feed_di_setup.dart';
import 'package:weaco/core/di/location/location_di_setup.dart';
import 'package:weaco/core/di/user/user_di_setup.dart';
import 'package:weaco/core/di/weather/weather_di_setup.dart';

final getIt = GetIt.instance;

/// DI 설정
/// - [commonDiSetup]: 공통 DI 설정
/// - [userDiSetup]: 사용자 DI 설정
/// - [locationDiSetup]: 위치 DI 설정
/// - [feedDiSetup]: 피드 DI 설정
/// - [weatherDiSetup]: 날씨 DI 설정
///  common -> user -> location -> feed -> weather 순으로 DI 설정 중요
///  각각 먼저 설정된 DI가 다음 DI에 영향을 줄 수 있기 때문
/// - [setup]: 모든 DI 설정
void setup() {
  commonDiSetup();
  userDiSetup();
  locationDiSetup();
  feedDiSetup();
  weatherDiSetup();
  // ViewModel

  // View
}