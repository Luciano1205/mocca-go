import 'package:flutter/material.dart';

import 'package:mocca_go/components/estado_badge.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// Tarjeta de un pedido del cliente (10 · Mis pedidos): número, estado,
/// productos, zona y total.
class MiPedidoCard extends StatelessWidget {
  final Pedido pedido;
  final Function() onTap;

  const MiPedidoCard({super.key, required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pedido #${pedido.numero}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              EstadoBadge(estado: pedido.estado),
            ],
          ),
          const SizedBox(height: 8),
          Text(pedido.resumenItems, style: const TextStyle(fontSize: 15, color: AppColors.text)),
          const SizedBox(height: 4),
          Text(
            '${pedido.zona} · ${haceCuanto(pedido.creadoEn)}',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  pedido.domiciliarioNombre == null
                      ? (pedido.estado.activo ? 'Buscando domiciliario' : '')
                      : 'Domiciliario: ${nombreCorto(pedido.domiciliarioNombre!)}',
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
