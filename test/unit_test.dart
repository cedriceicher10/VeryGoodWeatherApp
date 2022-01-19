import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:verygoodweatherapp/weather_cubit.dart';
import 'package:verygoodweatherapp/models/weather_package.dart';

class MockHttpClient extends Mock implements Client {}

class MockResponse extends Mock implements Response {}

class FakeUri extends Fake implements Uri {}

late WeatherPackage badPackage;

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });
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
        test(
            'getWeatherInfo correctly returns weather for a valid city location id',
            () async {
          WeatherCubit weather = WeatherCubit();
          expect(
              (await weather.getWeatherInfo('San Diego', 2487889)).isNotFound,
              equals(false));
        });
        test(
            'getWeatherInfo correctly returns a bad weather package with isNotFound true when locId is flagged (-1)',
            () async {
          WeatherCubit weather = WeatherCubit();
          expect((await weather.getWeatherInfo('San Diego', -1)).isNotFound,
              equals(badPackage.isNotFound));
        });
        test(
            'getWeatherInfo correctly returns a bad weather package with isNotFound true when status code != 200',
            () async {
          WeatherCubit weather = WeatherCubit();
          MockResponse response = MockResponse();
          when(() => response.statusCode).thenReturn(100);
          when(() => MockHttpClient().get(any()))
              .thenAnswer((_) async => response);
          expect(
            (await weather.getWeatherInfo('mock-query', 0)).isNotFound,
            equals(true),
          );
        });
        test(
            'getWeatherInfo correctly returns a bad weather package with isNotFound true when weather is empty []',
            () async {
          WeatherCubit weather = WeatherCubit();
          MockResponse response = MockResponse();
          when(() => response.statusCode).thenReturn(200);
          when(() => response.body).thenReturn('[]');
          when(() => MockHttpClient().get(any()))
              .thenAnswer((_) async => response);
          expect(
            (await weather.getWeatherInfo('mock-query', 0)).isNotFound,
            equals(true),
          );
        });
      });
      group('farToCel', () {
        test('farToCel correctly converts F to C', () async {
          WeatherCubit weather = WeatherCubit();
          double farValue = 78;
          double celValue = 26;
          expect((weather.farToCel(farValue)).round(), equals(celValue));
        });
      });
      group('celToFar', () {
        test('celToFar correctly converts F to C', () async {
          WeatherCubit weather = WeatherCubit();
          double farValue = 79;
          double celValue = 26;
          expect((weather.celToFar(celValue)).round(), equals(farValue));
        });
      });
      group('sendBackBadPackage', () {
        test('sendBackBadPackage correctly sends a bad package back', () async {
          WeatherCubit weather = WeatherCubit();
          expect((weather.sendBackBadPackage()).isNotFound, equals(true));
        });
      });
    });
  });
}

String getNowTime() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('h:mma').format(now);
  return formattedDate;
}
