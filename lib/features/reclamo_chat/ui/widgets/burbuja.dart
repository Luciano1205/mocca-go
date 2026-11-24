import 'package:flutter/material.dart';

import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_state.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Burbuja del chat: el bot a la izquierda (oscura) y el cliente a la
/// derecha (naranja), como en las pantallas 21 a 22 del prototipo.
class Burbuja extends StatelessWidget {
  final MensajeChat mensaje;

  const Burbuja({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final bot = mensaje.delBot;
    const radio = Radius.circular(18);
    return Align(
      alignment: bot ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bot ? AppColors.surface : AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: radio,
              topRight: radio,
              bottomLeft: bot ? const Radius.circular(4) : radio,
              bottomRight: bot ? radio : const Radius.circular(4),
            ),
          ),
          child: Text(
            mensaje.texto,
            style: TextStyle(
              fontSize: 15,
              color: bot ? AppColors.text : AppColors.onPrimary,
              fontWeight: bot ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
