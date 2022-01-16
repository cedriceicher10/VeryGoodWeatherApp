import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verygoodweatherapp/styles.dart';
import 'package:verygoodweatherapp/weather_package.dart';
import 'formatted_text.dart';
import 'weather_cubit.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const double textFieldWidth = 325;
    const double topButtonWidth = 158;
    const double topButtonHeight = 40;
    const double bottomButtonWidth = 138;
    const double bottomButtonHeight = 30;
    const double spacing = 10;
    const double weatherContainerWidth = 325;
    const double weatherContainerHeight = 325;

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
                  const SizedBox(height: spacing),
                  SizedBox(width: textFieldWidth, child: searchBar()),
                  const SizedBox(height: spacing),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    myLocationButton(topButtonWidth, topButtonHeight),
                    const SizedBox(width: spacing),
                    searchButton(topButtonWidth, topButtonHeight)
                  ]),
                  const SizedBox(height: spacing * 4),
                  weatherContainer(
                      weather, weatherContainerWidth, weatherContainerHeight),
                  meatWeatherConsideration(
                      'Weather provided by MetaWeather.com'),
                  const SizedBox(height: spacing / 2),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    toggleUnitsButton(bottomButtonWidth, bottomButtonHeight),
                    const SizedBox(width: spacing),
                    refreshButton(
                        weather, bottomButtonWidth, bottomButtonHeight)
                  ]),
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

  Widget myLocationButton(double buttonWidth, double buttonHeight) {
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
            primary: Colors.black, fixedSize: Size(buttonWidth, buttonHeight)),
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

  Widget searchButton(double buttonWidth, double buttonHeight) {
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
            primary: Colors.black, fixedSize: Size(buttonWidth, buttonHeight)),
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

  Widget weatherContainer(WeatherPackage weather, double weatherContainerWidth,
      double weatherContainerHeight) {
    return Container(
      width: weatherContainerWidth,
      height: weatherContainerHeight,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: weatherDisplay(weather),
    );
  }

  Widget weatherDisplay(WeatherPackage weather) {
    return Column(children: [
      weatherTitle('Weather in ${weather.locationName}'),
      updateTime('Updated at ${weather.updateTime}'),
      const SizedBox(height: 10),
      currentTemp(weather.currentTemp.toStringAsFixed(0), weather.isFahrenheit),
      const SizedBox(height: 5),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        hiLoTemp(
            weather.highTemp.toStringAsFixed(0), true, weather.isFahrenheit),
        const SizedBox(width: 20),
        hiLoTemp(
            weather.lowTemp.toStringAsFixed(0), false, weather.isFahrenheit)
      ])
    ]);
  }

  Widget weatherTitle(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeMedium,
        color: Colors.black,
        font: s_font_IBMPlexSans);
  }

  Widget updateTime(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeExtraSmall,
        color: Colors.black,
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget currentTemp(String text, bool isFahrenheit) {
    if (isFahrenheit) {
      text = text + ' °F';
    } else {
      text = text + ' °C';
    }
    return FormattedText(
        text: text,
        size: s_fontSizeExtraLarge * 1.5,
        color: Colors.black,
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }

  Widget hiLoTemp(String text, bool isHigh, bool isFahrenheit) {
    if (isFahrenheit) {
      text = text + ' °F';
    } else {
      text = text + ' °C';
    }
    if (isHigh) {
      text = 'H: ' + text;
    } else {
      text = 'L: ' + text;
    }
    return FormattedText(
      text: text,
      size: s_fontSizeMedLarge,
      color: Colors.black,
      font: s_font_IBMPlexSans,
    );
  }

  Widget toggleUnitsButton(double buttonWidth, double buttonHeight) {
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
            primary: Colors.black, fixedSize: Size(buttonWidth, buttonHeight)),
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

  Widget refreshButton(
      WeatherPackage weather, double buttonWidth, double buttonHeight) {
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
            primary: Colors.black, fixedSize: Size(buttonWidth, buttonHeight)),
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

  Widget meatWeatherConsideration(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeExtraSmall,
        color: Colors.black,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
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
              var url = "https://www.linkedin.com/in/cedriceicher/";
              if (!await launch(url)) throw 'Could not launch $url';
            }),
    );
  }
}
