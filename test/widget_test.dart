import 'package:verygoodweatherapp/main.dart';
import 'package:test/test.dart';
import 'package:verygoodweatherapp/weather_cubit.dart';
import 'package:verygoodweatherapp/weather_package.dart';
import 'package:verygoodweatherapp/weather_screen.dart';

late WeatherPackage badPackage;

void main() {
  group('VeryGoodWeather', () {
    group('WeatherPackage', () {
      test('WeatherPackage model correctly initializes with isStart true', () {
        WeatherPackage weather = WeatherPackage.initialize();
        expect(weather.isStart, equals(true));
      });
    });
    group('WeatherCubit', () {
      group('getLocid', () {
        test('getLocid correctly returns city location id for a valid city',
            () async {
          WeatherCubit weather = WeatherCubit();
          expect(await weather.getLocId('San Diego', false), equals(2487889));
        });
        test('getLocid correctly returns -1 for an unknown city', () async {
          WeatherCubit weather = WeatherCubit();
          expect(await weather.getLocId('Redlands', false), equals(-1));
        });
        test('getLocid correctly returns -1 for an invalid search', () async {
          WeatherCubit weather = WeatherCubit();
          expect(await weather.getLocId('abc123!@#', false), equals(-1));
        });
        test(
            'getLocid correctly returns -1 for a known city but not in latlon format',
            () async {
          WeatherCubit weather = WeatherCubit();
          expect(await weather.getLocId('San Diego', true), equals(-1));
        });
        test(
            'getLocid correctly returns city location id for a valid city in latlon format',
            () async {
          WeatherCubit weather = WeatherCubit();
          expect(await weather.getLocId('32.715691,-117.161720', true),
              equals(2487889));
        });
      });

      group('getWeatherInfo', () {
        setUp(() {
          badPackage = WeatherPackage(
              locationName: 'null',
              locationId: 0,
              updateTime: 'null',
              currentTemp: 0,
              highTemp: 0,
              lowTemp: 0,
              isFahrenheit: false,
              weatherState: 'null',
              windSpeed: 0,
              windDirection: 'null',
              airPressure: 0,
              humidity: 0,
              predictability: 0,
              visibility: 0,
              isStart: false,
              isNotFound: true);
        });
        // TO DO: Need to mock this, since weather is constantly changing
        // test('getWeatherInfo correctly returns weather for a valid city location id',
        //     () async {
        //   WeatherCubit weather = WeatherCubit();
        //   expect(await weather.getWeatherInfo('San Diego', 2487889), equals(weatherPackageSanDiego));
        test(
            'getWeatherInfo correctly returns a bad weather package with isNotFound true when locId is invalid',
            () async {
          WeatherCubit weather = WeatherCubit();
          expect((await weather.getWeatherInfo('San Diego', 0)).isNotFound,
              equals(badPackage.isNotFound));
        });
      });
    });
  });
}
