import 'package:flutter/material.dart';
import 'package:verygoodweatherapp/utils/styles.dart' as styles;

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
  double nextDaysWeatherContainerHeight = 0;
  double fontSizeExtraSmall = 0;
  double fontSizeSmaller = 0;
  double fontSizeSmall = 0;
  double fontSizeMedium = 0;
  double fontSizeMedLarge = 0;
  double fontSizeLarge = 0;
  double fontSizeExtraLarge = 0;
  double signatureBoxHeight = 0;
  double signatureBoxHeightStart = 0;

  AppSizing(this.context) {
    textFieldWidth = getTextFieldWidth();
    topButtonWidth = getTopButtonWidth();
    topButtonHeight = getTopButtonHeight();
    bottomButtonWidth = getBottomButtonWidth();
    bottomButtonHeight = getBottomButtonHeight();
    spacing = getSpacing();
    weatherContainerWidth = getWeatherContainerWidth();
    weatherContainerHeight = getWeatherContainerHeight();
    nextDaysWeatherContainerHeight = getNextDaysWeatherContainerHeight();
    fontSizeExtraSmall = getFontSizeExtraSmall();
    fontSizeSmaller = getFontSizeSmaller();
    fontSizeSmall = getFontSizeSmall();
    fontSizeMedium = getFontSizeMedium();
    fontSizeMedLarge = getFontSizeMedLarge();
    fontSizeLarge = getFontSizeLarge();
    fontSizeExtraLarge = getFontSizeExtraLarge();
    signatureBoxHeight = getSignatureBoxHeight();
    signatureBoxHeightStart = getSignatureBoxHeightStart();
  }

  // Container sizes
  double getSignatureBoxHeight() {
    double totalWidgetHeight = 20 +
        (getSpacing() * 6) +
        getTopButtonHeight() +
        getWeatherContainerHeight() +
        getNextDaysWeatherContainerHeight() +
        getBottomButtonHeight();
    if (MediaQuery.of(context).size.height > totalWidgetHeight) {
      return (MediaQuery.of(context).size.height - totalWidgetHeight) / 2;
    } else {
      return MediaQuery.of(context).size.height * 0.10;
    }
  }

  double getSignatureBoxHeightStart() {
    double totalWidgetHeight = 20 + (getSpacing() * 2) + getTopButtonHeight();
    return (MediaQuery.of(context).size.height) / 3;
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
    return MediaQuery.of(context).size.height * 0.55; // 405
  }

  double getNextDaysWeatherContainerHeight() {
    return MediaQuery.of(context).size.height * 0.15;
  }

  // Text sizes
  double reductionFactor = 0.65;

  double getFontSizeExtraSmall() {
    if ((MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) <
        550 * 350) {
      return styles.fontSizeExtraSmall * reductionFactor;
    }
    return styles.fontSizeExtraSmall;
  }

  double getFontSizeSmaller() {
    if ((MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) <
        550 * 350) {
      return styles.fontSizeSmaller * reductionFactor;
    }
    return styles.fontSizeSmaller;
  }

  double getFontSizeSmall() {
    if ((MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) <
        550 * 350) {
      return styles.fontSizeSmall * reductionFactor;
    }
    return styles.fontSizeSmall;
  }

  double getFontSizeMedium() {
    if ((MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) <
        550 * 350) {
      return styles.fontSizeMedium * reductionFactor;
    }
    return styles.fontSizeMedium;
  }

  double getFontSizeMedLarge() {
    if ((MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) <
        550 * 350) {
      return styles.fontSizeMedLarge * reductionFactor;
    }
    return styles.fontSizeMedLarge;
  }

  double getFontSizeLarge() {
    if ((MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) <
        550 * 350) {
      return styles.fontSizeLarge * reductionFactor;
    }
    return styles.fontSizeLarge;
  }

  double getFontSizeExtraLarge() {
    if ((MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) <
        550 * 350) {
      return styles.fontSizeExtraLarge * reductionFactor;
    }
    return styles.fontSizeExtraLarge;
  }
}
