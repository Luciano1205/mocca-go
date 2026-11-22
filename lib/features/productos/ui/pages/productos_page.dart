import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/producto_imagen.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_bloc.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_event.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_state.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// Pestaña "Productos" del domiciliario (19 · Disponibilidad de productos).
/// Los agotados aparecen deshabilitados en el menú del cliente.
class ProductosPage extends StatelessWidget {
  const ProductosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductosBloc, ProductosState>(
      builder: (context, state) {
        final cargando = state.status == ProductosStatus.loading ||
            state.status == ProductosStatus.initial;
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text('Productos', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Marca como agotado lo que ya no hay. El cliente no podrá pedirlo.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (state.errorMessage != null) ...[
              MessageBanner(title: state.errorMessage!, isError: true),
              const SizedBox(height: 16),
            ],
            if (state.productos.isEmpty && cargando)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else
              for (final producto in state.productos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FilaProducto(
                    producto: producto,
                    guardando: state.guardando.contains(producto.id),
                  ),
                ),
          ],
        );
      },
    );
  }
}

/// Componente "Fila/Producto": foto, nombre, precio, etiqueta y switch.
class _FilaProducto extends StatelessWidget {
  final Producto producto;
  final bool guardando;

  const _FilaProducto({required this.producto, required this.guardando});

  @override
  Widget build(BuildContext context) {
    final disponible = producto.disponible;
    return SurfaceCard(
      child: Row(
        children: [
          ProductoImagen(url: producto.imagenUrl, size: 48, apagada: !disponible),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: disponible ? AppColors.text : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatoPesos(producto.precio)} · ${disponible ? 'Disponible' : 'Agotado'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: disponible ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            key: Key('switch-${producto.id}'),
            value: disponible,
            activeThumbColor: AppColors.onPrimary,
            activeTrackColor: AppColors.primary,
            onChanged: guardando
                ? null
                : (valor) => context
                    .read<ProductosBloc>()
                    .add(DisponibilidadCambiada(producto, disponible: valor)),
          ),
        ],
      ),
    );
  }
}
