import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/estado_vacio.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/pedido_secciones.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/detalle_pedido/ui/bloc/detalle_pedido_bloc.dart';
import 'package:mocca_go/features/detalle_pedido/ui/bloc/detalle_pedido_event.dart';
import 'package:mocca_go/features/detalle_pedido/ui/bloc/detalle_pedido_state.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// 15 · Detalle del pedido y "Tomar pedido". Si otro domiciliario lo tomó
/// primero muestra 15b · Pedido ya tomado.
class DetallePedidoScreen extends StatelessWidget {
  const DetallePedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetallePedidoBloc, DetallePedidoState>(
      listener: (context, state) {
        if (state.status == DetallePedidoStatus.tomado) {
          // Reemplaza el detalle: al volver de Gestionar se llega al feed.
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.gestionarPedido,
            arguments: state.pedido,
          );
        }
      },
      builder: (context, state) {
        if (state.status == DetallePedidoStatus.yaTomado) {
          return const _YaTomado();
        }
        final pedido = state.pedido;
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                PedidoEncabezado(
                  pedido: pedido,
                  subtitulo:
                      'Esperando domiciliario ${haceCuanto(pedido.creadoEn).toLowerCase()}',
                ),
                const SizedBox(height: 20),
                if (state.status == DetallePedidoStatus.failure) ...[
                  MessageBanner(title: state.errorMessage!, isError: true),
                  const SizedBox(height: 14),
                ],
                PersonaCard(
                  nombre: pedido.clienteNombre,
                  calificacion: pedido.clienteCalificacion,
                  rol: 'Cliente',
                ),
                const SizedBox(height: 14),
                EntregaCard(pedido: pedido),
                const SizedBox(height: 14),
                ProductosCard(pedido: pedido),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: PrimaryButton(
                label: 'Tomar pedido',
                isLoading: state.status == DetallePedidoStatus.tomando ||
                    state.status == DetallePedidoStatus.tomado,
                onPressed: () =>
                    context.read<DetallePedidoBloc>().add(TomarPedidoPressed()),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 15b · Otro domiciliario lo tomó primero.
class _YaTomado extends StatelessWidget {
  const _YaTomado();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: Center(
          child: EstadoVacio(
            icono: Icons.person_off_outlined,
            titulo: 'Este pedido ya fue tomado',
            mensaje: 'Otro domiciliario lo tomó primero. '
                'Revisa el feed: puede haber más pedidos esperando.',
            color: AppColors.estadoPendiente,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: PrimaryButton(
            label: 'Volver a pedidos',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
