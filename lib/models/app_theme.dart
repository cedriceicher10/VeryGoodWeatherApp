import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:verygoodweatherapp/models/meta_weather.dart';
import 'package:verygoodweatherapp/utils/styles.dart';

class AppTheme {
  Color colorFadeTop = Colors.blue;
  Color colorFadeBottom = Colors.white;
  Color textColor = Colors.black;

  BoxDecoration getBackgroundFade(String weatherState) {
    switch (weatherState) {
      case MetaWeather.snow:
        {
          colorFadeTop = Colors.white;
          colorFadeBottom = Colors.grey;
          textColor = Colors.black;
        }
        break;
      case MetaWeather.sleet:
        {
          colorFadeTop = Colors.black;
          colorFadeBottom = Colors.white;
          textColor = Colors.white;
        }
        break;
      case MetaWeather.hail:
        {
          colorFadeTop = Colors.black;
          colorFadeBottom = Colors.lightBlue;
          textColor = Colors.white;
        }
        break;
      case MetaWeather.thunder:
        {
          colorFadeTop = Colors.black;
          colorFadeBottom = Colors.grey;
          textColor = Colors.white;
        }
        break;
      case MetaWeather.heavyRain:
        {
          colorFadeTop = Colors.blue;
          colorFadeBottom = Colors.blueGrey;
          textColor = Colors.black;
        }
        break;
      case MetaWeather.lightRain:
        {
          colorFadeTop = Colors.blue;
          colorFadeBottom = Colors.grey;
          textColor = Colors.black;
        }
        break;
      case MetaWeather.showers:
        {
          colorFadeTop = Colors.blueGrey;
          colorFadeBottom = Colors.lightBlue;
          textColor = Colors.black;
        }
        break;
      case MetaWeather.heavyClouds:
        {
          colorFadeTop = const Color(darkGrey);
          colorFadeBottom = Colors.white;
          textColor = Colors.black;
        }
        break;
      case MetaWeather.lightClouds:
        {
          colorFadeTop = Colors.grey;
          colorFadeBottom = Colors.yellow;
          textColor = Colors.black;
        }
        break;
      case MetaWeather.clear:
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

  Icon getWeatherStateIcon(String weatherState) {
    double iconSize = 65;
    Color iconColor = Colors.blue;
    Icon weatherStateIcon = Icon(
      WeatherIcons.day_sunny,
      color: iconColor,
      size: iconSize,
    );
    switch (weatherState) {
      // Snow
      case MetaWeather.snow:
        {
          weatherStateIcon = Icon(
            WeatherIcons.snow,
            color: Colors.white,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.sleet:
        {
          weatherStateIcon = Icon(
            WeatherIcons.sleet,
            color: Colors.grey,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.hail:
        {
          weatherStateIcon = Icon(
            WeatherIcons.hail,
            color: Colors.grey,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.thunder:
        {
          weatherStateIcon = Icon(
            WeatherIcons.thunderstorm,
            color: Colors.yellow,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.heavyRain:
        {
          weatherStateIcon = Icon(
            WeatherIcons.rain,
            color: const Color(darkBlue),
            size: iconSize,
          );
        }
        break;
      case MetaWeather.lightRain:
        {
          weatherStateIcon = Icon(
            WeatherIcons.raindrops,
            color: const Color(darkBlue),
            size: iconSize,
          );
        }
        break;
      // Showers
      case MetaWeather.showers:
        {
          weatherStateIcon = Icon(
            WeatherIcons.showers,
            color: const Color(darkBlue),
            size: iconSize,
          );
        }
        break;
      case MetaWeather.heavyClouds:
        {
          weatherStateIcon = Icon(
            WeatherIcons.cloudy,
            color: const Color(raisinBlack),
            size: iconSize,
          );
        }
        break;
      case MetaWeather.lightClouds:
        {
          weatherStateIcon = Icon(
            WeatherIcons.cloud,
            color: Colors.white,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.clear:
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
      case MetaWeather.windSpeed:
        {
          metricIcon = Icon(
            WeatherIcons.direction_up_right,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.windDirection:
        {
          metricIcon = Icon(
            WeatherIcons.wind_deg_225,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.airPressure:
        {
          metricIcon = Icon(
            WeatherIcons.barometer,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.humidity:
        {
          metricIcon = Icon(
            WeatherIcons.humidity,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.visibility:
        {
          metricIcon = Icon(
            Icons.visibility,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.predictability:
        {
          metricIcon = Icon(
            Icons.check,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
    }
    return metricIcon;
  }
}