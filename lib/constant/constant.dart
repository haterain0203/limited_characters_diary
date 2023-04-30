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

  static const googleFormUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSd0PX7sqCV1MU6BW740N9TVnyn-NblQWBlureYeuFfFZI7LhQ/viewform?usp=sf_link';

  static const privacyPolicyUrl = 'https://lizard-dash-dfc.notion.site/839460163cc2469c9f7afc17f0f30093';

  static const termsOfServiceUrl = 'https://lizard-dash-dfc.notion.site/0c5ff092a6da46dfbaa8c8f6efa8e80c';
}
