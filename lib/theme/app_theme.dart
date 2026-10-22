import 'package:flutter/material.dart';

/// Paleta de Mocca Go! (variables "Mocca Go!" del prototipo en Figma).
class AppColors {
  static const Color background = Color(0xFF14100E);
  static const Color surface = Color(0xFF221A16);
  static const Color surface2 = Color(0xFF2E241F);
  static const Color border = Color(0xFF3A2F28);
  static const Color primary = Color(0xFFF08A3C);
  static const Color onPrimary = Color(0xFF14100E);
  static const Color text = Color(0xFFF5EDE3);
  static const Color textMuted = Color(0xFFA8998C);
  static const Color error = Color(0xFFFF6B5B);
  static const Color success = Color(0xFFB8E07A);

  // Estados del pedido
  static const Color estadoPendiente = Color(0xFFE8B04B);
  static const Color estadoAceptado = Color(0xFF7FB2F0);
  static const Color estadoEnCamino = Color(0xFFF08A3C);
  static const Color estadoEntregado = Color(0xFFB8E07A);
  static const Color estadoCancelado = Color(0xFFFF6B5B);
}

/// Tema oscuro de la app con la fuente Inter.
ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.error,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.text),
      bodyMedium: TextStyle(fontSize: 15, color: AppColors.textMuted),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: true,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
    ),
  );
}
