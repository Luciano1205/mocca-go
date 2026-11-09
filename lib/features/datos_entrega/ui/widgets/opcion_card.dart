import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Tarjeta seleccionable de Datos de entrega: zona, billete o entidad.
/// Elegida lleva borde naranja; deshabilitada se ve apagada.
class OpcionCard extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData? icono;
  final bool elegida;
  final bool habilitada;
  final Widget? trailing;
  final Function() onTap;

  const OpcionCard({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.icono,
    this.elegida = false,
    this.habilitada = true,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorTexto = habilitada ? AppColors.text : AppColors.textMuted;
    return Opacity(
      opacity: habilitada ? 1 : 0.5,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: habilitada ? () => onTap() : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: elegida ? AppColors.primary : AppColors.border,
                width: elegida ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (icono != null) ...[
                  Icon(icono, color: elegida ? AppColors.primary : AppColors.textMuted),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorTexto,
                        ),
                      ),
                      if (subtitulo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitulo!,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  Icon(
                    elegida ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: elegida ? AppColors.primary : AppColors.border,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
