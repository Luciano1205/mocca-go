import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Aviso dentro del formulario: verde de éxito ("¡Cuenta creada
/// exitosamente!", 02e y 02h) o rojo de error.
class MessageBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isError;

  const MessageBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.success;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 13, color: AppColors.text),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
