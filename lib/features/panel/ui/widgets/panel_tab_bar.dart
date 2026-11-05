import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Barra inferior de los paneles (componentes "TabBar/Cliente" y
/// "TabBar/Proveedor").
class PanelTabBar extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final Function(int) onTap;

  const PanelTabBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
