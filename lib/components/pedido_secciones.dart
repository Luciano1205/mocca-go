import 'package:flutter/material.dart';

import 'package:mocca_go/components/estado_badge.dart';
import 'package:mocca_go/components/info_row.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

// Secciones del detalle de un pedido (15 · Detalle, 17 · Gestionar).

/// Persona con su calificación: "LG  Laura Gómez  ★ 4.9 · Cliente".
class PersonaCard extends StatelessWidget {
  final String nombre;
  final double? calificacion;
  final String rol;

  const PersonaCard({
    super.key,
    required this.nombre,
    this.calificacion,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    final estrellas = (calificacion == null || calificacion == 0)
        ? 'Sin calificaciones'
        : calificacion!.toStringAsFixed(1);
    return SurfaceCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.25),
            child: Text(
              iniciales(nombre),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text(
                      '$estrellas · $rol',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Zona, referencia, pago y nota.
class EntregaCard extends StatelessWidget {
  final Pedido pedido;

  const EntregaCard({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final pago = pedido.pago;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Titulo('Entrega'),
          InfoRow(label: 'Zona', value: pedido.zona),
          InfoRow(label: 'Referencia', value: pedido.referencia),
          if (pago != null) ..._filasPago(pago),
          if (pedido.nota != null) InfoRow(label: 'Nota', value: pedido.nota!),
        ],
      ),
    );
  }

  List<Widget> _filasPago(PagoPedido pago) {
    if (pago.metodo == MetodoPago.transferencia) {
      return [
        InfoRow(label: 'Pago', value: 'Transferencia · ${pago.entidadNombre ?? ''}'),
        if (pago.entidadDato != null) InfoRow(label: 'Destino', value: pago.entidadDato!),
      ];
    }
    if (pago.valorEntregado == null) {
      return const [InfoRow(label: 'Pago', value: 'Efectivo · Valor exacto')];
    }
    return [
      InfoRow(label: 'Pago', value: 'Efectivo · ${formatoPesos(pago.valorEntregado!)}'),
      InfoRow(label: 'Cambio', value: formatoPesos(pago.cambio)),
    ];
  }
}

/// Productos y total a cobrar.
class ProductosCard extends StatelessWidget {
  final Pedido pedido;
  final String etiquetaTotal;

  const ProductosCard({
    super.key,
    required this.pedido,
    this.etiquetaTotal = 'Total a cobrar',
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Titulo('Productos'),
          for (final item in pedido.items)
            InfoRow(
              label: '${item.cantidad} × ${item.nombre}',
              value: formatoPesos(item.subtotal),
            ),
          if (pedido.costoDomicilio > 0)
            InfoRow(label: 'Domicilio', value: formatoPesos(pedido.costoDomicilio)),
          const SizedBox(height: 4),
          InfoRow(
            label: etiquetaTotal,
            value: formatoPesos(pedido.total),
            destacado: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;

  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(texto, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
    );
  }
}

/// Encabezado del detalle: botón atrás, "Pedido #1045", estado y subtítulo.
class PedidoEncabezado extends StatelessWidget {
  final Pedido pedido;
  final String subtitulo;

  const PedidoEncabezado({super.key, required this.pedido, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.text,
          ),
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Pedido #${pedido.numero}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            EstadoBadge(estado: pedido.estado),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitulo, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
      ],
    );
  }
}
