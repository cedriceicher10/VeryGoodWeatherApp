import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verygoodweatherapp/utils/styles.dart';
import 'package:verygoodweatherapp/models/weather_package.dart';
import 'package:weather_icons/weather_icons.dart';
import 'weather_cubit.dart';
import 'models/meta_weather.dart';
import 'models/user_location.dart';
import 'utils/formatted_text.dart';
import 'utils/styles.dart';

// Global sizes for easy manipulation and tinkering
double textFieldWidth = 325;
double topButtonWidth = 158;
double topButtonHeight = 40;
double bottomButtonWidth = 138;
double bottomButtonHeight = 30;
double spacing = 10;
double weatherContainerWidth = 325;
double weatherContainerHeight = 405;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // The text in the TextField
  final TextEditingController _text = TextEditingController();
  // Saved globally to allow url_launcher to access
  int _locId = -1;
  UserLocation userLocation = UserLocation();

  // Global text color of the UI
  Color _textColor = Colors.black;

  @override
  Widget build(BuildContext context) {
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
              title: weatherScreenTitle('Very Good Weather App'),
              backgroundColor: Colors.black,
              centerTitle: true,
            ),
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<WeatherCubit, WeatherPackage>(
                builder: (context, weather) {
              return Container(
                  decoration: backgroundColor(weather.weatherState),
                  child: Center(
                    child: Column(children: [
                      SizedBox(height: spacing),
                      SizedBox(width: textFieldWidth, child: searchBar()),
                      SizedBox(height: spacing),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            myLocationButton(),
                            SizedBox(width: spacing),
                            searchButton()
                          ]),
                      SizedBox(height: spacing * 2),
                      // Fade upon reloads to alert user something is happening
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                              key: UniqueKey(),
                              child: weatherContainer(weather))),
                      // Push to the bottom
                      Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: signatureText('An App by Cedric Eicher'),
                        ),
                      )
                    ]),
                  ));
            })));
  }

  // ===========================================================================
  // MAIN UI ELEMENTS (BUTTONS, WEATHER DISPLAY, SEARCH BAR)
  // ===========================================================================

  Widget searchBar() {
    return TextField(
      controller: _text,
      textInputAction: TextInputAction.search,
      //This allows the user to press Enter/Search on the keyboard to trigger
      onSubmitted: (value) {
        // Remove keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        // Get weather for current city
        context.read<WeatherCubit>().getWeather(_text.value.text);
      },
      style: TextStyle(color: _textColor),
      decoration: InputDecoration(
        hintText: 'Type any big city name or coordinates',
        hintStyle: TextStyle(color: _textColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _textColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _textColor),
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
          await userLocation.getLocation();
          String latLonQuery =
              "${userLocation.userLat},${userLocation.userLon}";
          // Get weather at that lat, lon location
          context.read<WeatherCubit>().getWeather(latLonQuery);
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.black,
            fixedSize: Size(topButtonWidth, topButtonHeight)),
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
          // Get weather for the text entered
          context.read<WeatherCubit>().getWeather(_text.value.text);
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.black,
            fixedSize: Size(topButtonWidth, topButtonHeight)),
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
          width: weatherContainerWidth,
          height: weatherContainerHeight,
          padding: EdgeInsets.all(spacing),
          child: weatherDisplay(weather));
    }
  }

  Widget weatherDisplay(WeatherPackage weather) {
    _locId = weather.locationId;
    return Column(children: [
      weatherTitle(weather.locationName),
      updateTimeText('Updated at ${weather.updateTime}'),
      SizedBox(height: spacing),
      currentTempText(weather.currentTemp.toStringAsFixed(0),
          weather.isFahrenheit, weather.weatherState),
      SizedBox(height: spacing / 2),
      hiLoTempText(weather.highTemp.toStringAsFixed(0),
          weather.lowTemp.toStringAsFixed(0), weather.isFahrenheit),
      SizedBox(height: spacing / 2),
      weatherStateText(weather.weatherState),
      SizedBox(height: spacing * 2),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            weatherMetricText('${weather.windSpeed.toStringAsFixed(0)} mph',
                MetaWeather.windSpeed),
            weatherMetricText(weather.windDirection, MetaWeather.windDirection),
            weatherMetricText('${weather.airPressure.toStringAsFixed(0)} mbar',
                MetaWeather.airPressure)
          ],
        ),
        SizedBox(width: spacing * 2),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            weatherMetricText('${weather.humidity}%', MetaWeather.humidity),
            weatherMetricText('${weather.visibility.toStringAsFixed(0)} mi',
                MetaWeather.visibility),
            weatherMetricText(
                '${weather.predictability}%', MetaWeather.predictability)
          ],
        ),
      ]),
      SizedBox(height: spacing),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        toggleUnitsButton(),
        SizedBox(width: spacing),
        refreshButton(weather)
      ]),
      // Force to bottom
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: metaWeatherConsiderationText(
              'View this weather on MetaWeather.com'),
        ),
      ),
    ]);
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
            fixedSize: Size(bottomButtonWidth, bottomButtonHeight)),
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
          // Get weather for current city
          context.read<WeatherCubit>().getWeather(weather.locationName);
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.black,
            fixedSize: Size(bottomButtonWidth, bottomButtonHeight)),
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

  // ===========================================================================
  // FORMATTED TEXT
  // ===========================================================================

  Widget weatherMetricText(String text, String mode) {
    Icon metricIcon = getMetricIcon(mode);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        metricIcon,
        SizedBox(width: spacing),
        FormattedText(
            text: text,
            size: fontSizeExtraSmall,
            color: _textColor,
            font: fontIBMPlexSans)
      ],
    );
  }

  Widget weatherStateText(String text) {
    return FormattedText(
        text: text,
        size: fontSizeMedLarge,
        color: _textColor,
        font: fontIBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget weatherTitle(String text) {
    return FormattedText(
        text: text,
        size: fontSizeMedLarge,
        color: _textColor,
        font: fontIBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget updateTimeText(String text) {
    return FormattedText(
        text: text,
        size: fontSizeExtraSmall,
        color: _textColor,
        font: fontIBMPlexSans);
  }

  Widget currentTempText(String text, bool isFahrenheit, String weatherState) {
    if (isFahrenheit) {
      text = text + ' °F';
    } else {
      text = text + ' °C';
    }
    Icon weatherStateIcon = getWeatherStateIcon(weatherState);
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          weatherStateIcon,
          SizedBox(width: spacing * 2.5),
          FormattedText(
              text: text,
              size: fontSizeExtraLarge * 1.5,
              color: _textColor,
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
      size: fontSizeMedium,
      color: _textColor,
      font: fontIBMPlexSans,
    );
  }

  Widget weatherScreenTitle(String text) {
    return FormattedText(
        text: text,
        size: fontSizeMedLarge,
        color: Colors.white,
        font: fontBonaNova,
        weight: FontWeight.bold);
  }

  Widget topButtonText(String text) {
    return FormattedText(
        text: text,
        size: fontSizeSmall,
        color: Colors.white,
        font: fontBonaNova,
        weight: FontWeight.bold);
  }

  Widget bottomButtonText(String text) {
    return FormattedText(
        text: text,
        size: fontSizeSmaller,
        color: Colors.white,
        font: fontBonaNova,
        weight: FontWeight.bold);
  }

  Widget metaWeatherConsiderationText(String text) {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              color: _textColor,
              fontFamily: fontBonaNova,
              fontSize: fontSizeExtraSmall,
              fontWeight: FontWeight.bold),
          text: text,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              int locId = getLocationId();
              var url = 'http://www.metaweather.com/$locId';
              if (!await launch(url)) throw 'Could not launch $url';
            }),
    );
  }

  Widget signatureText(String text) {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              color: _textColor,
              fontFamily: fontIBMPlexSans,
              fontSize: fontSizeExtraSmall,
              fontWeight: FontWeight.bold),
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
        'The location you chose could not be found or does not have weather at this time. \nPlease try again.\n\nTip:\nTry big cities (e.g. San Diego) or even \ncoordinates with the format \n33.8121, -117.9190. \n\nAnd be sure to check your spelling!';
    return SizedBox(
        width: weatherContainerWidth,
        child: FormattedText(
            text: text,
            size: fontSizeSmaller,
            color: Colors.red,
            font: fontIBMPlexSans,
            weight: FontWeight.bold,
            align: TextAlign.center));
  }

  // ===========================================================================
  // DISPLAY SWITCHING (BACKGROUND, TEXT COLOR)
  // ===========================================================================

  BoxDecoration backgroundColor(String weatherState) {
    // Default colors
    Color colorTop = Colors.blue;
    Color colorBottom = Colors.white;
    switch (weatherState) {
      case MetaWeather.snow:
        {
          colorTop = Colors.white;
          colorBottom = Colors.grey;
          _textColor = Colors.black;
        }
        break;
      case MetaWeather.sleet:
        {
          colorTop = Colors.black;
          colorBottom = Colors.white;
          _textColor = Colors.white;
        }
        break;
      case MetaWeather.hail:
        {
          colorTop = Colors.black;
          colorBottom = Colors.lightBlue;
          _textColor = Colors.white;
        }
        break;
      case MetaWeather.thunder:
        {
          colorTop = Colors.black;
          colorBottom = Colors.grey;
          _textColor = Colors.white;
        }
        break;
      case MetaWeather.heavyRain:
        {
          colorTop = Colors.blue;
          colorBottom = Colors.blueGrey;
          _textColor = Colors.black;
        }
        break;
      case MetaWeather.lightRain:
        {
          colorTop = Colors.blue;
          colorBottom = Colors.grey;
          _textColor = Colors.black;
        }
        break;
      case MetaWeather.showers:
        {
          colorTop = Colors.blueGrey;
          colorBottom = Colors.lightBlue;
          _textColor = Colors.black;
        }
        break;
      case MetaWeather.heavyClouds:
        {
          colorTop = const Color(darkGrey);
          colorBottom = Colors.white;
          _textColor = Colors.black;
        }
        break;
      case MetaWeather.lightClouds:
        {
          colorTop = Colors.grey;
          colorBottom = Colors.yellow;
          _textColor = Colors.black;
        }
        break;
      case MetaWeather.clear:
        {
          colorTop = Colors.yellow;
          colorBottom = Colors.blue;
          _textColor = Colors.black;
        }
        break;
    }
    return BoxDecoration(
        gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        colorTop,
        colorBottom,
      ],
    ));
  }

  Icon getWeatherStateIcon(String weatherState) {
    double iconSize = 65;
    Color iconColor = Colors.blue;
    Icon weatherStateIcon = Icon(
      WeatherIcons.day_sunny,
      color: iconColor,
      size: iconSize,
    );
    switch (weatherState) {
      // Snow
      case MetaWeather.snow:
        {
          weatherStateIcon = Icon(
            WeatherIcons.snow,
            color: Colors.white,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.sleet:
        {
          weatherStateIcon = Icon(
            WeatherIcons.sleet,
            color: Colors.grey,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.hail:
        {
          weatherStateIcon = Icon(
            WeatherIcons.hail,
            color: Colors.grey,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.thunder:
        {
          weatherStateIcon = Icon(
            WeatherIcons.thunderstorm,
            color: Colors.yellow,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.heavyRain:
        {
          weatherStateIcon = Icon(
            WeatherIcons.rain,
            color: const Color(darkBlue),
            size: iconSize,
          );
        }
        break;
      case MetaWeather.lightRain:
        {
          weatherStateIcon = Icon(
            WeatherIcons.raindrops,
            color: const Color(darkBlue),
            size: iconSize,
          );
        }
        break;
      // Showers
      case MetaWeather.showers:
        {
          weatherStateIcon = Icon(
            WeatherIcons.showers,
            color: const Color(darkBlue),
            size: iconSize,
          );
        }
        break;
      case MetaWeather.heavyClouds:
        {
          weatherStateIcon = Icon(
            WeatherIcons.cloudy,
            color: const Color(raisinBlack),
            size: iconSize,
          );
        }
        break;
      case MetaWeather.lightClouds:
        {
          weatherStateIcon = Icon(
            WeatherIcons.cloud,
            color: Colors.white,
            size: iconSize,
          );
        }
        break;
      case MetaWeather.clear:
        {
          weatherStateIcon = Icon(
            WeatherIcons.day_sunny,
            color: Colors.yellow,
            size: iconSize,
          );
        }
        break;
    }
    return weatherStateIcon;
  }

  Icon getMetricIcon(String mode) {
    double iconSize = 14;
    Color iconColor = _textColor;
    Icon metricIcon = Icon(
      WeatherIcons.day_sunny,
      color: iconColor,
      size: iconSize,
    );
    switch (mode) {
      // Wind Speed
      case MetaWeather.windSpeed:
        {
          metricIcon = Icon(
            WeatherIcons.direction_up_right,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Wind Direction
      case MetaWeather.windDirection:
        {
          metricIcon = Icon(
            WeatherIcons.wind_deg_225,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Air Pressure
      case MetaWeather.airPressure:
        {
          metricIcon = Icon(
            WeatherIcons.barometer,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Humidity
      case MetaWeather.humidity:
        {
          metricIcon = Icon(
            WeatherIcons.humidity,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Visibility
      case MetaWeather.visibility:
        {
          metricIcon = Icon(
            Icons.visibility,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Predictability
      case MetaWeather.predictability:
        {
          metricIcon = Icon(
            Icons.check,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
    }
    return metricIcon;
  }

  // ===========================================================================
  // FUNCTIONS
  // ===========================================================================
  int getLocationId() {
    return _locId;
  }
}
