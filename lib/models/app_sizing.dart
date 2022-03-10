import 'package:flutter/material.dart';

class AppSizing {
  BuildContext context;
  double textFieldWidth = 0; // 325
  double topButtonWidth = 0; // 158
  double topButtonHeight = 0; // 40
  double bottomButtonWidth = 0; // 138
  double bottomButtonHeight = 0; // 30
  double spacing = 0; // 10
  double weatherContainerWidth = 0; // 325
  double weatherContainerHeight = 0; // 405

  AppSizing(this.context) {
    textFieldWidth = getTextFieldWidth();
    topButtonWidth = getTopButtonWidth();
    topButtonHeight = getTopButtonHeight();
    bottomButtonWidth = getBottomButtonWidth();
    bottomButtonHeight = getBottomButtonHeight();
    spacing = getSpacing();
    weatherContainerWidth = getWeatherContainerWidth();
    weatherContainerHeight = getWeatherContainerHeight();
  }

  double getTextFieldWidth() {
    return MediaQuery.of(context).size.width * 0.85; // 325
  }

  double getTopButtonWidth() {
    return MediaQuery.of(context).size.width * 0.41; // 158
  }

  double getTopButtonHeight() {
    return MediaQuery.of(context).size.height * 0.05; // 40
  }

  double getBottomButtonWidth() {
    return MediaQuery.of(context).size.width * 0.35; // 138
  }

  double getBottomButtonHeight() {
    return getTopButtonHeight() / 2; // 30
  }

  double getSpacing() {
    return 10; // 10
  }

  double getWeatherContainerWidth() {
    return MediaQuery.of(context).size.width * 0.80; // 325
  }

  double getWeatherContainerHeight() {
    return MediaQuery.of(context).size.height * 0.60; // 405
  }
}
