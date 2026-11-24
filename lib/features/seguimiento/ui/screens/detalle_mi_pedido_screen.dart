import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/pedido_secciones.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_bloc.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_state.dart';
import 'package:mocca_go/features/seguimiento/ui/screens/seguimiento_screen.dart';
import 'package:mocca_go/features/seguimiento/ui/widgets/calificacion_domiciliario.dart';
import 'package:mocca_go/features/seguimiento/ui/widgets/domiciliario_card.dart';
import 'package:mocca_go/features/seguimiento/ui/widgets/linea_tiempo.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/utils/formato.dart';

/// 11d · Pedido entregado y 11e · Pedido cancelado, desde el historial.
/// Usa el mismo [SeguimientoBloc] que el seguimiento para saber si ya
/// calificó al domiciliario y dejar hacerlo desde aquí (12).
class DetalleMiPedidoScreen extends StatelessWidget {
  const DetalleMiPedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeguimientoBloc, SeguimientoState>(
      builder: (context, state) {
        final pedido = state.pedido;
        final entregado = pedido.estado == EstadoPedido.entregado;
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                PedidoEncabezado(pedido: pedido, subtitulo: SeguimientoScreen.subtitulo(pedido)),
                const SizedBox(height: 20),
                if (state.status == SeguimientoStatus.failure) ...[
                  MessageBanner(title: state.errorMessage!, isError: true),
                  const SizedBox(height: 14),
                ],
                if (entregado) ...[
                  MessageBanner(
                    title: 'Pedido entregado',
                    subtitle: 'Pagaste ${formatoPesos(pedido.total)}. ¡Gracias por pedir!',
                  ),
                  const SizedBox(height: 14),
                  if (pedido.domiciliarioNombre != null) ...[
                    CalificacionDomiciliario(state: state),
                    const SizedBox(height: 14),
                  ],
                  LineaTiempo(pedido: pedido),
                  const SizedBox(height: 14),
                  DomiciliarioCard(pedido: pedido),
                ] else
                  const MessageBanner(
                    title: 'Pedido cancelado',
                    subtitle: 'No se te cobró nada.',
                    isError: true,
                  ),
                const SizedBox(height: 14),
                EntregaCard(pedido: pedido),
                const SizedBox(height: 14),
                ProductosCard(pedido: pedido, etiquetaTotal: entregado ? 'Total pagado' : 'Total'),
              ],
            ),
          ),
          // 21 · Reclamo de un pedido entregado. En los cancelados no se muestra.
          bottomNavigationBar: entregado
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                    child: PrimaryButton(
                      label: '¿Problema con tu pedido? Escríbenos',
                      isSecondary: true,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.reclamo, arguments: pedido),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
