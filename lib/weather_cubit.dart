import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'weather_package.dart';
import 'dart:math';

class WeatherCubit extends Cubit<WeatherPackage> {
  WeatherCubit()
      : super(WeatherPackage(
            locationName: '[Ex: San Diego, CA]',
            updateTime: '1:22 PM',
            currentTemp: 78,
            highTemp: 81,
            lowTemp: 64,
            isFahrenheit: true));

  void getWeather(String location) {
    emit(WeatherPackage(
        locationName: location,
        updateTime: getNowTime(),
        currentTemp: (randNum(true) + randNum(false)) / 2,
        highTemp: randNum(true),
        lowTemp: randNum(false),
        isFahrenheit: state.isFahrenheit));
  }

  void toggleUnits() {
    if (state.isFahrenheit) {
      emit(WeatherPackage(
          locationName: state.locationName,
          updateTime: state.updateTime,
          currentTemp: farToCel(state.currentTemp),
          highTemp: farToCel(state.highTemp),
          lowTemp: farToCel(state.lowTemp),
          isFahrenheit: false));
    } else {
      emit(WeatherPackage(
          locationName: state.locationName,
          updateTime: state.updateTime,
          currentTemp: celToFar(state.currentTemp),
          highTemp: celToFar(state.highTemp),
          lowTemp: celToFar(state.lowTemp),
          isFahrenheit: true));
    }
  }

  double farToCel(double temp) {
    return (temp - 32) * (5 / 9);
  }

  double celToFar(double temp) {
    return (temp * (9 / 5)) + 32;
  }

  double randNum(bool highNum) {
    double temp = -1;
    Random random = Random();
    if (highNum) {
      temp = random.nextInt(100) + 70; // 70 - 100
    } else {
      temp = random.nextInt(70) + 0; // 0 - 70
    }
    return temp;
  }

  String getNowTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm').format(now);
    return formattedDate;
  }

  //void increment() => emit(state + 1);
  //void decrement() => emit(state - 1);
}
