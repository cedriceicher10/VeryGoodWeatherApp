import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verygoodweatherapp/styles.dart';
import 'formatted_text.dart';
//import 'weather_cubit.dart';

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
    const double buttonWidth = 158;
    const double buttonHeight = 40;
    const double spacing = 10;

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
          body: Center(
            child: Column(children: [
              const SizedBox(height: spacing),
              SizedBox(width: textFieldWidth, child: searchBar()),
              const SizedBox(height: spacing),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                myLocationButton(buttonWidth, buttonHeight),
                const SizedBox(width: spacing),
                searchButton(buttonWidth, buttonHeight)
              ]),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: signatureText('An App by Cedric Eicher'),
                ),
              )
            ]),
          ),
        ));
  }

  Widget searchBar() {
    return TextField(
      controller: _text,
      decoration: const InputDecoration(
        hintText: 'Ex: San Diego, CA',
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
          buttonText('My Location')
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
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(builder: (context) => const StartScreen()),
          //     (Route<dynamic> route) => false);
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
          buttonText('Search')
        ]));
  }

  // REFERENCE
  // body: BlocBuilder<CounterCubit, int>(
  //       builder: (context, count) => Center(child: Text('$count')),
  //     ),
  //     floatingActionButton: Column(
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: <Widget>[
  //         FloatingActionButton(
  //           child: const Icon(Icons.add),
  //           onPressed: () => context.read<CounterCubit>().increment(),
  //         ),
  //         const SizedBox(height: 4),
  //         FloatingActionButton(
  //           child: const Icon(Icons.remove),
  //           onPressed: () => context.read<CounterCubit>().decrement(),
  //         ),
  //       ],
  //     ),

  Widget weatherScreenTitle(String title) {
    return FormattedText(
        text: title,
        size: s_fontSizeMedLarge,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget buttonText(String title) {
    return FormattedText(
        text: title,
        size: s_fontSizeSmall,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget signatureText(String title) {
    return RichText(
      text: TextSpan(
          style: const TextStyle(
              color: Colors.black,
              fontFamily: s_font_IBMPlexSans,
              fontSize: s_fontSizeExtraSmall,
              fontWeight: FontWeight.bold),
          text: title,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              var url = "https://www.linkedin.com/in/cedriceicher/";
              if (!await launch(url)) throw 'Could not launch $url';
            }),
    );
  }
}
