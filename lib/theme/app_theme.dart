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

  // Cores de Ação
  static const Color primaryFuelColor = Color(0xFF00796B);
  static const Color primaryFuelAccent = Color(0xFFFF1207);
  static const Color efficiencyGreen = Color(0xFF34A853);

  static const Color primaryDark = surfaceDark;
  static const Color secondaryDark = surfaceContainer;
  static const Color cardDark = surfaceCard;

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
      ),
    );
  }
}
