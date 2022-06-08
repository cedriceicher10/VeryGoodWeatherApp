import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:verygoodweatherapp/models/weather_state.dart';
import 'package:verygoodweatherapp/utils/styles.dart';

// For testing
// Turn isTest to true
// Toggle index of testWeatherState
// Hot restart each time
bool isTest = false;
List<String> testWeatherStateArray = [
  'Snow',
  'Sleet',
  'Hail',
  'Thunder',
  'Heavy Rain',
  'Light Rain',
  'Showers',
  'Heavy Clouds',
  'Light Clouds',
  'Clear'
];
String testWeatherState = testWeatherStateArray[0];

enum WEATHER_DISPLAY { mainTemp, futureTemp }

class AppTheme {
  BuildContext context;
  Color colorFadeTop = Colors.blue;
  Color colorFadeBottom = Colors.white;
  Color textColor = Colors.black;

  AppTheme(this.context);

  BoxDecoration getBackgroundFade(String weatherState) {
    if (isTest) {
      weatherState = testWeatherState;
    }
    switch (weatherState) {
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

  Icon getWeatherStateIcon(
      String weatherState, WEATHER_DISPLAY weatherDisplay) {
    if (isTest) {
      weatherState = testWeatherState;
    }
    double iconSize = 20;
    if (weatherDisplay == WEATHER_DISPLAY.mainTemp) {
      iconSize = 65;
    } else {
      iconSize = 35;
    }
    double reductionFactor = 0.65;
    if ((MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) <
        550 * 350) {
      iconSize = iconSize * reductionFactor;
    }
    Color iconColor = Colors.blue;
    Icon weatherStateIcon = Icon(
      WeatherIcons.day_sunny,
      color: iconColor,
      size: iconSize,
    );
    switch (weatherState) {
      case WeatherState.snow:
        {
          weatherStateIcon = Icon(
            WeatherIcons.snow,
            color: Colors.white,
            size: iconSize,
          );
        }
        break;
      case WeatherState.sleet:
        {
          weatherStateIcon = Icon(
            WeatherIcons.sleet,
            color: Colors.grey,
            size: iconSize,
          );
        }
        break;
      case WeatherState.hail:
        {
          weatherStateIcon = Icon(
            WeatherIcons.hail,
            color: Colors.grey,
            size: iconSize,
          );
        }
        break;
      case WeatherState.thunder:
        {
          weatherStateIcon = Icon(
            WeatherIcons.thunderstorm,
            color: Colors.yellow,
            size: iconSize,
          );
        }
        break;
      case WeatherState.heavyRain:
        {
          weatherStateIcon = Icon(
            WeatherIcons.rain,
            color: const Color(darkBlue),
            size: iconSize,
          );
        }
        break;
      case WeatherState.lightRain:
        {
          weatherStateIcon = Icon(
            WeatherIcons.raindrops,
            color: const Color(darkBlue),
            size: iconSize,
          );
        }
        break;
      // Showers
      case WeatherState.showers:
        {
          weatherStateIcon = Icon(
            WeatherIcons.showers,
            color: const Color(darkBlue),
            size: iconSize,
          );
        }
        break;
      case WeatherState.heavyClouds:
        {
          weatherStateIcon = Icon(
            WeatherIcons.cloudy,
            color: const Color(raisinBlack),
            size: iconSize,
          );
        }
        break;
      case WeatherState.lightClouds:
        {
          weatherStateIcon = Icon(
            WeatherIcons.cloud,
            color: Colors.white,
            size: iconSize,
          );
        }
        break;
      case WeatherState.clear:
        {
          weatherStateIcon = Icon(
            WeatherIcons.day_sunny,
            color: Colors.yellow,
            size: iconSize,
          );
        }
        break;
    }
    return weatherStateIcon;
  }

  Icon getMetricIcon(String mode) {
    double iconSize = 14;
    Color iconColor = textColor;
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
}
