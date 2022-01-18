import 'package:verygoodweatherapp/main.dart';
import 'package:test/test.dart';
import 'package:verygoodweatherapp/weather_cubit.dart';
import 'package:verygoodweatherapp/weather_package.dart';
import 'package:verygoodweatherapp/weather_screen.dart';

void main() {
  group('WeatherPackage Model', () {
    test('WeatherPackage model correctly initializes with isStart true', () {
      WeatherPackage weather = WeatherPackage.initialize();
      expect(weather.isStart, equals(true));
    });

    test('', () {});
  });
}
