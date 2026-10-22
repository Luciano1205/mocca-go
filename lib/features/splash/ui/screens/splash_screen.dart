import 'package:flutter/material.dart';

import 'package:mocca_go/components/app_logo.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// 01 · Splash. Por ahora solo muestra la marca; la detección de sesión
/// y la redirección por rol se agregan con la capa de autenticación.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 96),
            SizedBox(height: 16),
            Text(
              'Mocca Go!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tu café, donde estés en el campus',
              style: TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
