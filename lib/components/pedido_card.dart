import 'package:flutter/material.dart';

import 'package:mocca_go/components/estado_badge.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// Tarjeta de un pedido en las listas del domiciliario (14 · Pedidos
/// pendientes, 16 · Mis entregas). En el feed muestra cuánto lleva
/// esperando; en Mis entregas, el estado.
class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final Function() onTap;
  final bool mostrarEstado;

  const PedidoCard({
    super.key,
    required this.pedido,
    required this.onTap,
    this.mostrarEstado = false,
  });

  @override
  Widget build(BuildContext context) {
    final metodo = pedido.pago?.metodo == MetodoPago.transferencia
        ? 'Transferencia'
        : 'Efectivo';
    return SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pedido.zona,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (mostrarEstado)
                EstadoBadge(estado: pedido.estado)
              else
                _Espera(texto: haceCuanto(pedido.creadoEn)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pedido.referencia,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Text(
            pedido.resumenItems,
            style: const TextStyle(fontSize: 15, color: AppColors.text),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  mostrarEstado
                      ? 'Pedido #${pedido.numero} · ${nombreCorto(pedido.clienteNombre)}'
                      : '${nombreCorto(pedido.clienteNombre)} · $metodo',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
              Text(
                formatoPesos(pedido.total),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _Espera extends StatelessWidget {
  final String texto;

  const _Espera({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.estadoPendiente.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.estadoPendiente,
        ),
      ),
    );
  }
}
