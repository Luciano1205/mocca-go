import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/estado_vacio.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/pedido_card.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_bloc.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_event.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_state.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Pestaña "Mis entregas" del domiciliario (16 · Activos, 16b · Historial).
class MisEntregasPage extends StatelessWidget {
  const MisEntregasPage({super.key});

  Future<void> _abrir(BuildContext context, Pedido pedido) async {
    await Navigator.pushNamed(context, AppRoutes.gestionarPedido, arguments: pedido);
    if (context.mounted) context.read<MisEntregasBloc>().add(MisEntregasRequested());
  }

  Future<void> _recargar(BuildContext context) async {
    final bloc = context.read<MisEntregasBloc>()..add(MisEntregasRequested());
    await bloc.stream.firstWhere((s) => s.status != MisEntregasStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MisEntregasBloc, MisEntregasState>(
      builder: (context, state) {
        final cargando = state.status == MisEntregasStatus.loading ||
            state.status == MisEntregasStatus.initial;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _recargar(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              Text('Mis entregas', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Pestana(texto: 'Activos', activa: state.activos, activos: true),
                  const SizedBox(width: 8),
                  _Pestana(texto: 'Historial', activa: !state.activos, activos: false),
                ],
              ),
              const SizedBox(height: 16),
              if (state.status == MisEntregasStatus.failure) ...[
                MessageBanner(title: state.errorMessage!, isError: true),
                const SizedBox(height: 16),
              ],
              if (state.pedidos.isEmpty && cargando)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (state.pedidos.isEmpty && state.status == MisEntregasStatus.success)
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: state.activos
                      ? const EstadoVacio(
                          icono: Icons.inventory_2_outlined,
                          titulo: 'No tienes entregas en curso',
                          mensaje: 'Toma un pedido desde la pestaña Pedidos.',
                        )
                      : const EstadoVacio(
                          icono: Icons.history,
                          titulo: 'Aún no tienes entregas completadas',
                        ),
                )
              else
                for (final pedido in state.pedidos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PedidoCard(
                      pedido: pedido,
                      mostrarEstado: true,
                      onTap: () => _abrir(context, pedido),
                    ),
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
          context.read<MisEntregasBloc>().add(MisEntregasRequested(activos: activos));
        }
      },
    );
  }
}
