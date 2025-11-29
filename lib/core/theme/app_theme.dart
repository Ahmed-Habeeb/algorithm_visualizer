import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors_manager.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: ColorsManager.primaryColor,
        scaffoldBackgroundColor: ColorsManager.screenColorLight,
        colorScheme: const ColorScheme.light(
          primary: ColorsManager.primaryColor,
          secondary: ColorsManager.secondaryColor,
          surface: ColorsManager.cardColorLight,
          error: ColorsManager.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorsManager.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: ColorsManager.cardColorLight,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsManager.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: ColorsManager.primaryColor,
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: ColorsManager.primaryColor,
          inactiveTrackColor: ColorsManager.primaryColor.withOpacity(0.3),
          thumbColor: ColorsManager.primaryColor,
          overlayColor: ColorsManager.primaryColor.withOpacity(0.2),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: ColorsManager.primaryColorDark,
        scaffoldBackgroundColor: ColorsManager.screenColorDark,
        colorScheme: const ColorScheme.dark(
          primary: ColorsManager.primaryColorDark,
          secondary: ColorsManager.secondaryColor,
          surface: ColorsManager.cardColorDark,
          error: ColorsManager.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorsManager.cardColorDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: ColorsManager.cardColorDark,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsManager.primaryColorDark,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: ColorsManager.primaryColorDark,
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: ColorsManager.primaryColorDark,
          inactiveTrackColor: ColorsManager.primaryColorDark.withOpacity(0.3),
          thumbColor: ColorsManager.primaryColorDark,
          overlayColor: ColorsManager.primaryColorDark.withOpacity(0.2),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      );
}
