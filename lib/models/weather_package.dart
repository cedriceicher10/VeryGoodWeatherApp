// WeatherPackage is inteded for use with BLoC architecture and the flutter_bloc package

class WeatherPackage {
  String locationName;
  String regionName;
  String countryName;
  String currentTime;
  String updateTime;
  double currentTemp;
  double highTemp;
  double lowTemp;
  bool isFahrenheit;
  String weatherState;
  int weatherCode;
  double windSpeed;
  String windDirection;
  double airPressure;
  int humidity;
  double precipitation;
  double visibility;
  bool isStart;
  bool isNotFound;
  List<double> hourlyTemps;
  List<double> futureWeatherHis;
  List<double> futureWeatherLos;
  List<String> futureWeatherStateText;
  List<int> futureWeatherStateCode;

  WeatherPackage(
      {required this.locationName,
      required this.regionName,
      required this.countryName,
      required this.currentTime,
      required this.updateTime,
      required this.currentTemp,
      required this.highTemp,
      required this.lowTemp,
      required this.isFahrenheit,
      required this.weatherState,
      required this.weatherCode,
      required this.windSpeed,
      required this.windDirection,
      required this.airPressure,
      required this.humidity,
      required this.precipitation,
      required this.visibility,
      required this.isStart,
      required this.isNotFound,
      required this.hourlyTemps,
      required this.futureWeatherHis,
      required this.futureWeatherLos,
      required this.futureWeatherStateText,
      required this.futureWeatherStateCode});

  // Initialize is intended for use in WeatherCubit on initalization
  WeatherPackage.initialize()
      : locationName = '',
        regionName = '',
        countryName = '',
        currentTime = '',
        updateTime = '',
        currentTemp = -1,
        highTemp = -1,
        lowTemp = -1,
        isFahrenheit = true,
        weatherState = '',
        weatherCode = -1,
        windSpeed = -1,
        windDirection = '',
        airPressure = -1,
        humidity = -1,
        precipitation = -1,
        visibility = -1,
        isStart = true, // Trigger for initial screen (no city yet)
        isNotFound = false,
        hourlyTemps = List<double>.filled(24, -1),
        futureWeatherHis = List<double>.filled(2, -1),
        futureWeatherLos = List<double>.filled(2, -1),
        futureWeatherStateText = List<String>.filled(2, ''),
        futureWeatherStateCode = List<int>.filled(2, -1);
}
