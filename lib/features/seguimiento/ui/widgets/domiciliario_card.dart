import 'package:flutter/material.dart';

import 'package:mocca_go/components/pedido_secciones.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Quién lleva el pedido. Mientras nadie lo toma: "Buscando domiciliario".
class DomiciliarioCard extends StatelessWidget {
  final Pedido pedido;

  const DomiciliarioCard({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final nombre = pedido.domiciliarioNombre;
    if (nombre != null) {
      return PersonaCard(
        nombre: nombre,
        calificacion: pedido.domiciliarioCalificacion,
        rol: 'Domiciliario',
      );
    }
    return const SurfaceCard(
      child: Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: AppColors.estadoPendiente, size: 22),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Buscando domiciliario...',
              style: TextStyle(fontSize: 15, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}
