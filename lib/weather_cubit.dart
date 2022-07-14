import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verygoodweatherapp/models/api_key.dart';
import 'package:verygoodweatherapp/models/weather_state.dart';
import 'package:verygoodweatherapp/models/time.dart';
import 'package:verygoodweatherapp/models/weather_package.dart';

String _baseUrl = 'api.weatherapi.com';
String _apiMethod = '/v1/forecast.json';
Time _time = Time();
ApiKey _api =
    ApiKey('weatherApiKey.txt'); // For release: Replace with hard-coded key
String _myApiKey = '';

class WeatherCubit extends Cubit<WeatherPackage> {
  final Client httpClient = Client();

  WeatherCubit() : super(WeatherPackage.initialize());

  void getWeather(String location, WeatherPackage lastWeather) async {
    // Poll for weather
    WeatherPackage newWeather = await getWeatherInfo(location);

    // Only trigger refresh if new weather is found
    bool validateNewWeather = validate(lastWeather, newWeather);
    if ((validateNewWeather) || (newWeather.isNotFound)) {
      emit(newWeather);
    }
  }

  bool validate(WeatherPackage lastWeather, WeatherPackage newWeather) {
    // If the temps/locations are the same, don't refresh the screen
    if ((lastWeather.currentTemp == newWeather.currentTemp) &&
        (lastWeather.locationName == newWeather.locationName)) {
      return false;
    }
    lastWeather = newWeather;
    return true;
  }

  Future<WeatherPackage> getWeatherInfo(String location) async {
    _myApiKey =
        await _api.readApiKey(); // For release: Replace with hard-coded key

    // CURRENT WEATHER

    // https://www.weatherapi.com/api-explorer.aspx
    // Param q: Pass US Zipcode, UK Postcode, Canada Postalcode, IP address,
    //          Latitude/Longitude (decimal degree) or city name
    Uri weatherRequest = Uri.https(_baseUrl, _apiMethod, <String, String>{
      'key': _myApiKey,
      'q': location,
      'days': '3', // >3 day forecast is part of a paid plan
      'aqi': 'yes',
      'alerts': 'no'
    });

    Response weatherResponse = await httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
      throw ('Location search response code != 200');
      return sendBackBadPackage();
    }

    Map<String, dynamic> weatherResponseJson = jsonDecode(
      weatherResponse.body,
    );

    if (weatherResponseJson.isEmpty) {
      throw ('Location search response is empty');
      return sendBackBadPackage();
    }

    // Convert to WeatherPackage object
    WeatherPackage emitWeather =
        weatherResponseJsonConverter(weatherResponseJson);

    // FORECAST WEATHER

    return emitWeather;
  }

  WeatherPackage weatherResponseJsonConverter(
      Map<String, dynamic> weatherResponseJson) {
    // Convert from the WeatherState JSON package to WeatherPackage object
    WeatherPackage weatherPackage = WeatherPackage(
        locationName: weatherResponseJson['location']['name'],
        updateTime: _time.convertZuluTime(
            weatherResponseJson['current']['last_updated_epoch']),
        currentTemp: weatherResponseJson['current']['temp_c'], // C
        highTemp: weatherResponseJson['forecast']['forecastday'][0]['day']
            ['maxtemp_c'], // C
        lowTemp: weatherResponseJson['forecast']['forecastday'][0]['day']
            ['mintemp_c'], // C
        isFahrenheit: state.isFahrenheit,
        weatherState: weatherResponseJson['current']['condition']['text'],
        weatherCode: weatherResponseJson['current']['condition']['code'],
        windSpeed: weatherResponseJson['current']['wind_mph'], // mph
        windDirection: weatherResponseJson['current']['wind_dir'],
        airPressure: weatherResponseJson['current']['pressure_mb'], // mbar
        humidity: weatherResponseJson['current']['humidity'], // %
        precipitation: weatherResponseJson['current']['precip_in'], // in
        visibility: weatherResponseJson['current']['vis_miles'], // mi
        isStart: false,
        isNotFound: false,
        hourlyTemps: hourlyTempsExtraction(weatherResponseJson),
        futureWeatherHis: [
          weatherResponseJson['forecast']['forecastday'][1]['day']['maxtemp_c'],
          weatherResponseJson['forecast']['forecastday'][2]['day']['maxtemp_c']
        ],
        futureWeatherLos: [
          weatherResponseJson['forecast']['forecastday'][1]['day']['mintemp_c'],
          weatherResponseJson['forecast']['forecastday'][2]['day']['mintemp_c']
        ],
        futureWeatherStateText: [
          weatherResponseJson['forecast']['forecastday'][1]['day']['condition']
              ['text'],
          weatherResponseJson['forecast']['forecastday'][2]['day']['condition']
              ['text']
        ],
        futureWeatherStateCode: [
          weatherResponseJson['forecast']['forecastday'][1]['day']['condition']
              ['code'],
          weatherResponseJson['forecast']['forecastday'][2]['day']['condition']
              ['code']
        ]); // mi
    if (weatherPackage.isFahrenheit) {
      weatherPackage.currentTemp = celToFarDouble(weatherPackage.currentTemp);
      weatherPackage.highTemp = celToFarDouble(weatherPackage.highTemp);
      weatherPackage.lowTemp = celToFarDouble(weatherPackage.lowTemp);
      for (int index = 0; index < 2; ++index) {
        weatherPackage.futureWeatherHis[index] =
            celToFarDouble(weatherPackage.futureWeatherHis[index]);
        weatherPackage.futureWeatherLos[index] =
            celToFarDouble(weatherPackage.futureWeatherLos[index]);
      }
      for (int index = 0; index < 24; ++index) {
        weatherPackage.hourlyTemps[index] =
            celToFarDouble(weatherPackage.hourlyTemps[index]);
      }
      weatherPackage.isFahrenheit = true;
    }
    return weatherPackage;
  }

  List<double> hourlyTempsExtraction(Map<String, dynamic> weatherResponseJson) {
    List<double> listHourlyTemps = [];
    for (int index = 0; index < 24; ++index) {
      listHourlyTemps.add(weatherResponseJson['forecast']['forecastday'][0]
          ['hour'][index]['temp_c']);
    }
    return listHourlyTemps;
  }

  void toggleUnits() {
    // F to C
    if (state.isFahrenheit) {
      emit(WeatherPackage(
          locationName: state.locationName,
          updateTime: state.updateTime,
          currentTemp: farToCelDouble(state.currentTemp),
          highTemp: farToCelDouble(state.highTemp),
          lowTemp: farToCelDouble(state.lowTemp),
          isFahrenheit: false,
          weatherState: state.weatherState,
          weatherCode: state.weatherCode,
          windSpeed: state.windSpeed,
          windDirection: state.windDirection,
          airPressure: state.airPressure,
          humidity: state.humidity,
          precipitation: state.precipitation,
          visibility: state.visibility,
          isStart: state.isStart,
          isNotFound: state.isNotFound,
          hourlyTemps: state.hourlyTemps,
          futureWeatherHis: farToCelList(state.futureWeatherHis),
          futureWeatherLos: farToCelList(state.futureWeatherLos),
          futureWeatherStateText: state.futureWeatherStateText,
          futureWeatherStateCode: state.futureWeatherStateCode));
    } else {
      // C to F
      emit(WeatherPackage(
          locationName: state.locationName,
          updateTime: state.updateTime,
          currentTemp: celToFarDouble(state.currentTemp),
          highTemp: celToFarDouble(state.highTemp),
          lowTemp: celToFarDouble(state.lowTemp),
          isFahrenheit: true,
          weatherState: state.weatherState,
          weatherCode: state.weatherCode,
          windSpeed: state.windSpeed,
          windDirection: state.windDirection,
          airPressure: state.airPressure,
          humidity: state.humidity,
          precipitation: state.precipitation,
          visibility: state.visibility,
          isStart: state.isStart,
          isNotFound: state.isNotFound,
          hourlyTemps: state.hourlyTemps,
          futureWeatherHis: celToFarList(state.futureWeatherHis),
          futureWeatherLos: celToFarList(state.futureWeatherLos),
          futureWeatherStateText: state.futureWeatherStateText,
          futureWeatherStateCode: state.futureWeatherStateCode));
    }
  }

  WeatherPackage sendBackBadPackage() {
    // Bad package is for when location/weather isn't found
    return WeatherPackage(
        locationName: state.locationName,
        updateTime: state.updateTime,
        currentTemp: state.currentTemp,
        highTemp: state.highTemp,
        lowTemp: state.lowTemp,
        isFahrenheit: state.isFahrenheit,
        weatherState: state.weatherState,
        weatherCode: state.weatherCode,
        windSpeed: state.windSpeed,
        windDirection: state.windDirection,
        airPressure: state.airPressure,
        humidity: state.humidity,
        precipitation: state.precipitation,
        visibility: state.visibility,
        isStart: false,
        isNotFound: true,
        hourlyTemps: state.hourlyTemps,
        futureWeatherHis: state.futureWeatherHis,
        futureWeatherLos: state.futureWeatherLos,
        futureWeatherStateText: state.futureWeatherStateText,
        futureWeatherStateCode: state.futureWeatherStateCode);
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


// CODE GRAVEYARD 

    // ~~~~~~~~~~~~~ OLD API: WeatherState
    // // Determine if a city name or lat/lon coordinates
    // bool locationContainsNumerals = location.contains(RegExp(r'[0-9]'));
    // // Created using https://www.WeatherState.com/api/
    // // Find the location and corresponding location id
    // int locId = await getLocId(location, locationContainsNumerals);
    // // Find the weather info using the location id
    // WeatherPackage newWeather = await getWeatherInfo(location, locId);
    // // Only trigger refresh if new weather is found
    // bool validateNewWeather = validate(lastWeather, newWeather);
    // if ((validateNewWeather) || (newWeather.isNotFound)) {
    //   emit(newWeather);
    // }
    // ~~~~~~~~~~~~~ OLD API: WeatherState



  // Future<int> getLocId(String location, bool isLatLon) async {
  //   Uri locationSearchRequest;
  //   //Query for a location search to WeatherState
  //   if (isLatLon) {
  //     // Lat Lon
  //     locationSearchRequest = Uri.https(
  //         _baseUrlWeatherState,
  //         _baseApiCallLocationSearch,
  //         <String, String>{_apiCallLocationSearch: location});
  //   } else {
  //     // City name
  //     locationSearchRequest = Uri.https(
  //         _baseUrlWeatherState,
  //         _baseApiCallLocationSearch,
  //         <String, String>{_apiCallLocation: location});
  //   }
  //   Response locationSearchResponse =
  //       await httpClient.get(locationSearchRequest);
  //   // Ensure return doesn't have an error status code
  //   // (typically only happens if passing an empty input)
  //   if (locationSearchResponse.statusCode != 200) {
  //     //throw ('Location search response code != 200');
  //     return -1;
  //   }
  //   // Ensure return has an actual location and location id
  //   List locationSearchResponseJson = jsonDecode(
  //     locationSearchResponse.body,
  //   ) as List;
  //   if (locationSearchResponseJson.isEmpty) {
  //     //throw ('Location search response code is empty');
  //     return -1;
  //   }
  //   // Save location name (visually pleasing)
  //   locationNameVisuallyPleasing =
  //       locationSearchResponseJson[0][WeatherState.locationName];
  //   // Extract location id
  //   return locationSearchResponseJson[0][WeatherState.locationId];
  // }
