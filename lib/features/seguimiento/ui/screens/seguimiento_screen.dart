import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/pedido_secciones.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_bloc.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_event.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_state.dart';
import 'package:mocca_go/features/seguimiento/ui/widgets/domiciliario_card.dart';
import 'package:mocca_go/features/seguimiento/ui/widgets/linea_tiempo.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// 11 · Seguimiento: estado, línea de tiempo y domiciliario cuando lo
/// acepta. Mientras siga pendiente se puede cancelar (11c).
class SeguimientoScreen extends StatelessWidget {
  const SeguimientoScreen({super.key});

  static String subtitulo(Pedido pedido) {
    final fecha = pedido.historial[pedido.estado];
    final hora = fecha == null ? '' : ' a las ${formatoHora(fecha)}';
    final domiciliario = pedido.domiciliarioNombre == null
        ? 'Un domiciliario'
        : nombreCorto(pedido.domiciliarioNombre!);
    switch (pedido.estado) {
      case EstadoPedido.pendiente:
        return 'Esperando domiciliario ${haceCuanto(pedido.creadoEn).toLowerCase()}';
      case EstadoPedido.aceptado:
        return '$domiciliario tomó tu pedido$hora';
      case EstadoPedido.enCamino:
        return '$domiciliario va en camino';
      case EstadoPedido.entregado:
        return 'Entregado$hora';
      case EstadoPedido.cancelado:
        return 'Cancelado$hora';
    }
  }

  Future<void> _recargar(BuildContext context) async {
    final bloc = context.read<SeguimientoBloc>()..add(SeguimientoRequested());
    await bloc.stream.firstWhere((s) => s.status != SeguimientoStatus.loading);
  }

  /// 11c · Confirmar cancelación.
  Future<void> _confirmarCancelacion(BuildContext context, Pedido pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Cancelar el pedido?'),
        content: Text(
          'El pedido #${pedido.numero} se cancelará y no tendrás que pagar nada.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, seguir esperando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cancelar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      context.read<SeguimientoBloc>().add(CancelarPedidoConfirmed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeguimientoBloc, SeguimientoState>(
      builder: (context, state) {
        final pedido = state.pedido;
        final pendiente = pedido.estado == EstadoPedido.pendiente;
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _recargar(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  PedidoEncabezado(pedido: pedido, subtitulo: subtitulo(pedido)),
                  const SizedBox(height: 20),
                  if (state.status == SeguimientoStatus.failure) ...[
                    MessageBanner(title: state.errorMessage!, isError: true),
                    const SizedBox(height: 14),
                  ],
                  if (pedido.estado == EstadoPedido.cancelado) ...[
                    const MessageBanner(
                      title: 'Pedido cancelado',
                      subtitle: 'No se te cobrará nada.',
                      isError: true,
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    LineaTiempo(pedido: pedido),
                    const SizedBox(height: 14),
                    DomiciliarioCard(pedido: pedido),
                    const SizedBox(height: 14),
                  ],
                  EntregaCard(pedido: pedido),
                  const SizedBox(height: 14),
                  ProductosCard(pedido: pedido, etiquetaTotal: 'Total'),
                ],
              ),
            ),
          ),
          bottomNavigationBar: pendiente
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                    child: PrimaryButton(
                      label: 'Cancelar pedido',
                      isSecondary: true,
                      isLoading: state.status == SeguimientoStatus.cancelando,
                      onPressed: () => _confirmarCancelacion(context, pedido),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
