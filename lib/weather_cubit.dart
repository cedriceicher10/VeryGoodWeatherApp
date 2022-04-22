import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verygoodweatherapp/models/meta_weather.dart';
import 'package:verygoodweatherapp/models/time.dart';
import 'package:verygoodweatherapp/models/weather_package.dart';

String _baseUrlMetaWeather = 'www.metaweather.com';
String _baseApiCallLocationSearch = '/api/location/search';
String _apiCallLocationSearch = 'lattlong';
String _baseApiCallLocation = '/api/location/';
String _apiCallLocation = 'query';
WeatherPackage oldWeather = WeatherPackage.initialize();

Time _time = Time();

class WeatherCubit extends Cubit<WeatherPackage> {
  final Client httpClient = Client();
  // Visually pleasing implies capital first letter, lowercase subsequent letters
  String locationNameVisuallyPleasing = '';

  WeatherCubit() : super(WeatherPackage.initialize());

  void getWeather(String location, WeatherPackage lastWeather) async {
    // Determine if a city name or lat/lon coordinates
    bool locationContainsNumerals = location.contains(RegExp(r'[0-9]'));
    // Created using https://www.metaweather.com/api/
    // Find the location and corresponding location id
    int locId = await getLocId(location, locationContainsNumerals);
    // Find the weather info using the location id
    WeatherPackage newWeather = await getWeatherInfo(location, locId);
    // Only trigger refresh if new weather is found
    bool validateNewWeather = validate(lastWeather, newWeather);
    if ((validateNewWeather) || (newWeather.isNotFound)) {
      emit(newWeather);
    }
  }

  bool validate(WeatherPackage lastWeather, WeatherPackage newWeather) {
    // If the temps/locations are the same, don't refresh the screen
    if ((lastWeather.currentTemp == newWeather.currentTemp) &&
        (lastWeather.locationId == newWeather.locationId)) {
      return false;
    }
    lastWeather = newWeather;
    return true;
  }

  Future<int> getLocId(String location, bool isLatLon) async {
    Uri locationSearchRequest;
    //Query for a location search to MetaWeather
    if (isLatLon) {
      // Lat Lon
      locationSearchRequest = Uri.https(
          _baseUrlMetaWeather,
          _baseApiCallLocationSearch,
          <String, String>{_apiCallLocationSearch: location});
    } else {
      // City name
      locationSearchRequest = Uri.https(
          _baseUrlMetaWeather,
          _baseApiCallLocationSearch,
          <String, String>{_apiCallLocation: location});
    }
    Response locationSearchResponse =
        await httpClient.get(locationSearchRequest);
    // Ensure return doesn't have an error status code
    // (typically only happens if passing an empty input)
    if (locationSearchResponse.statusCode != 200) {
      //throw ('Location search response code != 200');
      return -1;
    }
    // Ensure return has an actual location and location id
    List locationSearchResponseJson = jsonDecode(
      locationSearchResponse.body,
    ) as List;
    if (locationSearchResponseJson.isEmpty) {
      //throw ('Location search response code is empty');
      return -1;
    }
    // Save location name (visually pleasing)
    locationNameVisuallyPleasing =
        locationSearchResponseJson[0][MetaWeather.locationName];
    // Extract location id
    return locationSearchResponseJson[0][MetaWeather.locationId];
  }

  Future<WeatherPackage> getWeatherInfo(String location, int locId) async {
    // Check for bad location id
    if (locId == -1) {
      return sendBackBadPackage();
    }
    // Query for weather with a locId to MetaWeather
    Uri weatherRequest =
        Uri.https(_baseUrlMetaWeather, _baseApiCallLocation + '$locId');
    Response weatherResponse = await httpClient.get(weatherRequest);
    // Ensure return doesn't have an error status code
    if (weatherResponse.statusCode != 200) {
      //throw ('Weather search response code != 200');
      return sendBackBadPackage();
    }
    // Ensure return has actual weather
    List weatherResponseJson = jsonDecode(
      weatherResponse.body,
    )[MetaWeather.allWeather] as List;
    if (weatherResponseJson.isEmpty) {
      //throw ('Weather search response is empty');
      return sendBackBadPackage();
    }
    // Convert to WeatherPackage object
    WeatherPackage weatherInfo =
        weatherResponseJsonConverter(location, weatherResponseJson, locId);
    return weatherInfo;
  }

  WeatherPackage weatherResponseJsonConverter(
      // Convert from the MetaWeather JSON package to WeatherPackage object
      String location,
      List weatherResponseJson,
      int locId) {
    WeatherPackage weatherPackage = WeatherPackage(
        locationName: locationNameVisuallyPleasing,
        locationId: locId,
        updateTime: _time.convertZuluTime(weatherResponseJson[0]['created']),
        currentTemp: weatherResponseJson[0][MetaWeather.currentTemp], // C
        highTemp: weatherResponseJson[0][MetaWeather.highTemp], // C
        lowTemp: weatherResponseJson[0][MetaWeather.lowTemp], // C
        isFahrenheit: state.isFahrenheit,
        weatherState: weatherResponseJson[0][MetaWeather.weatherState],
        windSpeed: weatherResponseJson[0][MetaWeather.windSpeed], // mph
        windDirection: weatherResponseJson[0][MetaWeather.windDirection],
        airPressure: weatherResponseJson[0][MetaWeather.airPressure], // mbar
        humidity: weatherResponseJson[0][MetaWeather.humidity], // %
        predictability: weatherResponseJson[0]
            [MetaWeather.predictability], // % of agreeing weather reports
        visibility: weatherResponseJson[0][MetaWeather.visibility],
        isStart: false,
        isNotFound: false,
        futureWeatherHis: [
          weatherResponseJson[1][MetaWeather.highTemp],
          weatherResponseJson[2][MetaWeather.highTemp],
          weatherResponseJson[3][MetaWeather.highTemp],
          weatherResponseJson[4][MetaWeather.highTemp],
          weatherResponseJson[5][MetaWeather.highTemp]
        ],
        futureWeatherLos: [
          weatherResponseJson[1][MetaWeather.lowTemp],
          weatherResponseJson[2][MetaWeather.lowTemp],
          weatherResponseJson[3][MetaWeather.lowTemp],
          weatherResponseJson[4][MetaWeather.lowTemp],
          weatherResponseJson[5][MetaWeather.lowTemp]
        ],
        futureWeatherStates: [
          weatherResponseJson[1][MetaWeather.weatherState],
          weatherResponseJson[2][MetaWeather.weatherState],
          weatherResponseJson[3][MetaWeather.weatherState],
          weatherResponseJson[4][MetaWeather.weatherState],
          weatherResponseJson[5][MetaWeather.weatherState]
        ]); // mi
    if ((weatherPackage.weatherState == 'Heavy Cloud') ||
        (weatherPackage.weatherState == 'Light Cloud')) {
      weatherPackage.weatherState = weatherPackage.weatherState + 's';
    }
    for (int index = 0; index < 5; ++index) {
      if ((weatherPackage.futureWeatherStates[index] == 'Heavy Cloud') ||
          (weatherPackage.futureWeatherStates[index] == 'Light Cloud')) {
        weatherPackage.futureWeatherStates[index] =
            weatherPackage.futureWeatherStates[index] + 's';
      }
    }
    if (weatherPackage.isFahrenheit) {
      weatherPackage.currentTemp = celToFarDouble(weatherPackage.currentTemp);
      weatherPackage.highTemp = celToFarDouble(weatherPackage.highTemp);
      weatherPackage.lowTemp = celToFarDouble(weatherPackage.lowTemp);
      for (int index = 0; index < 5; ++index) {
        weatherPackage.futureWeatherHis[index] =
            celToFarDouble(weatherPackage.futureWeatherHis[index]);
        weatherPackage.futureWeatherLos[index] =
            celToFarDouble(weatherPackage.futureWeatherLos[index]);
      }
      weatherPackage.isFahrenheit = true;
    }
    return weatherPackage;
  }

  void toggleUnits() {
    // F to C
    if (state.isFahrenheit) {
      emit(WeatherPackage(
          locationName: state.locationName,
          locationId: state.locationId,
          updateTime: state.updateTime,
          currentTemp: farToCelDouble(state.currentTemp),
          highTemp: farToCelDouble(state.highTemp),
          lowTemp: farToCelDouble(state.lowTemp),
          isFahrenheit: false,
          weatherState: state.weatherState,
          windSpeed: state.windSpeed,
          windDirection: state.windDirection,
          airPressure: state.airPressure,
          humidity: state.humidity,
          predictability: state.predictability,
          visibility: state.visibility,
          isStart: state.isStart,
          isNotFound: state.isNotFound,
          futureWeatherHis: farToCelList(state.futureWeatherHis),
          futureWeatherLos: farToCelList(state.futureWeatherLos),
          futureWeatherStates: state.futureWeatherStates));
    } else {
      // C to F
      emit(WeatherPackage(
          locationName: state.locationName,
          locationId: state.locationId,
          updateTime: state.updateTime,
          currentTemp: celToFarDouble(state.currentTemp),
          highTemp: celToFarDouble(state.highTemp),
          lowTemp: celToFarDouble(state.lowTemp),
          isFahrenheit: true,
          weatherState: state.weatherState,
          windSpeed: state.windSpeed,
          windDirection: state.windDirection,
          airPressure: state.airPressure,
          humidity: state.humidity,
          predictability: state.predictability,
          visibility: state.visibility,
          isStart: state.isStart,
          isNotFound: state.isNotFound,
          futureWeatherHis: celToFarList(state.futureWeatherHis),
          futureWeatherLos: celToFarList(state.futureWeatherLos),
          futureWeatherStates: state.futureWeatherStates));
    }
  }

  WeatherPackage sendBackBadPackage() {
    // Bad package is for when location/weather isn't found
    return WeatherPackage(
        locationName: state.locationName,
        locationId: state.locationId,
        updateTime: state.updateTime,
        currentTemp: state.currentTemp,
        highTemp: state.highTemp,
        lowTemp: state.lowTemp,
        isFahrenheit: state.isFahrenheit,
        weatherState: state.weatherState,
        windSpeed: state.windSpeed,
        windDirection: state.windDirection,
        airPressure: state.airPressure,
        humidity: state.humidity,
        predictability: state.predictability,
        visibility: state.visibility,
        isStart: false,
        isNotFound: true,
        futureWeatherHis: state.futureWeatherHis,
        futureWeatherLos: state.futureWeatherLos,
        futureWeatherStates: state.futureWeatherStates);
  }

  double farToCelDouble(double temp) {
    return (temp - 32) * (5 / 9);
  }

  double celToFarDouble(double temp) {
    return (temp * (9 / 5)) + 32;
  }

  List<double> farToCelList(List<double> temps) {
    for (var i = 0; i < temps.length; i++) {
      temps[i] = (temps[i] - 32) * (5 / 9);
    }
    return temps;
  }

  List<double> celToFarList(List<double> temps) {
    for (var i = 0; i < temps.length; i++) {
      temps[i] = (temps[i] * (9 / 5)) + 32;
    }
    return temps;
  }
}
