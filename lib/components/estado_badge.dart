import 'package:flutter/material.dart';

import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Etiqueta del estado del pedido (componente "Badge/Estado").
class EstadoBadge extends StatelessWidget {
  final EstadoPedido estado;

  const EstadoBadge({super.key, required this.estado});

  static Color colorDe(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return AppColors.estadoPendiente;
      case EstadoPedido.aceptado:
        return AppColors.estadoAceptado;
      case EstadoPedido.enCamino:
        return AppColors.estadoEnCamino;
      case EstadoPedido.entregado:
        return AppColors.estadoEntregado;
      case EstadoPedido.cancelado:
        return AppColors.estadoCancelado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorDe(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            estado.etiqueta,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
