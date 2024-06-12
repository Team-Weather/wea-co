import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/core/gps/gps_permission_status.dart';
import 'package:weaco/core/gps/gps_position.dart';

class GpsHelper {
  /// 위치 권한 요청
  /// @return: GpsPermissionStatus enum
  Future<GpsPermissionStatus> getPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled == false) {
        return Future.error('Location services are disabled.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return GpsPermissionStatus.denied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return GpsPermissionStatus.deniedForever;
      }

      if (permission == LocationPermission.whileInUse) {
        return GpsPermissionStatus.whileInUse;
      }
      return GpsPermissionStatus.forever;
    } catch (e) {
      log(e.toString(), name: 'GpsHelper.getPermission()');
      return GpsPermissionStatus.disabled;
    }
  }

  /// GPS 좌표 요청
  /// @return: 위치 권한이 있을 경우 = Position, 없으면 = null
  Future<GpsPosition> getPosition() async {
    GpsPermissionStatus permission = await getPermission();
    if (permission == GpsPermissionStatus.forever ||
        permission == GpsPermissionStatus.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      return GpsPosition(lat: position.latitude, lng: position.longitude);
    }
    throw ExceptionCode.locationException;
  }
}
