import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  static const cream = Color(0xFFFDF9F3);
  static const ink = Color(0xFF1B1410);
  static const rose = Color(0xFFE55A7E);
  static const roseDeep = Color(0xFFC93F66);
  static const gold = Color(0xFFD4AF37);
  static const goldSoft = Color(0xFFE9D28A);
  static const muted = Color(0xFF6B5A4A);
  static const cardLight = Color(0xCCFFFFFF);
  static const cardDark = Color(0xCC241A18);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppPalette.cream,
      colorScheme: const ColorScheme.light(
        primary: AppPalette.rose,
        secondary: AppPalette.gold,
        surface: AppPalette.cream,
      ),
      textTheme: _textTheme(base.textTheme, AppPalette.ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      iconTheme: const IconThemeData(color: AppPalette.ink),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF120B13),
      colorScheme: const ColorScheme.dark(
        primary: AppPalette.rose,
        secondary: AppPalette.goldSoft,
        surface: Color(0xFF120B13),
      ),
      textTheme: _textTheme(base.textTheme, const Color(0xFFF7ECDC)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      iconTheme: const IconThemeData(color: Color(0xFFF7ECDC)),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color color) {
    final body = GoogleFonts.interTextTheme(base.apply(bodyColor: color, displayColor: color));
    return body.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(textStyle: body.displayLarge, color: color),
      displayMedium: GoogleFonts.playfairDisplay(textStyle: body.displayMedium, color: color),
      displaySmall: GoogleFonts.playfairDisplay(textStyle: body.displaySmall, color: color),
      headlineLarge: GoogleFonts.playfairDisplay(textStyle: body.headlineLarge, color: color),
      headlineMedium: GoogleFonts.playfairDisplay(textStyle: body.headlineMedium, color: color),
      headlineSmall: GoogleFonts.playfairDisplay(textStyle: body.headlineSmall, color: color),
      titleLarge: GoogleFonts.playfairDisplay(textStyle: body.titleLarge, color: color),
    );
  }

  /// "Great Vibes" cursive script for the gold accent labels.
  static TextStyle script({double size = 32, Color color = AppPalette.gold}) =>
      GoogleFonts.greatVibes(fontSize: size, color: color, height: 1.1);

  /// "Cormorant Garamond" elegant serif used in some cards.
  static TextStyle serif({
    double size = 18,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.cormorantGaramond(fontSize: size, color: color, fontWeight: weight, height: 1.4);
}
