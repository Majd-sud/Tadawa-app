

import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness
      .light, // Background color for light mode (use white or light grey)
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme.light(
    surface: Colors.white, // Light surface color for light mode
    primary: Colors.black, // Standard primary color for light mode
    secondary:
        Colors.black, // Secondary color, often a lighter shade or accent color
  ).copyWith(
      surface:
          Colors.white), // Scaffold background color (use white or light grey)
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade700,
  ).copyWith(),
);
