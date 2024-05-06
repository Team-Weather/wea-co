import 'package:weaco/domain/common/extension/list.dart';
import 'package:weaco/domain/location/model/location.dart';
import 'package:weaco/domain/weather/model/weather.dart';

class DailyLocationWeather {
  final double highTemperature;
  final double lowTemperature;
  final List<Weather> weatherList;
  final Location location;
  final DateTime createdAt;

  const DailyLocationWeather({
    required this.highTemperature,
    required this.lowTemperature,
    required this.weatherList,
    required this.location,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'DailyLocationWeather{highTemperature: $highTemperature, lowTemperature: $lowTemperature, weatherList: $weatherList, location: $location, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLocationWeather &&
          runtimeType == other.runtimeType &&
          highTemperature == other.highTemperature &&
          lowTemperature == other.lowTemperature &&
          weatherList.equals(other.weatherList) &&
          location == other.location &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      highTemperature.hashCode ^
      lowTemperature.hashCode ^
      weatherList.fold(1, (prev, next) => prev.hashCode ^ next.hashCode) ^
      location.hashCode ^
      createdAt.hashCode;

  DailyLocationWeather copyWith({
    double? highTemperature,
    double? lowTemperature,
    List<Weather>? weatherList,
    Location? location,
    DateTime? createdAt,
  }) {
    return DailyLocationWeather(
      highTemperature: highTemperature ?? this.highTemperature,
      lowTemperature: lowTemperature ?? this.lowTemperature,
      weatherList: weatherList ?? this.weatherList,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'highTemperature': highTemperature,
      'lowTemperature': lowTemperature,
      'weatherList': weatherList,
      'location': location,
      'createdAt': createdAt,
    };
  }

  factory DailyLocationWeather.fromJson(Map<String, dynamic> json) {
    return DailyLocationWeather(
      highTemperature: json['highTemperature'] as double,
      lowTemperature: json['lowTemperature'] as double,
      weatherList: (json['weatherList'] as List)
          .map((e) => Weather.fromJson(e))
          .toList(),
      location: Location.fromJson(json['location']),
      createdAt: json['createdAt'] as DateTime,
    );
  }
}
