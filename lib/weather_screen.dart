import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verygoodweatherapp/styles.dart';
import 'package:verygoodweatherapp/weather_package.dart';
import 'package:weather_icons/weather_icons.dart';
import 'formatted_text.dart';
import 'weather_cubit.dart';

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
  final TextEditingController _text = TextEditingController();
  int _locId = -1; // Saved globally to allow url_launcher to access

  @override
  Widget build(BuildContext context) {
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
              return Center(
                child: Column(children: [
                  SizedBox(height: spacing),
                  SizedBox(width: textFieldWidth, child: searchBar()),
                  SizedBox(height: spacing),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    myLocationButton(),
                    SizedBox(width: spacing),
                    searchButton()
                  ]),
                  SizedBox(height: spacing * 2),
                  weatherContainer(weather),
                  Expanded(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: signatureText('An App by Cedric Eicher'),
                    ),
                  )
                ]),
              );
            })));
  }

  Widget searchBar() {
    return TextField(
      controller: _text,
      textInputAction: TextInputAction.search,
      // This allows the user to press Enter/Search on the keyboard to trigger
      onSubmitted: (value) {
        // Remove keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        // Get weather for current city
        context.read<WeatherCubit>().getWeather(_text.value.text);
      },
      decoration: const InputDecoration(
        hintText: 'Type any big city name',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
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
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(builder: (context) => const StartScreen()),
          //     (Route<dynamic> route) => false);
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
          // Get weather for current city
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
      // Error finding search location or weather
      return notFoundText();
    } else {
      return Container(
          width: weatherContainerWidth,
          height: weatherContainerHeight,
          padding: EdgeInsets.all(spacing),
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
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
            weatherMetricText('${weather.windSpeed.toStringAsFixed(0)} mph', 1),
            weatherMetricText(weather.windDirection, 2),
            weatherMetricText(
                '${weather.airPressure.toStringAsFixed(0)} mbar', 3)
          ],
        ),
        SizedBox(width: spacing * 2),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            weatherMetricText('${weather.humidity}%', 4),
            weatherMetricText('${weather.visibility.toStringAsFixed(0)} mi', 5),
            weatherMetricText('${weather.predictability}%', 6)
          ],
        ),
      ]),
      SizedBox(height: spacing),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        toggleUnitsButton(),
        SizedBox(width: spacing),
        refreshButton(weather)
      ]),
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: meatWeatherConsiderationText(
              'View this weather on MetaWeather.com'),
        ),
      ),
    ]);
  }

  Widget weatherMetricText(String text, int mode) {
    Icon metricIcon = getMetricIcon(mode);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        metricIcon,
        SizedBox(width: spacing),
        FormattedText(
            text: text,
            size: s_fontSizeExtraSmall,
            color: Colors.black,
            font: s_font_IBMPlexSans)
      ],
    );
  }

  Widget weatherStateText(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeMedLarge,
        color: Colors.black,
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget weatherTitle(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeMedLarge,
        color: Colors.black,
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget updateTimeText(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeExtraSmall,
        color: Colors.black,
        font: s_font_IBMPlexSans);
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
              size: s_fontSizeExtraLarge * 1.5,
              color: Colors.black,
              font: s_font_IBMPlexSans,
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
      size: s_fontSizeMedium,
      color: Colors.black,
      font: s_font_IBMPlexSans,
    );
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

  Widget weatherScreenTitle(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeMedLarge,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget topButtonText(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeSmall,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget bottomButtonText(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeSmaller,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget meatWeatherConsiderationText(String text) {
    return RichText(
      text: TextSpan(
          style: const TextStyle(
              color: Colors.black,
              fontFamily: s_font_BonaNova,
              fontSize: s_fontSizeExtraSmall,
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

  int getLocationId() {
    return _locId;
  }

  Widget signatureText(String text) {
    return RichText(
      text: TextSpan(
          style: const TextStyle(
              color: Colors.black,
              fontFamily: s_font_IBMPlexSans,
              fontSize: s_fontSizeExtraSmall,
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
        'The city you chose could not be found or does not have weather at this time. Please try again.\n(Tip: Try big cities!)';
    return SizedBox(
        width: weatherContainerWidth * 0.9,
        child: FormattedText(
            text: text,
            size: s_fontSizeSmall,
            color: Colors.red,
            font: s_font_IBMPlexSans,
            weight: FontWeight.bold,
            align: TextAlign.center));
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
      case 'Snow':
        {
          weatherStateIcon = Icon(
            WeatherIcons.snow,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Sleet
      case 'Sleet':
        {
          weatherStateIcon = Icon(
            WeatherIcons.sleet,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Hail
      case 'Hail':
        {
          weatherStateIcon = Icon(
            WeatherIcons.hail,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Thunderstorm
      case 'Thunderstorm':
        {
          weatherStateIcon = Icon(
            WeatherIcons.thunderstorm,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Heavy Rain
      case 'Heavy Rain':
        {
          weatherStateIcon = Icon(
            WeatherIcons.rain,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Light Rain
      case 'Light Rain':
        {
          weatherStateIcon = Icon(
            WeatherIcons.raindrops,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Showers
      case 'Showers':
        {
          weatherStateIcon = Icon(
            WeatherIcons.showers,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Heavy Cloud
      case 'Heavy Cloud':
        {
          weatherStateIcon = Icon(
            WeatherIcons.cloudy,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Light Cloud
      case 'Light Cloud':
        {
          weatherStateIcon = Icon(
            WeatherIcons.cloud,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Clear
      case 'Clear':
        {
          weatherStateIcon = Icon(
            WeatherIcons.day_sunny,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
    }
    return weatherStateIcon;
  }

  Icon getMetricIcon(int mode) {
    double iconSize = 14;
    Color iconColor = Colors.black;
    Icon metricIcon = Icon(
      WeatherIcons.day_sunny,
      color: iconColor,
      size: iconSize,
    );
    switch (mode) {
      // Wind Speed
      case 1:
        {
          metricIcon = Icon(
            WeatherIcons.direction_up_right,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Wind Direction
      case 2:
        {
          metricIcon = Icon(
            WeatherIcons.wind_deg_225,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Air Pressure
      case 3:
        {
          metricIcon = Icon(
            WeatherIcons.barometer,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Humidity
      case 4:
        {
          metricIcon = Icon(
            WeatherIcons.humidity,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Visibility
      case 5:
        {
          metricIcon = Icon(
            Icons.visibility,
            color: iconColor,
            size: iconSize,
          );
        }
        break;
      // Predictability
      case 6:
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
}
