import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColorLight: Colors.blue,
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF4CAF50),
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      canvasColor: Colors.white,

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF2F2F7),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.blue,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Text',
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
        color: Colors.white,
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: Colors.black87, fontFamily: '.SF Pro Text'),
        titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.black87, fontFamily: '.SF Pro Text'),
        bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87, fontFamily: '.SF Pro Text'),
        bodySmall: TextStyle(fontSize: 14.0, color: Colors.black54, fontFamily: '.SF Pro Text'),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CupertinoColors.activeGreen;
          }
          return Colors.grey.shade300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CupertinoColors.activeGreen.withOpacity(0.5);
          }
          return Colors.grey.shade200;
        }),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 1,
        selectedLabelStyle: TextStyle(fontSize: 10, fontFamily: '.SF Pro Text'),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontFamily: '.SF Pro Text'),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CupertinoColors.systemGrey6,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF4CAF50),
      primaryColorLight: Colors.blue,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      canvasColor: const Color(0xFF2C2C2E),

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.blue,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Text',
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade700, width: 0.5),
        ),
        color: const Color(0xFF2C2C2E),
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: '.SF Pro Text'),
        titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: '.SF Pro Text'),
        bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white70, fontFamily: '.SF Pro Text'),
        bodySmall: TextStyle(fontSize: 14.0, color: Colors.white54, fontFamily: '.SF Pro Text'),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontFamily: '.SF Pro Text'),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CupertinoColors.activeGreen;
          }
          return Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CupertinoColors.activeGreen.withOpacity(0.5);
          }
          return Colors.grey.shade700;
        }),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2C2C2E),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 1,
        selectedLabelStyle: TextStyle(fontSize: 10, fontFamily: '.SF Pro Text'),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontFamily: '.SF Pro Text'),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue[300],
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF2C2C2E),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3A3A3C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}