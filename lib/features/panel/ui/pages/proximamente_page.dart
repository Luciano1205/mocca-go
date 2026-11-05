import 'package:flutter/material.dart';

import 'package:mocca_go/components/estado_vacio.dart';

/// Pestaña que todavía no está construida.
class ProximamentePage extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData icono;

  const ProximamentePage({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.icono = Icons.hourglass_empty,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: textos.headlineMedium),
          if (subtitulo != null) ...[
            const SizedBox(height: 4),
            Text(subtitulo!, style: textos.bodyMedium),
          ],
          Expanded(
            child: Center(
              child: EstadoVacio(icono: icono, titulo: 'Próximamente'),
            ),
          ),
        ],
      ),
    );
  }
}
