import 'package:flutter/material.dart';

// ============================================================
// XCASH HT — Palèt koulè rich (gradyan vèt → lò)
// Nouvo redesign: pi pwofesyonèl, background ki pa tou blan
// ============================================================

class XcColors {
  // Koulè prensipal vèt
  static const Color deepGreen = Color(0xFF052E22); // fonse
  static const Color forest = Color(0xFF064E3B); // vèt fèy
  static const Color emerald = Color(0xFF059669); // vèt emerald
  static const Color mint = Color(0xFF34D399); // vèt klere
  static const Color paleMint = Color(0xFFA7F3D0); // vèt pal

  // Aksan lò / anbre
  static const Color gold = Color(0xFFF59E0B);
  static const Color amber = Color(0xFFFBBF24);
  static const Color goldSoft = Color(0xFFFDE68A);
  static const Color goldWarm = Color(0xFFB45309);

  // Background ki pa blan — yon seri vèt-lò trè fèb
  static const Color bgTop = Color(0xFFF2FBF5); // prèske vèt
  static const Color bgBottom = Color(0xFFFBF7EC); // prèske lò

  // Sifas / kad
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCream = Color(0xFFFFFBF0);

  // Nwa / gri
  static const Color ink = Color(0xFF0F172A);
  static const Color slate = Color(0xFF475569);
  static const Color muted = Color(0xFF94A3B8);
  static const Color line = Color(0xFFE7EFE9);
}

// Gradyan siyati XCASH HT (vèt fonse → emerald → touche lò)
const LinearGradient kBrandGradient = LinearGradient(
  colors: [Color(0xFF052E22), Color(0xFF064E3B), Color(0xFF059669)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Gradyan fèb pou background paj (pa tou blan)
const LinearGradient kPageGradient = LinearGradient(
  colors: [Color(0xFFF2FBF5), Color(0xFFFBF7EC)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Gradyan aksan lò (pou bouton sekondè / veri)
const LinearGradient kGoldGradient = LinearGradient(
  colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

ThemeData buildXcashTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: XcColors.emerald,
    scaffoldBackgroundColor: XcColors.bgTop,
    colorScheme: ColorScheme.fromSeed(
      seedColor: XcColors.emerald,
      primary: XcColors.emerald,
      secondary: XcColors.gold,
      surface: XcColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF052E22),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: XcColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: XcColors.line, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: XcColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: XcColors.forest,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: XcColors.emerald, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: XcColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: XcColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: XcColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: XcColors.emerald, width: 2),
      ),
      labelStyle: const TextStyle(color: XcColors.slate, fontSize: 14),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: XcColors.forest,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: XcColors.emerald,
      unselectedItemColor: XcColors.muted,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
      type: BottomNavigationBarType.fixed,
    ),
  );
}
