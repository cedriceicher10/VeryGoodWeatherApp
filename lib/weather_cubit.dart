import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'weather_package.dart';
import 'dart:convert';

String baseUrlMetaWeather = 'www.metaweather.com';
String baseApiCallLocationSearch = '/api/location/search';
String baseApiCallLocation = '/api/location/';

class WeatherCubit extends Cubit<WeatherPackage> {
  final Client httpClient = Client();

  WeatherCubit()
      : super(WeatherPackage(
            locationName: '',
            locationId: -1,
            updateTime: '',
            currentTemp: -1,
            highTemp: -1,
            lowTemp: -1,
            isFahrenheit: false,
            weatherState: '',
            windSpeed: -1,
            windDirection: '',
            airPressure: -1,
            humidity: -1,
            predictability: -1,
            visibility: -1,
            isStart: true, // Trigger for initial screen (no city yet)
            isNotFound: false));

  void getWeather(String location) async {
    // Created using https://www.metaweather.com/api/
    // Find the location and corresponding location id
    int locId = await getLocId(location);
    // Find the weather info using the location id
    WeatherPackage newWeather = await getWeatherInfo(location, locId);
    emit(newWeather);
  }

  Future<int> getLocId(String location) async {
    // Query for a location search to MetaWeather
    Uri locationSearchRequest = Uri.https(baseUrlMetaWeather,
        baseApiCallLocationSearch, <String, String>{'query': location});
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
    // Extract location id
    return locationSearchResponseJson[0]['woeid'];
  }

  Future<WeatherPackage> getWeatherInfo(String location, int locId) async {
    // Check for bad location id
    if (locId == -1) {
      return sendBackBadPackage();
    }
    // Query for weather with a locId to MetaWeather
    Uri weatherRequest =
        Uri.https(baseUrlMetaWeather, baseApiCallLocation + '$locId');
    Response weatherResponse = await httpClient.get(weatherRequest);
    // Ensure return doesn't have an error status code
    if (weatherResponse.statusCode != 200) {
      //throw ('Weather search response code != 200');
      return sendBackBadPackage();
    }
    // Ensure return has actual weather
    List weatherResponseJson = jsonDecode(
      weatherResponse.body,
    )['consolidated_weather'] as List;
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
      String location, List weatherResponseJson, int locId) {
    return WeatherPackage(
        locationName: location,
        locationId: locId,
        updateTime: getNowTime(),
        currentTemp: celToFar(weatherResponseJson[0]['the_temp']), // C to F
        highTemp: celToFar(weatherResponseJson[0]['max_temp']), // C to F
        lowTemp: celToFar(weatherResponseJson[0]['min_temp']), // C to F
        isFahrenheit: true,
        weatherState: weatherResponseJson[0]['weather_state_name'],
        windSpeed: weatherResponseJson[0]['wind_speed'], // mph
        windDirection: weatherResponseJson[0]['wind_direction_compass'],
        airPressure: weatherResponseJson[0]['air_pressure'], // mbar
        humidity: weatherResponseJson[0]['humidity'], // %
        predictability: weatherResponseJson[0]
            ['predictability'], // % of agreeing weather reports
        visibility: weatherResponseJson[0]['visibility'],
        isStart: false,
        isNotFound: false); // mi
  }

  void toggleUnits() {
    if (state.isFahrenheit) {
      emit(WeatherPackage(
          locationName: state.locationName,
          locationId: state.locationId,
          updateTime: state.updateTime,
          currentTemp: farToCel(state.currentTemp),
          highTemp: farToCel(state.highTemp),
          lowTemp: farToCel(state.lowTemp),
          isFahrenheit: false,
          weatherState: state.weatherState,
          windSpeed: state.windSpeed,
          windDirection: state.windDirection,
          airPressure: state.airPressure,
          humidity: state.humidity,
          predictability: state.predictability,
          visibility: state.visibility,
          isStart: state.isStart,
          isNotFound: state.isNotFound));
    } else {
      emit(WeatherPackage(
          locationName: state.locationName,
          locationId: state.locationId,
          updateTime: state.updateTime,
          currentTemp: celToFar(state.currentTemp),
          highTemp: celToFar(state.highTemp),
          lowTemp: celToFar(state.lowTemp),
          isFahrenheit: true,
          weatherState: state.weatherState,
          windSpeed: state.windSpeed,
          windDirection: state.windDirection,
          airPressure: state.airPressure,
          humidity: state.humidity,
          predictability: state.predictability,
          visibility: state.visibility,
          isStart: state.isStart,
          isNotFound: state.isNotFound));
    }
  }

  WeatherPackage sendBackBadPackage() {
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
        isNotFound: true);
  }

  double farToCel(double temp) {
    return (temp - 32) * (5 / 9);
  }

  double celToFar(double temp) {
    return (temp * (9 / 5)) + 32;
  }

  String getNowTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('h:mma').format(now);
    return formattedDate;
  }
}
