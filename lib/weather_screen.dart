import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verygoodweatherapp/utils/styles.dart';
import 'package:verygoodweatherapp/models/weather_package.dart';
import 'package:verygoodweatherapp/weather_cubit.dart';
import 'package:verygoodweatherapp/models/app_sizing.dart';
import 'package:verygoodweatherapp/models/app_theme.dart';
import 'package:verygoodweatherapp/models/weather_state.dart';
import 'package:verygoodweatherapp/models/time.dart';
import 'package:verygoodweatherapp/models/user_location.dart';
import 'package:verygoodweatherapp/utils/formatted_text.dart';

Time _time = Time();

// App sizing and themeing
late AppSizing _appSize;
late AppTheme _theme;
late WeatherPackage lastWeather;

double _tempRange = 20;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _text = TextEditingController();
  final UserLocation _userLocation = UserLocation();

  @override
  Widget build(BuildContext context) {
    _appSize = AppSizing(context);
    _theme = AppTheme(context);
    // The GestureDetector allows taps by the user to dismiss the keyboard
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: weatherScreenTitle('Simple Weather'),
              backgroundColor: Colors.black,
              centerTitle: true,
            ),
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<WeatherCubit, WeatherPackage>(
                builder: (context, weather) {
              lastWeather = weather;
              if (weather.isStart) {
                // User location on start
                getUserWeatherOnStart();
              }
              return Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: _theme.getBackgroundFade(weather.weatherCode),
                  child: Center(
                    child: Column(children: [
                      SizedBox(height: _appSize.spacing),
                      SizedBox(
                          width: _appSize.textFieldWidth, child: searchBar()),
                      SizedBox(height: _appSize.spacing),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            myLocationButton(),
                            SizedBox(width: _appSize.spacing),
                            searchButton()
                          ]),
                      SizedBox(height: _appSize.spacing),
                      bottomDisplayContainer(weather),
                    ]),
                  ));
            })));
  }

  Widget bottomDisplayContainer(WeatherPackage weather) {
    if (weather.isStart) {
      return signatureText('An App by Cedric Eicher');
    }
    return // Fade upon reloads to alert user something is happening
        Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
      AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(key: UniqueKey(), child: weatherContainer(weather))),
      SizedBox(height: _appSize.spacing),
      toggleAndRefreshButtons(weather),
      SizedBox(height: _appSize.spacing),
      signatureText('An App by Cedric Eicher')
    ])));
  }

  // ===========================================================================
  // MAIN UI ELEMENTS (BUTTONS, WEATHER DISPLAY, SEARCH BAR)
  // ===========================================================================

  getUserWeatherOnStart() async {
    // Get location
    await _userLocation.getLocation();
    if (!_userLocation.denied) {
      String latLonQuery = "${_userLocation.userLat},${_userLocation.userLon}";
      // Get weather at that lat, lon location
      context.read<WeatherCubit>().getWeather(latLonQuery, lastWeather);
    }
  }

  Widget searchBar() {
    return TextField(
      controller: _text,
      textInputAction: TextInputAction.search,
      //This allows the user to press Enter/Search on the keyboard to trigger
      onSubmitted: (value) async {
        // Remove keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        if (_text.value.text.isNotEmpty) {
          // Show snack bar (for refreshes)
          if (lastWeather.locationName == _text.value.text) {
            ScaffoldMessenger.of(context).showSnackBar(
                snackBarFloating('Checking for updated weather...', true));
          }
          // REMOVED FOR NOW: WEATHER API MAY NOT NEED THIS GEO CATCH
          // // Geocode to get lat/lon to allow for 'nearest available' weather
          // String latLonQuery;
          // try {
          //   List<Location> latLonFromAddress =
          //       await locationFromAddress(_text.value.text);
          //   latLonQuery = latLonFromAddress[0].latitude.toString() +
          //       ', ' +
          //       latLonFromAddress[0].longitude.toString();
          // } catch (exception) {
          //   latLonQuery = '';
          // }
          String latLonQuery = _text.value.text;
          // Get weather for current city
          context.read<WeatherCubit>().getWeather(latLonQuery, lastWeather);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              snackBarFloating('The search bar is empty!', false));
        }
      },
      style: TextStyle(color: _theme.textColor),
      decoration: InputDecoration(
        hintText: 'City name, coordinates, or postal code (US/UK/CAN)',
        hintStyle: TextStyle(
            color: _theme.textColor, fontSize: _appSize.fontSizeSmaller),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _theme.textColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _theme.textColor),
        ),
      ),
    );
  }

  Widget myLocationButton() {
    return ElevatedButton(
        onPressed: () async {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          // Get location
          await _userLocation.getLocation();
          if (!_userLocation.denied) {
            String latLonQuery =
                "${_userLocation.userLat},${_userLocation.userLon}";
            // Show snack bar (for refreshes)
            ScaffoldMessenger.of(context).showSnackBar(
                snackBarFloating('Checking for updated weather...', true));
            // Get weather at that lat, lon location
            context.read<WeatherCubit>().getWeather(latLonQuery, lastWeather);
          }
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.black,
            fixedSize: Size(_appSize.topButtonWidth, _appSize.topButtonHeight)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.my_location_sharp,
            color: Colors.blue,
            size: 16,
          ),
          const SizedBox(
            width: 8,
          ),
          topButtonText('My Location')
        ]));
  }

  Widget searchButton() {
    return ElevatedButton(
        onPressed: () async {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          if (_text.value.text.isNotEmpty) {
            // Show snack bar (for refreshes)
            if (lastWeather.locationName == _text.value.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                  snackBarFloating('Checking for updated weather...', true));
            }
            // REMOVED FOR NOW: WEATHER API MAY NOT NEED THIS GEO CATCH
            // // Geocode to get lat/lon to allow for 'nearest available' weather
            // String latLonQuery;
            // try {
            //   List<Location> latLonFromAddress =
            //       await locationFromAddress(_text.value.text);
            //   latLonQuery = latLonFromAddress[0].latitude.toString() +
            //       ', ' +
            //       latLonFromAddress[0].longitude.toString();
            // } catch (exception) {
            //   latLonQuery = '';
            // }
            String latLonQuery = _text.value.text;
            // Get weather for the text entered
            context.read<WeatherCubit>().getWeather(latLonQuery, lastWeather);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                snackBarFloating('The search bar is empty!', false));
          }
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.black,
            fixedSize: Size(_appSize.topButtonWidth, _appSize.topButtonHeight)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.search,
            color: Colors.blue,
            size: 16,
          ),
          const SizedBox(
            width: 8,
          ),
          topButtonText('Search')
        ]));
  }

  Widget toggleAndRefreshButtons(WeatherPackage weather) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      toggleUnitsButton(),
      SizedBox(width: _appSize.spacing),
      refreshButton(weather)
    ]);
  }

  Widget weatherContainer(WeatherPackage weather) {
    if (weather.isStart) {
      // Empty container before city has been chosen
      return Container();
    } else if (weather.isNotFound) {
      // Error message after not finding search location or weather
      return notFoundText();
    } else {
      // Weather found succesfully
      return Container(
          width: _appSize.weatherContainerWidth,
          //height: _appSize.weatherContainerHeight, // Doesn't need to be restricted
          padding: EdgeInsets.all(_appSize.spacing),
          child: weatherDisplay(weather));
    }
  }

  Widget weatherDisplay(WeatherPackage weather) {
    return Scrollbar(
        child: SingleChildScrollView(
            child: Column(children: [
      weatherTitle(weather.locationName),
      weatherLocationTitle(weather.regionName, weather.countryName),
      updateTimeText('Weather last updated at ${weather.updateTime}'),
      SizedBox(height: _appSize.spacing),
      currentTempText(weather.currentTemp.toStringAsFixed(0),
          weather.isFahrenheit, weather.weatherCode),
      SizedBox(height: _appSize.spacing / 2),
      hiLoTempText(weather.highTemp.toStringAsFixed(0),
          weather.lowTemp.toStringAsFixed(0), weather.isFahrenheit),
      SizedBox(height: _appSize.spacing / 2),
      weatherStateText(weather.weatherState),
      SizedBox(height: _appSize.spacing * 2),
      weatherHourlyForecast(weather),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            weatherMetricText('Windspeed: ',
                '${weather.windSpeed.toStringAsFixed(0)} mph', 'windSpeed'),
            weatherMetricText(
                'Wind Direction:', weather.windDirection, 'windDirection'),
            weatherMetricText('Air Pressure:',
                '${weather.airPressure.toStringAsFixed(0)} mbar', 'airPressure')
          ],
        ),
        SizedBox(width: _appSize.spacing * 2),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            weatherMetricText('Humidity:', '${weather.humidity}%', 'humidity'),
            weatherMetricText('Visibility:',
                '${weather.visibility.toStringAsFixed(0)} mi', 'visibility'),
            weatherMetricText(
                'Precip:', '${weather.precipitation} in', 'predictability')
          ],
        ),
      ]),
      SizedBox(height: _appSize.spacing),
      Container(
          height: _appSize.nextDaysWeatherContainerHeight,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.5, color: Colors.black),
              bottom: BorderSide(width: 0.5, color: Colors.black),
            ),
          ),
          child: futureWeatherList(weather)),
      SizedBox(height: _appSize.spacing),
      apiConsiderationText('Courtesy of Weather API')
    ])));
  }

  Widget weatherHourlyForecast(WeatherPackage weather) {
    _tempRange =
        weather.hourlyTemps.reduce(max) - weather.hourlyTemps.reduce(min);
    return SizedBox(
      height: 75,
      width: _appSize.textFieldWidth,
      //decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 24,
          minY: weather.hourlyTemps.reduce(min) - 4,
          maxY: weather.hourlyTemps.reduce(max) + 4,
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: hourTitleWidgets,
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: tempTitleWidgets,
                reservedSize: 25,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: tempGridHorizontalLines,
            getDrawingVerticalLine: tempGridVerticalLines,
          ),
          lineBarsData: [
            LineChartBarData(
                spots: dataPoints(weather),
                isCurved: true,
                color: _theme.iconColor,
                shadow: const Shadow(blurRadius: 8, color: Colors.black),
                gradient: LinearGradient(
                  colors: [
                    const Color(raisinBlack),
                    _theme.iconColor,
                    _theme.iconColor,
                    const Color(raisinBlack),
                  ],
                  stops: const [0.1, 0.3, 0.9, 0.95],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                        colors: [
                          const Color(darkBlue).withOpacity(0.3),
                          const Color(darkBlue).withOpacity(0.3),
                          Colors.yellow.withOpacity(0.3),
                          Colors.yellow.withOpacity(0.3),
                          Colors.yellow.withOpacity(0.3),
                          const Color(darkBlue).withOpacity(0.3),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight)))
          ],
        ),
      ),
    );
  }

  FlLine tempGridVerticalLines(double value) {
    FlLine verticalLine = FlLine(
      color: const Color(0xff37434d),
      strokeWidth: 0.25,
    );
    if ((value.toInt() == 1) ||
        (value.toInt() == 4) ||
        (value.toInt() == 7) ||
        (value.toInt() == 10) ||
        (value.toInt() == 13) ||
        (value.toInt() == 16) ||
        (value.toInt() == 19) ||
        (value.toInt() == 22) ||
        (value.toInt() == 24)) {
      return verticalLine;
    } else {
      return FlLine(strokeWidth: 0);
    }
  }

  FlLine tempGridHorizontalLines(double value) {
    FlLine horizontalLine = FlLine(
      color: const Color(0xff37434d),
      strokeWidth: 0.25,
    );
    if (value.toInt() % 10 == 0) {
      return horizontalLine;
    } else {
      return FlLine(strokeWidth: 0);
    }
  }

  Widget hourTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );
    String text;
    if ((value.toInt() == 1) || (value.toInt() == 24)) {
      text = '12a';
    } else if (value.toInt() == 4) {
      text = '3a';
    } else if (value.toInt() == 7) {
      text = '6a';
    } else if (value.toInt() == 10) {
      text = '9a';
    } else if (value.toInt() == 13) {
      text = '12p';
    } else if (value.toInt() == 16) {
      text = '3p';
    } else if (value.toInt() == 19) {
      text = '6p';
    } else if (value.toInt() == 22) {
      text = '9p';
    } else {
      return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.center);
  }

  Widget tempTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );
    String text;
    if (value.toInt() % graphRange(_tempRange) == 0) {
      text = value.toInt().toString();
    } else {
      return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  List<FlSpot> dataPoints(WeatherPackage weather) {
    List<FlSpot> listSpots = [];
    for (int index = 0; index < 24; ++index) {
      listSpots.add(FlSpot(
          index.toDouble() + 1, weather.hourlyTemps[index].roundToDouble()));
    }
    return listSpots;
  }

  int graphRange(double tempRange) {
    if (tempRange < 10) {
      return 5;
    }
    return 10;
  }

  Widget futureWeatherList(WeatherPackage weather) {
    double widthSpacing = _appSize.spacing / 2;

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          futureWeatherItem(weather, 0),
          SizedBox(width: widthSpacing),
          futureWeatherItem(weather, 1),
          SizedBox(width: widthSpacing),
        ]);

    // This method is for when future cast had more days than
    // could fit on the screen (hence horizontal scrolling). Currently
    // Weather API only allows 3 forecast days for free (inluding the day of),
    // so this'll be binned until that changes.
    // return ListView(scrollDirection: Axis.horizontal, children: [
    //   futureWeatherItem(weather, 0),
    //   SizedBox(width: widthSpacing),
    //   futureWeatherItem(weather, 1),
    //   SizedBox(width: widthSpacing),
    // ]);
  }

  Widget futureWeatherItem(WeatherPackage weather, int index) {
    List<String> futureWeatherDays = _time.getFutureDays();
    String hiLoTempText = weather.futureWeatherHis[index].toStringAsFixed(0) +
        '°  |  ' +
        weather.futureWeatherLos[index].toStringAsFixed(0) +
        '°';
    Icon weatherIcon = _theme.getWeatherStateIcon(
        weather.futureWeatherStateCode[index], WEATHER_DISPLAY.futureTemp);
    return SizedBox(
        width: _appSize.weatherContainerWidth / 4,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FormattedText(
                  text: futureWeatherDays[index],
                  size: _appSize.fontSizeSmall,
                  color: _theme.textColor,
                  font: fontIBMPlexSans,
                  weight: FontWeight.bold),
              weatherIcon,
              SizedBox(height: _appSize.spacing * 2),
              FormattedText(
                  text: hiLoTempText,
                  size: _appSize.fontSizeExtraSmall,
                  color: _theme.textColor,
                  font: fontIBMPlexSans)
            ]));
  }

  Widget toggleUnitsButton() {
    return ElevatedButton(
        onPressed: () async {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          // Toggle units
          context.read<WeatherCubit>().toggleUnits();
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.black,
            fixedSize:
                Size(_appSize.bottomButtonWidth, _appSize.bottomButtonHeight)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.switch_right_sharp,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(
            width: 8,
          ),
          bottomButtonText('Toggle °F/°C')
        ]));
  }

  Widget refreshButton(WeatherPackage weather) {
    return ElevatedButton(
        onPressed: () async {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          // Show snack bar (for refreshes)
          ScaffoldMessenger.of(context).showSnackBar(
              snackBarFloating('Checked for updated weather...', true));
          // Get weather for current city
          context
              .read<WeatherCubit>()
              .getWeather(weather.locationName, lastWeather);
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.black,
            fixedSize:
                Size(_appSize.bottomButtonWidth, _appSize.bottomButtonHeight)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.refresh_sharp,
            color: Colors.yellow,
            size: 16,
          ),
          const SizedBox(
            width: 8,
          ),
          bottomButtonText('Refresh')
        ]));
  }

  Widget scrollForMoreIcon(WeatherPackage weather) {
    if (weather.isStart) {
      // Empty container before city has been chosen
      return Container();
    } else {
      double iconSize = 20;
      Color iconColor = _theme.textColor;
      return Icon(
        Icons.arrow_drop_down,
        color: iconColor,
        size: iconSize,
      );
    }
  }

  SnackBar snackBarFloating(String text, bool isRefresh) {
    Color? snackBarColor = Colors.yellow[700]!.withOpacity(0.95);
    if (!isRefresh) {
      snackBarColor = Colors.red[500]!.withOpacity(0.9);
    }
    return SnackBar(
      content: snackBarText(text),
      backgroundColor: snackBarColor,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 30,
          left: 30),
    );
  }

  // ===========================================================================
  // FORMATTED TEXT
  // ===========================================================================

  Widget snackBarText(String text) {
    return FormattedText(
        text: text,
        size: _appSize.fontSizeExtraSmall * 1.15,
        color: Colors.white,
        font: fontIBMPlexSans,
        weight: FontWeight.bold,
        style: FontStyle.italic,
        align: TextAlign.center);
  }

  Widget weatherMetricText(String metricName, String metric, String mode) {
    Icon metricIcon = _theme.getMetricIcon(mode);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        metricIcon,
        SizedBox(width: _appSize.spacing / 2),
        FormattedText(
            text: metricName,
            size: _appSize.fontSizeExtraSmall,
            color: _theme.textColor,
            font: fontIBMPlexSans),
        FormattedText(
            text: metric,
            size: _appSize.fontSizeExtraSmall,
            color: _theme.textColor,
            weight: FontWeight.bold,
            font: fontIBMPlexSans)
      ],
    );
  }

  Widget weatherStateText(String text) {
    return FormattedText(
        text: text,
        size: _appSize.fontSizeMedLarge,
        color: _theme.textColor,
        font: fontIBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget weatherTitle(String text) {
    return FormattedText(
        text: text,
        size: _appSize.fontSizeMedLarge,
        color: _theme.textColor,
        font: fontIBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget weatherLocationTitle(String region, String country) {
    return FormattedText(
        text: region + ', ' + country,
        size: _appSize.fontSizeExtraSmall,
        color: _theme.textColor,
        font: fontIBMPlexSans,
        weight: FontWeight.bold,
        style: FontStyle.italic);
  }

  Widget updateTimeText(String text) {
    return FormattedText(
        text: text,
        size: _appSize.fontSizeExtraSmall,
        color: _theme.textColor,
        font: fontIBMPlexSans,
        style: FontStyle.italic);
  }

  Widget currentTempText(String text, bool isFahrenheit, int weatherCode) {
    if (isFahrenheit) {
      text = text + ' °F';
    } else {
      text = text + ' °C';
    }

    Icon weatherStateIcon =
        _theme.getWeatherStateIcon(weatherCode, WEATHER_DISPLAY.mainTemp);

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          weatherStateIcon,
          SizedBox(width: _appSize.spacing * 2.5),
          FormattedText(
              text: text,
              size: _appSize.fontSizeExtraLarge * 1.48,
              color: _theme.textColor,
              font: fontIBMPlexSans,
              weight: FontWeight.bold)
        ]);
  }

  Widget hiLoTempText(String highTemp, String lowTemp, bool isFahrenheit) {
    String text = '';
    if (isFahrenheit) {
      text = '$highTemp °F   |   $lowTemp °F';
    } else {
      text = '$highTemp °C   |   $lowTemp °C';
    }
    return FormattedText(
      text: text,
      size: _appSize.fontSizeMedium,
      color: _theme.textColor,
      font: fontIBMPlexSans,
    );
  }

  Widget weatherScreenTitle(String text) {
    return FormattedText(
        text: text,
        size: _appSize.fontSizeMedLarge,
        color: Colors.white,
        font: fontBonaNova,
        weight: FontWeight.bold);
  }

  Widget topButtonText(String text) {
    return FormattedText(
        text: text,
        size: _appSize.fontSizeSmall,
        color: Colors.white,
        font: fontBonaNova,
        weight: FontWeight.bold);
  }

  Widget bottomButtonText(String text) {
    return FormattedText(
        text: text,
        size: _appSize.fontSizeSmaller,
        color: Colors.white,
        font: fontBonaNova,
        weight: FontWeight.bold);
  }

  Widget apiConsiderationText(String text) {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              color: _theme.textColor,
              fontFamily: fontBonaNova,
              fontSize: _appSize.fontSizeExtraSmall,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
          text: text,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              var url = 'http://www.weatherapi.com';
              if (!await launch(url)) throw 'Could not launch $url';
            }),
    );
  }

  Widget signatureText(String text) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          style: TextStyle(
              color: _theme.textColor,
              fontFamily: fontIBMPlexSans,
              fontSize: _appSize.fontSizeExtraSmall,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
          text: text,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              var url = 'https://www.linkedin.com/in/cedriceicher/';
              if (!await launch(url)) throw 'Could not launch $url';
            }),
    );
  }

  Widget notFoundText() {
    String text =
        'Simple Weather could not find weather for the entered location.\n\nTip:\nTry a city name, coordinates, postal code (US/UK/CAN), or even country/region name! \n\nAnd be sure to check your spelling!';
    return SizedBox(
        width: _appSize.weatherContainerWidth,
        child: FormattedText(
            text: text,
            size: _appSize.fontSizeSmaller,
            color: _theme.textColor,
            font: fontIBMPlexSans,
            weight: FontWeight.bold,
            align: TextAlign.center));
  }
}
