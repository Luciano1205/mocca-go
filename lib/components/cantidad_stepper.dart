import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Contador "−  2  +" del menú y del carrito (componente "Stepper").
class CantidadStepper extends StatelessWidget {
  final int cantidad;
  final Function() onRestar;
  final Function() onSumar;

  const CantidadStepper({
    super.key,
    required this.cantidad,
    required this.onRestar,
    required this.onSumar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Boton(icono: Icons.remove, tooltip: 'Quitar uno', onTap: onRestar),
          SizedBox(
            width: 28,
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          _Boton(icono: Icons.add, tooltip: 'Agregar uno', onTap: onSumar),
        ],
      ),
    );
  }
}

class _Boton extends StatelessWidget {
  final IconData icono;
  final String tooltip;
  final Function() onTap;

  const _Boton({required this.icono, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      color: AppColors.primary,
      icon: Icon(icono),
      onPressed: () => onTap(),
    );
  }
}
