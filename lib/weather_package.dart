class WeatherPackage {
  String locationName;
  int locationId;
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
  bool isStart;
  bool isNotFound;

  WeatherPackage(
      {required this.locationName,
      required this.locationId,
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
      required this.visibility,
      required this.isStart,
      required this.isNotFound});

  WeatherPackage.initialize()
      : locationName = '',
        locationId = -1,
        updateTime = '',
        currentTemp = -1,
        highTemp = -1,
        lowTemp = -1,
        isFahrenheit = false,
        weatherState = '',
        windSpeed = -1,
        windDirection = '',
        airPressure = -1,
        humidity = -1,
        predictability = -1,
        visibility = -1,
        isStart = true, // Trigger for initial screen (no city yet)
        isNotFound = false;
}
