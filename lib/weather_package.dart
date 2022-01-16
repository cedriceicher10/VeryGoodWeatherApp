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
  int predictability;
  double visibility;

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
      required this.predictability,
      required this.visibility});
}
