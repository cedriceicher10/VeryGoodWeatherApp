import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verygoodweatherapp/utils/styles.dart';
import 'package:verygoodweatherapp/models/weather_package.dart';
import 'package:verygoodweatherapp/weather_cubit.dart';
import 'package:verygoodweatherapp/models/app_sizing.dart';
import 'package:verygoodweatherapp/models/app_theme.dart';
import 'package:verygoodweatherapp/models/meta_weather.dart';
import 'package:verygoodweatherapp/models/user_location.dart';
import 'package:verygoodweatherapp/utils/formatted_text.dart';

// App sizing and themeing
late AppSizing _appSize;
late AppTheme _theme;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _text = TextEditingController();
  final UserLocation _userLocation = UserLocation();
  int _locId = -1;

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
              return Container(
                  decoration: _theme.getBackgroundFade(weather.weatherState),
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
                      // Fade upon reloads to alert user something is happening
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                              key: UniqueKey(),
                              child: weatherContainer(weather))),
                      SizedBox(height: _appSize.spacing),
                      toggleAndRefreshButtons(weather.isStart, weather),
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
      style: TextStyle(color: _theme.textColor),
      decoration: InputDecoration(
        hintText: 'Type any big city name or coordinates',
        hintStyle: TextStyle(color: _theme.textColor),
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
          String latLonQuery =
              "${_userLocation.userLat},${_userLocation.userLon}";
          // Get weather at that lat, lon location
          context.read<WeatherCubit>().getWeather(latLonQuery);
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
          // Get weather for the text entered
          context.read<WeatherCubit>().getWeather(_text.value.text);
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

  Widget toggleAndRefreshButtons(bool isStart, WeatherPackage weather) {
    if (isStart) {
      return Container();
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        toggleUnitsButton(),
        SizedBox(width: _appSize.spacing),
        refreshButton(weather)
      ]);
    }
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
    _locId = weather.locationId;
    return Scrollbar(
        showTrackOnHover: true,
        child: SingleChildScrollView(
            child: Column(children: [
          weatherTitle(weather.locationName),
          updateTimeText('Updated at ${weather.updateTime}'),
          SizedBox(height: _appSize.spacing),
          currentTempText(weather.currentTemp.toStringAsFixed(0),
              weather.isFahrenheit, weather.weatherState),
          SizedBox(height: _appSize.spacing / 2),
          hiLoTempText(weather.highTemp.toStringAsFixed(0),
              weather.lowTemp.toStringAsFixed(0), weather.isFahrenheit),
          SizedBox(height: _appSize.spacing / 2),
          weatherStateText(weather.weatherState),
          SizedBox(height: _appSize.spacing),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                weatherMetricText('${weather.windSpeed.toStringAsFixed(0)} mph',
                    MetaWeather.windSpeed),
                weatherMetricText(
                    weather.windDirection, MetaWeather.windDirection),
                weatherMetricText(
                    '${weather.airPressure.toStringAsFixed(0)} mbar',
                    MetaWeather.airPressure)
              ],
            ),
            SizedBox(width: _appSize.spacing * 2),
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
          SizedBox(height: _appSize.spacing),
          metaWeatherConsiderationText('View this weather on MetaWeather.com')
        ])));
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
          // Get weather for current city
          context.read<WeatherCubit>().getWeather(weather.locationName);
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

  // ===========================================================================
  // FORMATTED TEXT
  // ===========================================================================

  Widget weatherMetricText(String text, String mode) {
    Icon metricIcon = _theme.getMetricIcon(mode);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        metricIcon,
        SizedBox(width: _appSize.spacing),
        FormattedText(
            text: text,
            size: _appSize.fontSizeExtraSmall,
            color: _theme.textColor,
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

  Widget updateTimeText(String text) {
    return FormattedText(
        text: text,
        size: _appSize.fontSizeExtraSmall,
        color: _theme.textColor,
        font: fontIBMPlexSans);
  }

  Widget currentTempText(String text, bool isFahrenheit, String weatherState) {
    if (isFahrenheit) {
      text = text + ' °F';
    } else {
      text = text + ' °C';
    }
    Icon weatherStateIcon = _theme.getWeatherStateIcon(weatherState);
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          weatherStateIcon,
          SizedBox(width: _appSize.spacing * 2.5),
          FormattedText(
              text: text,
              size: _appSize.fontSizeExtraLarge * 1.5,
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

  Widget metaWeatherConsiderationText(String text) {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              color: _theme.textColor,
              fontFamily: fontBonaNova,
              fontSize: _appSize.fontSizeExtraSmall,
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
              color: _theme.textColor,
              fontFamily: fontIBMPlexSans,
              fontSize: _appSize.fontSizeExtraSmall,
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
        width: _appSize.weatherContainerWidth,
        child: FormattedText(
            text: text,
            size: _appSize.fontSizeSmaller,
            color: Colors.red,
            font: fontIBMPlexSans,
            weight: FontWeight.bold,
            align: TextAlign.center));
  }

  // ===========================================================================
  // FUNCTIONS
  // ===========================================================================
  int getLocationId() {
    return _locId;
  }
}
