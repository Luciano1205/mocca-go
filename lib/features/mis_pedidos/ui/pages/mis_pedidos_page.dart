import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/estado_vacio.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_bloc.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_event.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_state.dart';
import 'package:mocca_go/features/mis_pedidos/ui/widgets/mi_pedido_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Pestaña "Mis pedidos" del cliente (10 · Activos, 10b · Historial).
/// Los activos abren 11 · Seguimiento; los del historial, 11d / 11e · Detalle.
class MisPedidosPage extends StatelessWidget {
  const MisPedidosPage({super.key});

  Future<void> _abrir(BuildContext context, Pedido pedido) async {
    final ruta = pedido.estado.activo ? AppRoutes.seguimiento : AppRoutes.detalleMiPedido;
    await Navigator.pushNamed(context, ruta, arguments: pedido);
    // Al volver el pedido pudo cambiar (lo tomaron, lo cancelé...).
    if (context.mounted) context.read<MisPedidosBloc>().add(MisPedidosRequested());
  }

  Future<void> _recargar(BuildContext context) async {
    final bloc = context.read<MisPedidosBloc>()..add(MisPedidosRequested());
    await bloc.stream.firstWhere((s) => s.status != MisPedidosStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MisPedidosBloc, MisPedidosState>(
      builder: (context, state) {
        final cargando =
            state.status == MisPedidosStatus.loading || state.status == MisPedidosStatus.initial;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _recargar(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              Text('Mis pedidos', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Pestana(texto: 'Activos', activa: state.activos, activos: true),
                  const SizedBox(width: 8),
                  _Pestana(texto: 'Historial', activa: !state.activos, activos: false),
                ],
              ),
              const SizedBox(height: 16),
              if (state.status == MisPedidosStatus.failure) ...[
                MessageBanner(title: state.errorMessage!, isError: true),
                const SizedBox(height: 16),
              ],
              if (state.pedidos.isEmpty && cargando)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (state.pedidos.isEmpty && state.status == MisPedidosStatus.success)
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: state.activos
                      ? const EstadoVacio(
                          icono: Icons.receipt_long_outlined,
                          titulo: 'No tienes pedidos en curso',
                          mensaje: 'Pide algo desde la pestaña Menú.',
                        )
                      : const EstadoVacio(
                          icono: Icons.history,
                          titulo: 'Aún no tienes pedidos anteriores',
                        ),
                )
              else
                for (final pedido in state.pedidos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MiPedidoCard(pedido: pedido, onTap: () => _abrir(context, pedido)),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// Chip de Activos / Historial, como los filtros de categoría de la lección 104.
class _Pestana extends StatelessWidget {
  final String texto;
  final bool activa;
  final bool activos;

  const _Pestana({required this.texto, required this.activa, required this.activos});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(texto),
      selected: activa,
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: activa ? AppColors.onPrimary : AppColors.text,
      ),
      onSelected: (_) {
        if (!activa) {
          context.read<MisPedidosBloc>().add(MisPedidosRequested(activos: activos));
        }
      },
    );
  }
}
