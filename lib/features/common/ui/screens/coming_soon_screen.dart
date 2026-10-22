import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Pantalla para rutas que todavía no existen (por ejemplo las de registro
/// y recuperación mientras se construyen).
class ComingSoonScreen extends StatelessWidget {
  final String routeName;

  const ComingSoonScreen({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Próximamente\n$routeName',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
