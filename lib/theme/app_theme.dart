import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores de Superficie e Ação (MANTIDAS)
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceContainer = Color(0xFF1F1F1F);
  static const Color surfaceCard = Color(0xFF252525);

  static const Color errorRed = Color(0xFFFF5252);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFAAAAAA);
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textDarkGrey = Color(0xFF565656);
  static const Color textLightGrey = Color(0xFFd3d3d3);

  // Cores de Ação
  static const Color primaryRadioColor = Color.fromARGB(255, 0, 0, 0);
  static const Color backgroundColorLight = Color.fromARGB(255, 250, 250, 250);
  static const Color backgroundColorDark = Color.fromARGB(255, 18, 18, 18);
  static const Color primaryFuelColor = Color.fromARGB(255, 1, 163, 144);
  static const Color primaryFuelAccent = Color(0xFFFF1207);
  static const Color efficiencyGreen = Color(0xFF34A853);

  static const Color surfaceLight = Color(0xFFF7F7F7);
  static const Color surfaceLightContainer = Color(0xFFFFFFFF);

  static const Color primaryDark = surfaceDark;
  static const Color secondaryDark = surfaceContainer;
  static const Color cardDark = surfaceCard;

  static const Color primaryLight = primaryFuelColor;
  static const Color secondaryLight = surfaceLight;
  static const Color cardLight = surfaceLightContainer;

  static const LinearGradient fuelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryFuelAccent, Color(0xFF004D40)],
  );

  static ThemeData darkTheme([String languageCode = 'en']) {
    final isRtlLanguage = languageCode == 'en' || languageCode == 'pt';
    final baseTextTheme = isRtlLanguage
        ? GoogleFonts.vazirmatnTextTheme(ThemeData.dark().textTheme)
        : GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);

    final baseAppBarTextStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textLight,
          )
        : GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textLight,
          );
    final baseButtonTextStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w600)
        : GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: primaryFuelColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryFuelColor,
        brightness: Brightness.dark,
        primary: primaryFuelColor,
        onPrimary: textLight,
        secondary: primaryFuelAccent,
        onSecondary: surfaceDark,
        surface: textLight,
        surfaceContainerHighest: surfaceContainer,
        error: errorRed,
        onError: textLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceContainer,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: baseAppBarTextStyle,
        iconTheme: const IconThemeData(color: textLight),
        actionsIconTheme: const IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.grey.withOpacity(0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryFuelColor,
          foregroundColor: textLight,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: baseButtonTextStyle,
        ),
      ),
      textTheme: baseTextTheme,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryFuelColor, width: 2),
        ),
        labelStyle: TextStyle(color: textGrey),
        hintStyle: TextStyle(color: textGrey),
        filled: true,
        fillColor: surfaceContainer,
        floatingLabelStyle: const TextStyle(color: textLight),
      ),
    );
  }
  static ThemeData lightTheme([String languageCode = 'en']) {
    final isRtlLanguage = languageCode == 'en' || languageCode == 'pt';
    final baseTextTheme = isRtlLanguage
        ? GoogleFonts.vazirmatnTextTheme(ThemeData.light().textTheme)
        : GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme);

    final baseAppBarTextStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textDark,
          )
        : GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textDark,
          );
    final baseButtonTextStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w600)
        : GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: primaryLight,
      primaryColor: primaryFuelColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryFuelColor,
        brightness: Brightness.light,
        primary: primaryFuelColor,
        onPrimary: textLight,
        secondary: primaryFuelAccent,
        onSecondary: textLight,
        surface: textDark,
        surfaceContainerHighest: surfaceLightContainer,
        error: errorRed,
        onError: textLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: secondaryLight,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: baseAppBarTextStyle,
        iconTheme: const IconThemeData(color: textDark),
        actionsIconTheme: const IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.grey.withOpacity(0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryFuelColor,
          foregroundColor: textLight,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: baseButtonTextStyle,
        ),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textGrey.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textGrey.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryFuelColor, width: 2),
        ),
        labelStyle: TextStyle(color: textGrey),
        hintStyle: TextStyle(color: textGrey),
        filled: true,
        fillColor: cardLight,
        floatingLabelStyle: const TextStyle(color: textDark),
      ),
    );
  }
}
