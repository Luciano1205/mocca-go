import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Botón del prototipo (componente "Button"): Primario naranja o
/// Secundario con borde. Muestra un indicador mientras carga.
class PrimaryButton extends StatelessWidget {
  final String label;
  final Function() onPressed;
  final bool isLoading;
  final bool isSecondary;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isSecondary ? AppColors.text : AppColors.onPrimary,
            ),
          )
        : Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: isSecondary
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: shape,
              ),
              onPressed: isLoading ? null : () => onPressed(),
              child: child,
            )
          : FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: AppColors.primary,
                shape: shape,
              ),
              onPressed: isLoading ? null : () => onPressed(),
              child: child,
            ),
    );
  }
}
