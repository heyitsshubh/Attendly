import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Black & Red design system for Attendly.
class AppTheme {
  // ── Brand Colors ─────────────────────────────────────────────────────────
  static const Color primaryRed    = Color(0xFFDC2626); // Crimson Red
  static const Color primaryRedDeep = Color(0xFF991B1B); // Deep Red
  static const Color accentRed     = Color(0xFFEF4444); // Bright Red (hover)

  static const Color success  = Color(0xFF22C55E); // Green
  static const Color warning  = Color(0xFFF59E0B); // Amber
  static const Color error    = Color(0xFFEF4444); // Red
  static const Color info     = Color(0xFF60A5FA); // Blue

  // ── Dark Surfaces (primary theme) ─────────────────────────────────────────
  static const Color darkBg       = Color(0xFF0A0A0A); // near-black
  static const Color darkSurface  = Color(0xFF141414);
  static const Color darkCard     = Color(0xFF1C1C1C);
  static const Color darkCard2    = Color(0xFF242424);
  static const Color darkBorder   = Color(0xFF2E2E2E);
  static const Color darkText     = Color(0xFFF5F5F5);
  static const Color darkSubtext  = Color(0xFF9CA3AF);

  // ── Light Surfaces ────────────────────────────────────────────────────────
  static const Color lightBg      = Color(0xFFF9F9F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard    = Color(0xFFFFFFFF);
  static const Color lightBorder  = Color(0xFFE5E5E5);
  static const Color lightText    = Color(0xFF0A0A0A);
  static const Color lightSubtext = Color(0xFF6B7280);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, primaryRedDeep],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1C1C), Color(0xFF141414)],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // ── Text Theme ────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color base) {
    return GoogleFonts.outfitTextTheme().copyWith(
      displayLarge:  GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: base, letterSpacing: -1),
      displayMedium: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: base, letterSpacing: -0.5),
      headlineLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: base),
      headlineMedium:GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: base),
      titleLarge:    GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: base),
      titleMedium:   GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: base),
      bodyLarge:     GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: base),
      bodyMedium:    GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400, color: base),
      bodySmall:     GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400, color: base.withOpacity(0.6)),
      labelLarge:    GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: base, letterSpacing: 0.5),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final cs = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryRed,
      onPrimary: Colors.white,
      secondary: accentRed,
      onSecondary: Colors.white,
      surface: darkSurface,
      onSurface: darkText,
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: darkBg,
      textTheme: _buildTextTheme(darkText),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: darkText),
        iconTheme: const IconThemeData(color: darkText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryRed,
          side: const BorderSide(color: primaryRed, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRed,
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryRed, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.outfit(color: darkSubtext),
        hintStyle: GoogleFonts.outfit(color: darkSubtext),
        prefixIconColor: darkSubtext,
        suffixIconColor: darkSubtext,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryRed.withOpacity(0.1),
        labelStyle: GoogleFonts.outfit(color: primaryRed, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard2,
        contentTextStyle: GoogleFonts.outfit(color: darkText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: darkText),
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final cs = ColorScheme(
      brightness: Brightness.light,
      primary: primaryRed,
      onPrimary: Colors.white,
      secondary: primaryRedDeep,
      onSecondary: Colors.white,
      surface: lightSurface,
      onSurface: lightText,
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: lightBg,
      textTheme: _buildTextTheme(lightText),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: lightText),
        iconTheme: const IconThemeData(color: lightText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryRed,
          side: const BorderSide(color: primaryRed, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRed,
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryRed, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.outfit(color: lightSubtext),
        hintStyle: GoogleFonts.outfit(color: lightSubtext),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryRed.withOpacity(0.08),
        labelStyle: GoogleFonts.outfit(color: primaryRed, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightText,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: lightText),
      ),
    );
  }
}
