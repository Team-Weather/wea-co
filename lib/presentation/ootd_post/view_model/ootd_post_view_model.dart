import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:weaco/core/enum/image_type.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/feed/use_case/save_edit_feed_use_case.dart';
import 'package:weaco/domain/file/use_case/get_image_use_case.dart';
import 'package:weaco/domain/file/use_case/save_image_use_case.dart';
import 'package:weaco/domain/location/model/location.dart';
import 'package:weaco/domain/weather/model/daily_location_weather.dart';
import 'package:weaco/domain/weather/model/weather.dart';
import 'package:weaco/domain/weather/use_case/get_daily_location_weather_use_case.dart';

class OotdPostViewModel with ChangeNotifier {
  final GetImageUseCase _getImageUseCase;
  final GetDailyLocationWeatherUseCase _getDailyLocationWeatherUseCase;
  final SaveEditFeedUseCase _saveEditFeedUseCase;
  bool _showSpinner = false;
  File? _originImage;
  File? _croppedImage;
  Weather? _weather;
  DailyLocationWeather? _dailyLocationWeather;

  OotdPostViewModel({
    required GetImageUseCase getImageUseCase,
    required GetDailyLocationWeatherUseCase getDailyLocationWeatherUseCase,
    required SaveEditFeedUseCase saveEditFeedUseCase,
    required SaveImageUseCase saveImageUseCase,
  })  : _getImageUseCase = getImageUseCase,
        _getDailyLocationWeatherUseCase = getDailyLocationWeatherUseCase,
        _saveEditFeedUseCase = saveEditFeedUseCase {
    initOotdPost();
  }

  void initOotdPost() async {
    _showSpinner = true;
    notifyListeners();

    try {
      _croppedImage =
          await _getImageUseCase.execute(imageType: ImageType.cropped);
      _dailyLocationWeather = await _getDailyLocationWeatherUseCase.execute();
      // 현재 시간 날씨
      _weather = _dailyLocationWeather!.weatherList.firstWhere((element) {
        return element.timeTemperature.hour == DateTime.now().hour;
      });
    } catch (e) {
      log(e.toString());
    }

    _showSpinner = false;
    notifyListeners();
  }

  Future<void> saveFeed(String email, String description) async {
    _showSpinner = true;
    notifyListeners();

    final now = DateTime.now();
    final Feed feed = Feed(
      id: null,
      imagePath: '',
      thumbnailImagePath: '',
      userEmail: email,
      description: description,
      weather: Weather(
        temperature: _weather!.temperature,
        timeTemperature: _weather!.timeTemperature,
        code: _weather!.code,
        createdAt: now,
      ),
      seasonCode: _dailyLocationWeather!.seasonCode,
      location: Location(
        lat: _dailyLocationWeather!.location.lat,
        lng: _dailyLocationWeather!.location.lng,
        city: _dailyLocationWeather!.location.city,
        createdAt: now,
      ),
      createdAt: now,
    );

    await _saveEditFeedUseCase.execute(feed: feed);

    _showSpinner = false;
    notifyListeners();
  }

  Future<void> editFeed(Feed feed, String description) async {
    _showSpinner = true;
    notifyListeners();

    final editedFeed = Feed(
      id: feed.id,
      imagePath: feed.imagePath,
      thumbnailImagePath: '',
      userEmail: feed.userEmail,
      description: description,
      weather: feed.weather,
      seasonCode: feed.seasonCode,
      location: feed.location,
      createdAt: feed.createdAt,
    );

    await _saveEditFeedUseCase.execute(feed: editedFeed);

    _showSpinner = false;
    notifyListeners();
  }

  Future<void> getOriginImage() async {
    _originImage = await _getImageUseCase.execute(imageType: ImageType.origin);
    if (_originImage == null) return;
  }

  File? get originImage => _originImage;

  File? get croppedImage => _croppedImage;

  Weather? get weather => _weather;

  DailyLocationWeather? get dailyLocationWeather => _dailyLocationWeather;

  bool get showSpinner => _showSpinner;
}
