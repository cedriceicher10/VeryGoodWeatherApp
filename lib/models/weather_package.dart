// WeatherPackage is inteded for use with BLoC architecture and the flutter_bloc package

class WeatherPackage {
  String locationName;
  String updateTime;
  double currentTemp;
  double highTemp;
  double lowTemp;
  bool isFahrenheit;
  String weatherState;
  double windSpeed;
  String windDirection;
  double airPressure;
  int humidity;
  double precipitation;
  double visibility;
  bool isStart;
  bool isNotFound;
  List<double> futureWeatherHis;
  List<double> futureWeatherLos;
  List<int> futureWeatherStates;

  WeatherPackage(
      {required this.locationName,
      required this.updateTime,
      required this.currentTemp,
      required this.highTemp,
      required this.lowTemp,
      required this.isFahrenheit,
      required this.weatherState,
      required this.windSpeed,
      required this.windDirection,
      required this.airPressure,
      required this.humidity,
      required this.precipitation,
      required this.visibility,
      required this.isStart,
      required this.isNotFound,
      required this.futureWeatherHis,
      required this.futureWeatherLos,
      required this.futureWeatherStates});

  // Initialize is intended for use in WeatherCubit on initalization
  WeatherPackage.initialize()
      : locationName = '',
        updateTime = '',
        currentTemp = -1,
        highTemp = -1,
        lowTemp = -1,
        isFahrenheit = true,
        weatherState = '',
        windSpeed = -1,
        windDirection = '',
        airPressure = -1,
        humidity = -1,
        precipitation = -1,
        visibility = -1,
        isStart = true, // Trigger for initial screen (no city yet)
        isNotFound = false,
        futureWeatherHis = List<double>.filled(2, 0),
        futureWeatherLos = List<double>.filled(2, 0),
        futureWeatherStates = List<int>.filled(2, 0);

  // Output for comparison or debugging
  String toOutputString(WeatherPackage weatherPackage) {
    return '${weatherPackage.locationName}, ${weatherPackage.updateTime}, ${weatherPackage.currentTemp}, ${weatherPackage.highTemp}, ${weatherPackage.lowTemp}, ${weatherPackage.isFahrenheit}, ${weatherPackage.weatherState}, ${weatherPackage.windSpeed}, ${weatherPackage.windDirection}, ${weatherPackage.airPressure}, ${weatherPackage.humidity}, ${weatherPackage.visibility}, ${weatherPackage.precipitation}, ${weatherPackage.isStart}, ${weatherPackage.isNotFound}';
  }
}
