import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:verygoodweatherapp/models/weather_state.dart';
import 'package:verygoodweatherapp/utils/styles.dart';

// For testing
// Turn isTest to true
// Toggle index of testWeatherState
// Hot restart each time
bool isTest = false;
List<int> testWeatherStateArray = [
  WeatherState.snow,
  WeatherState.sleet,
  WeatherState.hail,
  WeatherState.thunder,
  WeatherState.heavyRain,
  WeatherState.lightRain,
  WeatherState.showers,
  WeatherState.heavyClouds,
  WeatherState.lightClouds,
  WeatherState.clear,
];
int testWeatherState = testWeatherStateArray[0];

enum WEATHER_DISPLAY { mainTemp, futureTemp }

class AppTheme {
  BuildContext context;
  Color colorFadeTop = Colors.blue;
  Color colorFadeBottom = Colors.white;
  Color textColor = Colors.black;
  Color iconColor = Colors.white;

  double _screenWidth = 0;
  double _screenHeight = 0;
  double iconSizeMain = 0;
  double iconSizeNextDay = 0;
  double iconMetricSize = 0;

  AppTheme(this.context);

  int apiMapperToStates(int weatherCode) {
    // This mapper maps the codes from weather api to a shorter list of
    // simple weather states

    List<int> _snowCodes = [
      1114,
      1117,
      1210,
      1213,
      1216,
      1219,
      1222,
      1225,
      1255
    ];
    List<int> _sleetCodes = [1204, 1207, 1249, 1252];
    List<int> _hailCodes = [1237, 1261, 1264];
    List<int> _thunderCodes = [1273, 1276, 1279, 1282];
    List<int> _heavyRainCodes = [1171, 1186, 1189, 1192, 1195];
    List<int> _lightRainCodes = [1150, 1168, 1183, 1198, 1240];
    List<int> _showersCodes = [1180, 1243, 1246];
    List<int> _heavyCloudsCodes = [1006, 1009, 1087, 1135, 1147];
    List<int> _lightCloudsCodes = [1003, 1030, 1063, 1066, 1069, 1072];
    List<int> _clearCodes = [1000];

    if (_snowCodes.contains(weatherCode)) {
      return WeatherState.snow;
    } else if (_sleetCodes.contains(weatherCode)) {
      return WeatherState.sleet;
    }
    if (_hailCodes.contains(weatherCode)) {
      return WeatherState.hail;
    }
    if (_thunderCodes.contains(weatherCode)) {
      return WeatherState.thunder;
    }
    if (_heavyRainCodes.contains(weatherCode)) {
      return WeatherState.heavyRain;
    }
    if (_lightRainCodes.contains(weatherCode)) {
      return WeatherState.lightRain;
    }
    if (_showersCodes.contains(weatherCode)) {
      return WeatherState.showers;
    }
    if (_heavyCloudsCodes.contains(weatherCode)) {
      return WeatherState.heavyClouds;
    }
    if (_lightCloudsCodes.contains(weatherCode)) {
      return WeatherState.lightClouds;
    }
    if (_clearCodes.contains(weatherCode)) {
      return WeatherState.clear;
    }
    return 10; // Default is clear
  }

  BoxDecoration getBackgroundFade(int weatherCode) {
    int weatherStateInt = apiMapperToStates(weatherCode);

    if (isTest) {
      weatherStateInt = testWeatherState;
    }
    switch (weatherStateInt) {
      case WeatherState.snow:
        {
          colorFadeTop = Colors.white;
          colorFadeBottom = Colors.grey;
          textColor = Colors.black;
        }
        break;
      case WeatherState.sleet:
        {
          colorFadeTop = Colors.black;
          colorFadeBottom = Colors.white;
          textColor = Colors.white;
        }
        break;
      case WeatherState.hail:
        {
          colorFadeTop = Colors.black;
          colorFadeBottom = Colors.lightBlue;
          textColor = Colors.white;
        }
        break;
      case WeatherState.thunder:
        {
          colorFadeTop = Colors.black;
          colorFadeBottom = Colors.grey;
          textColor = Colors.white;
        }
        break;
      case WeatherState.heavyRain:
        {
          colorFadeTop = Colors.blue;
          colorFadeBottom = Colors.blueGrey;
          textColor = Colors.black;
        }
        break;
      case WeatherState.lightRain:
        {
          colorFadeTop = Colors.blue;
          colorFadeBottom = Colors.grey;
          textColor = Colors.black;
        }
        break;
      case WeatherState.showers:
        {
          colorFadeTop = Colors.blueGrey;
          colorFadeBottom = Colors.lightBlue;
          textColor = Colors.black;
        }
        break;
      case WeatherState.heavyClouds:
        {
          colorFadeTop = const Color(darkGrey);
          colorFadeBottom = Colors.white;
          textColor = Colors.black;
        }
        break;
      case WeatherState.lightClouds:
        {
          colorFadeTop = Colors.grey;
          colorFadeBottom = Colors.yellow;
          textColor = Colors.black;
        }
        break;
      case WeatherState.clear:
        {
          colorFadeTop = Colors.yellow;
          colorFadeBottom = Colors.blue;
          textColor = Colors.black;
        }
        break;
    }
    return BoxDecoration(
        gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        colorFadeTop,
        colorFadeBottom,
      ],
    ));
  }

  Icon getWeatherStateIcon(int weatherCode, WEATHER_DISPLAY weatherDisplay) {
    generateLayout();
    int weatherStateInt = apiMapperToStates(weatherCode);

    if (isTest) {
      weatherStateInt = testWeatherState;
    }
    double iconSize = 20;
    if (weatherDisplay == WEATHER_DISPLAY.mainTemp) {
      iconSize = iconSizeMain;
    } else {
      iconSize = iconSizeNextDay;
    }
    iconColor = Colors.blue;
    Icon weatherStateIcon = Icon(
      WeatherIcons.day_sunny,
      color: iconColor,
      size: iconSize,
    );
    switch (weatherStateInt) {
      case WeatherState.snow:
        {
          iconColor = Colors.white;
          weatherStateIcon = Icon(
            WeatherIcons.snow,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case WeatherState.sleet:
        {
          iconColor = Colors.grey;
          weatherStateIcon = Icon(
            WeatherIcons.sleet,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case WeatherState.hail:
        {
          iconColor = Colors.grey;
          weatherStateIcon = Icon(
            WeatherIcons.hail,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case WeatherState.thunder:
        {
          iconColor = Colors.yellow;
          weatherStateIcon = Icon(
            WeatherIcons.thunderstorm,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case WeatherState.heavyRain:
        {
          iconColor = const Color(darkBlue);
          weatherStateIcon = Icon(
            WeatherIcons.rain,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case WeatherState.lightRain:
        {
          iconColor = const Color(darkBlue);
          weatherStateIcon = Icon(
            WeatherIcons.raindrops,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Showers
      case WeatherState.showers:
        {
          iconColor = const Color(darkBlue);
          weatherStateIcon = Icon(
            WeatherIcons.showers,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case WeatherState.heavyClouds:
        {
          iconColor = const Color(raisinBlack);
          weatherStateIcon = Icon(
            WeatherIcons.cloudy,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case WeatherState.lightClouds:
        {
          iconColor = Colors.white;
          weatherStateIcon = Icon(
            WeatherIcons.cloud,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case WeatherState.clear:
        {
          iconColor = Colors.yellow;
          weatherStateIcon = Icon(
            WeatherIcons.day_sunny,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
    }
    return weatherStateIcon;
  }

  Icon getMetricIcon(String mode) {
    generateLayout();
    double iconSize = iconMetricSize;
    iconColor = textColor;
    Icon metricIcon = Icon(
      WeatherIcons.day_sunny,
      color: iconColor,
      size: iconSize,
    );
    switch (mode) {
      case 'windSpeed':
        {
          metricIcon = Icon(
            WeatherIcons.direction_up_right,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case 'windDirection':
        {
          metricIcon = Icon(
            WeatherIcons.wind_deg_225,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case 'airPressure':
        {
          metricIcon = Icon(
            WeatherIcons.barometer,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case 'humidity':
        {
          metricIcon = Icon(
            WeatherIcons.humidity,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case 'visibility':
        {
          metricIcon = Icon(
            Icons.visibility,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case 'predictability':
        {
          metricIcon = Icon(
            Icons.query_stats,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
    }
    return metricIcon;
  }

  void generateLayout() {
    _screenWidth = MediaQuery.of(context).size.width; // 523
    _screenHeight = MediaQuery.of(context).size.height; // 1057

    // Icons
    iconSizeMain = (75 / 1057) * _screenHeight;
    iconSizeNextDay = (55 / 1057) * _screenHeight;
    iconMetricSize = (20 / 1057) * _screenHeight;
  }
}
