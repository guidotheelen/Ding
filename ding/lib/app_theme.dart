import 'package:flutter/material.dart';

class AppTheme {
  // ThemeData
  static ThemeData get theme => ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: primaryRed),
        useMaterial3: true,
      );

  // Colors
  static const Color primaryRed = Color(0xFFE53935);
  static const Color background = Color(0xFFF5F5F5);
  static const Color appBarBg = Color(0xFF263238);
  static const Color appBarText = Colors.white;
  static const Color settingLabel = Color(0xFF757575);
  static const Color settingValue = Color(0xFF263238);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color promoBg = Color(0xFF263238);
  static const Color promoText = Colors.white;
  static const Color promoRed = Color(0xFFE53935);
  static const Color switchHelp = Color(0xFF757575);
  static const Color buttonBg = Color(0xFFE53935);
  static const Color buttonBorder = Colors.transparent;
  static const Color buttonText = Colors.white;
  static const Color circleButtonBg = Color(0xFFECEFF1);
  static const Color circleButtonIcon = Color(0xFF263238);
  static const Color cardBg = Colors.white;
  static const Color darkCardBg = Color(0xFF37474F);

  // Font sizes
  static const double appBarFontSize = 28;
  static const double settingValueFontSize = 32;
  static const double settingLabelFontSize = 16;
  static const double switchFontSize = 32;
  static const double startButtonFontSize = 40;
  static const double promoFontSize = 18;

  // Font weights
  static const FontWeight bold = FontWeight.bold;
  static const FontWeight semiBold = FontWeight.w500;

  // Paddings
  static const EdgeInsets appBarPadding =
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 12);
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);
  static const EdgeInsets promoPadding =
      EdgeInsets.symmetric(vertical: 20, horizontal: 20);

  // Border radius
  static const double promoRadius = 16;
  static const double buttonRadius = 12;
  static const double cardRadius = 16;

  // Elevations
  static const double cardElevation = 2.0;
  static const double buttonElevation = 3.0;
}
