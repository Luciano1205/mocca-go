import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Mensaje centrado con ícono: listas vacías, pedido ya tomado, entrega completada.
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? mensaje;
  final Color color;

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.mensaje,
    this.color = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 34, color: color),
          ),
          const SizedBox(height: 18),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 8),
            Text(
              mensaje!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
