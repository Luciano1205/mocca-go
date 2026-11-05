import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Fila "etiqueta ........ valor" de las tarjetas de detalle.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool destacado;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.destacado = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = destacado ? 17.0 : 15.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: size,
              fontWeight: destacado ? FontWeight.w600 : FontWeight.w400,
              color: destacado ? AppColors.text : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: size,
                fontWeight: destacado ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
