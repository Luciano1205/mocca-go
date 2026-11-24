import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Respuesta predeterminada que el cliente toca (motivo, producto o
/// solución). Con [elegida] se marca, para los productos que van varios.
class OpcionChat extends StatelessWidget {
  final String texto;
  final bool elegida;
  final Function() onTap;

  const OpcionChat({super.key, required this.texto, this.elegida = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: elegida ? AppColors.primary.withValues(alpha: 0.18) : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: elegida ? AppColors.primary : AppColors.border, width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (elegida) ...[
                const Icon(Icons.check, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: elegida ? AppColors.primary : AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
