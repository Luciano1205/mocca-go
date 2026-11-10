import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/estado_vacio.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_bloc.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_state.dart';
import 'package:mocca_go/features/catalogo/domain/entities/categoria.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_bloc.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_event.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_state.dart';
import 'package:mocca_go/features/menu/ui/widgets/carrito_barra.dart';
import 'package:mocca_go/features/menu/ui/widgets/producto_tile.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Pestaña "Menú" del cliente (06 · Menú): chips de categoría, productos y,
/// si el carrito tiene algo, la barra para ir a 07 · Carrito.
class MenuPage extends StatelessWidget {
  final String nombre;

  const MenuPage({super.key, required this.nombre});

  Future<void> _recargar(BuildContext context) async {
    final bloc = context.read<MenuBloc>()..add(MenuRequested());
    await bloc.stream.firstWhere((s) => s.status != MenuStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarritoBloc, CarritoState>(
      builder: (context, carrito) {
        return Column(
          children: [
            Expanded(
              child: _Lista(nombre: nombre, carrito: carrito, onRefresh: _recargar),
            ),
            if (!carrito.vacio)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: CarritoBarra(
                  unidades: carrito.totalUnidades,
                  total: carrito.total,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.carrito),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Lista extends StatelessWidget {
  final String nombre;
  final CarritoState carrito;
  final Future<void> Function(BuildContext) onRefresh;

  const _Lista({required this.nombre, required this.carrito, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        final cargando = state.status == MenuStatus.loading || state.status == MenuStatus.initial;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => onRefresh(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            children: [
              Text('Hola, $nombre', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('¿Qué se te antoja hoy?', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              _Chips(categorias: state.categorias, elegida: state.categoriaId),
              const SizedBox(height: 16),
              if (state.status == MenuStatus.failure) ...[
                MessageBanner(title: state.errorMessage!, isError: true),
                const SizedBox(height: 16),
              ],
              if (state.productos.isEmpty && cargando)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (state.productos.isEmpty && state.status == MenuStatus.success)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: EstadoVacio(
                    icono: Icons.coffee_outlined,
                    titulo: 'No hay productos aquí',
                    mensaje: 'Prueba con otra categoría.',
                  ),
                )
              else
                for (final producto in state.productos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProductoTile(
                      producto: producto,
                      cantidad: carrito.cantidadDe(producto.id),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// Chips "Todos · Cafés · Bebidas frías · Snacks", como en la lección 104.
class _Chips extends StatelessWidget {
  final List<Categoria> categorias;
  final String? elegida;

  const _Chips({required this.categorias, required this.elegida});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(texto: 'Todos', id: null, activa: elegida == null),
          for (final c in categorias) ...[
            const SizedBox(width: 8),
            _Chip(texto: c.nombre, id: c.id, activa: elegida == c.id),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final String? id;
  final bool activa;

  const _Chip({required this.texto, required this.id, required this.activa});

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
        if (!activa) context.read<MenuBloc>().add(MenuCategoriaSelected(id));
      },
    );
  }
}
