import 'package:flutter/material.dart';

class AppTheme {
  // ThemeData
  static ThemeData get theme => ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: primaryRed),
        useMaterial3: true,
      );

  // Colors
  static const Color primaryRed = Colors.red;
  static const Color background = Colors.white;
  static const Color appBarBg = Colors.black;
  static const Color appBarText = Colors.red;
  static const Color settingLabel = Colors.black;
  static const Color settingValue = Colors.black;
  static const Color divider = Colors.black12;
  static const Color promoBg = Colors.black;
  static const Color promoText = Colors.white;
  static const Color promoRed = Colors.red;
  static const Color switchHelp = Colors.black54;
  static const Color buttonBorder = Colors.red;
  static const Color buttonText = Colors.black;
  static const Color circleButtonBg = Color(0xFFF1F1F1);

  // Font sizes
  static const double appBarFontSize = 32;
  static const double settingValueFontSize = 40;
  static const double settingLabelFontSize = 18;
  static const double switchFontSize = 40;
  static const double startButtonFontSize = 28;
  static const double promoFontSize = 20;
  static const double promoDownloadFontSize = 18;

  // Font weights
  static const FontWeight bold = FontWeight.bold;
  static const FontWeight semiBold = FontWeight.w500;

  // Paddings
  static const EdgeInsets appBarPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12);
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 24.0);
  static const EdgeInsets promoPadding =
      EdgeInsets.symmetric(vertical: 24, horizontal: 20);

  // Border radius
  static const double promoRadius = 40;
  static const double buttonRadius = 40;
}
