import 'package:flutter/material.dart';

class Constant {
  static const limitedCharactersNumber = 16;

  static const MaterialColor colorSwatch =
      MaterialColor(_colorSwatchPrimaryValue, <int, Color>{
    50: Color(0xFFEDF6FC),
    100: Color(0xFFD2E9F8),
    200: Color(0xFFB5DAF3),
    300: Color(0xFF97CBEE),
    400: Color(0xFF80C0EA),
    500: Color(_colorSwatchPrimaryValue),
    600: Color(0xFF62AEE3),
    700: Color(0xFF57A5DF),
    800: Color(0xFF4D9DDB),
    900: Color(0xFF3C8DD5),
  });
  static const int _colorSwatchPrimaryValue = 0xFF6AB5E6;

  static const accentColor = Color(0xFFF5E07E);
}
