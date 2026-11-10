import 'package:flutter/material.dart';

import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// Línea de tiempo del cliente (11 · Seguimiento): Pedido recibido →
/// Aceptado → En camino → Entregado, con la hora de cada paso.
class LineaTiempo extends StatelessWidget {
  final Pedido pedido;

  const LineaTiempo({super.key, required this.pedido});

  static const _pasos = [
    EstadoPedido.pendiente,
    EstadoPedido.aceptado,
    EstadoPedido.enCamino,
    EstadoPedido.entregado,
  ];

  static String _texto(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return 'Pedido recibido';
      case EstadoPedido.aceptado:
        return 'Domiciliario asignado';
      case EstadoPedido.enCamino:
        return 'En camino';
      case EstadoPedido.entregado:
        return 'Entregado';
      case EstadoPedido.cancelado:
        return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final actual = _pasos.indexOf(pedido.estado);
    return SurfaceCard(
      child: Column(
        children: [
          for (var i = 0; i < _pasos.length; i++)
            _Paso(
              texto: _texto(_pasos[i]),
              hecho: i <= actual,
              actual: i == actual && pedido.estado != EstadoPedido.entregado,
              fecha: pedido.historial[_pasos[i]],
              ultimo: i == _pasos.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  final String texto;
  final bool hecho;
  final bool actual;
  final DateTime? fecha;
  final bool ultimo;

  const _Paso({
    required this.texto,
    required this.hecho,
    required this.actual,
    required this.fecha,
    required this.ultimo,
  });

  @override
  Widget build(BuildContext context) {
    final color = hecho ? AppColors.primary : AppColors.border;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              actual
                  ? Icons.radio_button_checked
                  : (hecho ? Icons.check_circle : Icons.radio_button_unchecked),
              color: color,
              size: 22,
            ),
            if (!ultimo) Container(width: 2, height: 22, color: color),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 15,
                fontWeight: hecho ? FontWeight.w600 : FontWeight.w400,
                color: hecho ? AppColors.text : AppColors.textMuted,
              ),
            ),
          ),
        ),
        if (hecho && fecha != null)
          Text(
            formatoHora(fecha!),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
      ],
    );
  }
}
