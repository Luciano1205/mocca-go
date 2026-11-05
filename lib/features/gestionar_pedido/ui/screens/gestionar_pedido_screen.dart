import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/pedido_secciones.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_bloc.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_event.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_state.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// 17 · Gestionar (Aceptado), 17b · En camino y 17c · Entrega completada.
/// Un solo botón avanza el estado.
class GestionarPedidoScreen extends StatelessWidget {
  const GestionarPedidoScreen({super.key});

  String _subtitulo(Pedido pedido) {
    final fecha = pedido.historial[pedido.estado];
    final hora = fecha == null ? '' : ' a las ${formatoHora(fecha)}';
    switch (pedido.estado) {
      case EstadoPedido.aceptado:
        return 'Lo tomaste$hora';
      case EstadoPedido.enCamino:
        return 'Saliste a entregar$hora';
      case EstadoPedido.entregado:
        return 'Entregado$hora';
      case EstadoPedido.pendiente:
      case EstadoPedido.cancelado:
        return pedido.estado.etiqueta;
    }
  }

  /// Texto del botón según lo que sigue; null si ya no avanza.
  String? _accion(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.aceptado:
        return 'Salir a entregar';
      case EstadoPedido.enCamino:
        return 'Marcar como entregado';
      case EstadoPedido.pendiente:
      case EstadoPedido.entregado:
      case EstadoPedido.cancelado:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GestionarPedidoBloc, GestionarPedidoState>(
      builder: (context, state) {
        final pedido = state.pedido;
        final accion = _accion(pedido.estado);
        final entregado = pedido.estado == EstadoPedido.entregado;
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                PedidoEncabezado(pedido: pedido, subtitulo: _subtitulo(pedido)),
                const SizedBox(height: 20),
                if (state.status == GestionarPedidoStatus.failure) ...[
                  MessageBanner(title: state.errorMessage!, isError: true),
                  const SizedBox(height: 14),
                ],
                if (entregado) ...[
                  MessageBanner(
                    title: 'Entrega completada',
                    subtitle: 'Cobro confirmado: ${formatoPesos(pedido.total)}',
                  ),
                  const SizedBox(height: 14),
                ],
                _Progreso(pedido: pedido),
                const SizedBox(height: 14),
                PersonaCard(
                  nombre: pedido.clienteNombre,
                  calificacion: pedido.clienteCalificacion,
                  rol: 'Cliente',
                ),
                const SizedBox(height: 14),
                EntregaCard(pedido: pedido),
                const SizedBox(height: 14),
                ProductosCard(
                  pedido: pedido,
                  etiquetaTotal: entregado ? 'Total cobrado' : 'Total a cobrar',
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: accion == null
                  ? PrimaryButton(
                      label: 'Volver a pedidos',
                      isSecondary: true,
                      onPressed: () => Navigator.pop(context),
                    )
                  : PrimaryButton(
                      label: accion,
                      isLoading: state.status == GestionarPedidoStatus.avanzando,
                      onPressed: () =>
                          context.read<GestionarPedidoBloc>().add(AvanzarPedidoPressed()),
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// Línea de seguimiento: Aceptado → En camino → Entregado, con la hora de cada paso.
class _Progreso extends StatelessWidget {
  final Pedido pedido;

  const _Progreso({required this.pedido});

  static const _pasos = [
    EstadoPedido.aceptado,
    EstadoPedido.enCamino,
    EstadoPedido.entregado,
  ];

  @override
  Widget build(BuildContext context) {
    final actual = _pasos.indexOf(pedido.estado);
    return SurfaceCard(
      child: Column(
        children: [
          for (var i = 0; i < _pasos.length; i++)
            _Paso(
              estado: _pasos[i],
              hecho: i <= actual,
              fecha: pedido.historial[_pasos[i]],
              ultimo: i == _pasos.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  final EstadoPedido estado;
  final bool hecho;
  final DateTime? fecha;
  final bool ultimo;

  const _Paso({
    required this.estado,
    required this.hecho,
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
              hecho ? Icons.check_circle : Icons.radio_button_unchecked,
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
              estado.etiqueta,
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
