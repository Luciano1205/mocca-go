import 'package:flutter/material.dart';

import 'package:mocca_go/components/estrellas.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// Hoja inferior para calificar a la otra parte al entregar: 12 · Calificar
/// domiciliario (cliente) y 18 · Calificar cliente (domiciliario).
///
/// Devuelve las estrellas elegidas, o null si tocó "Ahora no".
class CalificarSheet extends StatefulWidget {
  final String titulo;
  final String pregunta;
  final String nombre;

  const CalificarSheet({
    super.key,
    required this.titulo,
    required this.pregunta,
    required this.nombre,
  });

  /// Abre la hoja y espera la respuesta.
  static Future<int?> mostrar(
    BuildContext context, {
    required String titulo,
    required String pregunta,
    required String nombre,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CalificarSheet(titulo: titulo, pregunta: pregunta, nombre: nombre),
    );
  }

  @override
  State<CalificarSheet> createState() => _CalificarSheetState();
}

class _CalificarSheetState extends State<CalificarSheet> {
  int _valor = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.pregunta,
              style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withValues(alpha: 0.25),
              child: Text(
                iniciales(widget.nombre),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Estrellas(valor: _valor, onChanged: (v) => setState(() => _valor = v)),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Enviar calificación',
              // Sin estrellas elegidas no hace nada.
              onPressed: () {
                if (_valor > 0) Navigator.pop(context, _valor);
              },
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Ahora no',
                style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
