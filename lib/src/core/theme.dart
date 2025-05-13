import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColorLight: Colors.blue,
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF4CAF50),
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      canvasColor: Colors.white, // Color de fondo para Cards, Dialogs

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF2F2F7),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        // scrolledUnderElevation: 5,
        surfaceTintColor: Colors.blue,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 19,
          fontWeight: FontWeight.w600, // Peso de fuente de iOS
          fontFamily: '.SF Pro Text',
        ),
      ),

      cardTheme: CardTheme(
        elevation: 0, // Sin elevación
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 0.5), // Borde sutil
        ),
        color: Colors.white, // Fondo de las "tarjetas"
      ),

      // TextTheme: Estilo iOS (usando las propiedades de Cupertino si se desea)
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: Colors.black87, fontFamily: '.SF Pro Text'),
        titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.black87, fontFamily: '.SF Pro Text'),
        bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87, fontFamily: '.SF Pro Text'),
        bodySmall: TextStyle(fontSize: 14.0, color: Colors.black54, fontFamily: '.SF Pro Text'),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'), // Para botones
      ),

      // Switch: Cambiar el color activo
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CupertinoColors.activeGreen; // Verde de iOS
          }
          return Colors.grey.shade300; // Gris apagado
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CupertinoColors.activeGreen.withOpacity(0.5);
          }
          return Colors.grey.shade200; // Gris apagado
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue, // Color activo de iOS
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Sin animación de cambio
        elevation: 1,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontFamily: '.SF Pro Text'),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontFamily: '.SF Pro Text'),
      ),

      // ElevatedButton & TextButton: Estilo iOS
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
          foregroundColor: Colors.blue, // Azul para botones de texto
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
        ),
      ),

      // Diálogos: Estilo iOS
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),

      // Input Decoration (para campos de texto si los tuvieras)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CupertinoColors.systemGrey6, // Fondo de campo de texto iOS
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // Sin borde
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue, width: 2.0), // Borde azul al enfocar
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}