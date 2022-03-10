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
late AppSizing appSize;
late AppTheme theme;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _text = TextEditingController();
  UserLocation userLocation = UserLocation();
  int _locId = -1;

  @override
  Widget build(BuildContext context) {
    appSize = AppSizing(context);
    theme = AppTheme(context);
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
                  decoration: theme.getBackgroundFade(weather.weatherState),
                  child: Center(
                    child: Column(children: [
                      SizedBox(height: appSize.spacing),
                      SizedBox(
                          width: appSize.textFieldWidth, child: searchBar()),
                      SizedBox(height: appSize.spacing),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            myLocationButton(),
                            SizedBox(width: appSize.spacing),
                            searchButton()
                          ]),
                      SizedBox(height: appSize.spacing),
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
      style: TextStyle(color: theme.textColor),
      decoration: InputDecoration(
        hintText: 'Type any big city name or coordinates',
        hintStyle: TextStyle(color: theme.textColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.textColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.textColor),
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
            fixedSize: Size(appSize.topButtonWidth, appSize.topButtonHeight)),
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
            fixedSize: Size(appSize.topButtonWidth, appSize.topButtonHeight)),
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
          width: appSize.weatherContainerWidth,
          height: appSize.weatherContainerHeight,
          padding: EdgeInsets.all(appSize.spacing),
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
          SizedBox(height: appSize.spacing),
          currentTempText(weather.currentTemp.toStringAsFixed(0),
              weather.isFahrenheit, weather.weatherState),
          SizedBox(height: appSize.spacing / 2),
          hiLoTempText(weather.highTemp.toStringAsFixed(0),
              weather.lowTemp.toStringAsFixed(0), weather.isFahrenheit),
          SizedBox(height: appSize.spacing / 2),
          weatherStateText(weather.weatherState),
          SizedBox(height: appSize.spacing),
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
            SizedBox(width: appSize.spacing * 2),
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
          SizedBox(height: appSize.spacing),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            toggleUnitsButton(),
            SizedBox(width: appSize.spacing),
            refreshButton(weather)
          ]),
          SizedBox(height: appSize.spacing),
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
                Size(appSize.bottomButtonWidth, appSize.bottomButtonHeight)),
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
                Size(appSize.bottomButtonWidth, appSize.bottomButtonHeight)),
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
    Icon metricIcon = theme.getMetricIcon(mode);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        metricIcon,
        SizedBox(width: appSize.spacing),
        FormattedText(
            text: text,
            size: appSize.fontSizeExtraSmall,
            color: theme.textColor,
            font: fontIBMPlexSans)
      ],
    );
  }

  Widget weatherStateText(String text) {
    return FormattedText(
        text: text,
        size: appSize.fontSizeMedLarge,
        color: theme.textColor,
        font: fontIBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget weatherTitle(String text) {
    return FormattedText(
        text: text,
        size: appSize.fontSizeMedLarge,
        color: theme.textColor,
        font: fontIBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget updateTimeText(String text) {
    return FormattedText(
        text: text,
        size: appSize.fontSizeExtraSmall,
        color: theme.textColor,
        font: fontIBMPlexSans);
  }

  Widget currentTempText(String text, bool isFahrenheit, String weatherState) {
    if (isFahrenheit) {
      text = text + ' °F';
    } else {
      text = text + ' °C';
    }
    Icon weatherStateIcon = theme.getWeatherStateIcon(weatherState);
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          weatherStateIcon,
          SizedBox(width: appSize.spacing * 2.5),
          FormattedText(
              text: text,
              size: appSize.fontSizeExtraLarge * 1.5,
              color: theme.textColor,
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
      size: appSize.fontSizeMedium,
      color: theme.textColor,
      font: fontIBMPlexSans,
    );
  }

  Widget weatherScreenTitle(String text) {
    return FormattedText(
        text: text,
        size: appSize.fontSizeMedLarge,
        color: Colors.white,
        font: fontBonaNova,
        weight: FontWeight.bold);
  }

  Widget topButtonText(String text) {
    return FormattedText(
        text: text,
        size: appSize.fontSizeSmall,
        color: Colors.white,
        font: fontBonaNova,
        weight: FontWeight.bold);
  }

  Widget bottomButtonText(String text) {
    return FormattedText(
        text: text,
        size: appSize.fontSizeSmaller,
        color: Colors.white,
        font: fontBonaNova,
        weight: FontWeight.bold);
  }

  Widget metaWeatherConsiderationText(String text) {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              color: theme.textColor,
              fontFamily: fontBonaNova,
              fontSize: appSize.fontSizeExtraSmall,
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
              color: theme.textColor,
              fontFamily: fontIBMPlexSans,
              fontSize: appSize.fontSizeExtraSmall,
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
        width: appSize.weatherContainerWidth,
        child: FormattedText(
            text: text,
            size: appSize.fontSizeSmaller,
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
