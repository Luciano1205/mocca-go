import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/estado_vacio.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/pedido_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_bloc.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_event.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_state.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Pestaña "Pedidos" del domiciliario (14 · Pedidos pendientes y
/// 14c · Sin pedidos). Se desliza hacia abajo para recargar.
class PendientesPage extends StatelessWidget {
  const PendientesPage({super.key});

  Future<void> _abrir(BuildContext context, Pedido pedido) async {
    await Navigator.pushNamed(context, AppRoutes.detallePedido, arguments: pedido);
    // Al volver (lo tomó o no) el feed puede haber cambiado.
    if (context.mounted) context.read<PendientesBloc>().add(PendientesRequested());
  }

  Future<void> _recargar(BuildContext context) async {
    final bloc = context.read<PendientesBloc>()..add(PendientesRequested());
    await bloc.stream.firstWhere((s) => s.status != PendientesStatus.loading);
  }

  String _subtitulo(PendientesState state) {
    final n = state.pedidos.length;
    if (state.status == PendientesStatus.initial ||
        (state.status == PendientesStatus.loading && n == 0)) {
      return 'Buscando pedidos...';
    }
    if (n == 0) return 'Ningún pedido por ahora';
    return n == 1 ? '1 pedido esperando domiciliario' : '$n pedidos esperando domiciliario';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PendientesBloc, PendientesState>(
      builder: (context, state) {
        final cargando = state.status == PendientesStatus.loading ||
            state.status == PendientesStatus.initial;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _recargar(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              Text('Pedidos pendientes', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(_subtitulo(state), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              if (state.status == PendientesStatus.failure) ...[
                MessageBanner(title: state.errorMessage!, isError: true),
                const SizedBox(height: 16),
              ],
              if (state.pedidos.isEmpty && cargando)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (state.pedidos.isEmpty && state.status == PendientesStatus.success)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: EstadoVacio(
                    icono: Icons.coffee_outlined,
                    titulo: 'No hay pedidos pendientes',
                    mensaje: 'Desliza hacia abajo para buscar nuevos pedidos.',
                  ),
                )
              else
                for (final pedido in state.pedidos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PedidoCard(pedido: pedido, onTap: () => _abrir(context, pedido)),
                  ),
            ],
          ),
        );
      },
    );
  }
}
