import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Type system: Space Grotesk carries headers (it has that slightly
/// mechanical, stamped-letter quality), Inter carries body copy, and
/// IBM Plex Mono renders every number — streaks, percentages, scores —
/// so stats always read like a scoreboard, not a sentence.
class AppTheme {
  AppTheme._();

  static TextTheme get _textTheme {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.1,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.15,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.ink,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.ink,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.ink, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.inkSoft, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.inkSoft),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
    );
  }

  /// Use for any numeric readout: streaks, %, scores, timers, counts.
  static TextStyle statNumber({double size = 28, Color? color}) => GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.ink,
        letterSpacing: -0.5,
      );

  static TextStyle statLabel({Color? color}) => GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: color ?? AppColors.inkSoft,
      );

  static ThemeData get light {
    final textTheme = _textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paper,
      canvasColor: AppColors.paper,
      colorScheme: const ColorScheme.light(
        primary: AppColors.ink,
        onPrimary: AppColors.paper,
        secondary: AppColors.highlight,
        onSecondary: AppColors.ink,
        surface: AppColors.paperDim,
        onSurface: AppColors.ink,
        error: AppColors.coral,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.paperLine, thickness: 1, space: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.paper,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.ink, width: 1.4),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperDim,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.4),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.inkSoft.withValues(alpha: 0.6)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.paperDim,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paperDim,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.inter(color: AppColors.paper),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
