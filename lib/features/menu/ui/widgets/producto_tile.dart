import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/cantidad_stepper.dart';
import 'package:mocca_go/components/producto_imagen.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_bloc.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_event.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// Un producto del menú (06). Si no está en el carrito muestra "Agregar";
/// si está, el contador. Agotado: se ve apagado y no se puede agregar.
class ProductoTile extends StatelessWidget {
  final Producto producto;
  final int cantidad;

  const ProductoTile({super.key, required this.producto, required this.cantidad});

  @override
  Widget build(BuildContext context) {
    final carrito = context.read<CarritoBloc>();
    final agotado = !producto.disponible;
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ProductoImagen(url: producto.imagenUrl, apagada: agotado),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: agotado ? AppColors.textMuted : AppColors.text,
                  ),
                ),
                if (producto.descripcion != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    producto.descripcion!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  formatoPesos(producto.precio),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: agotado ? AppColors.textMuted : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (agotado)
            const _Agotado()
          else if (cantidad == 0)
            IconButton.filled(
              tooltip: 'Agregar ${producto.nombre}',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              icon: const Icon(Icons.add),
              onPressed: () => carrito.add(CarritoProductoAgregado(producto)),
            )
          else
            CantidadStepper(
              cantidad: cantidad,
              onRestar: () => carrito.add(CarritoProductoQuitado(producto.id)),
              onSumar: () => carrito.add(CarritoProductoAgregado(producto)),
            ),
        ],
      ),
    );
  }
}

class _Agotado extends StatelessWidget {
  const _Agotado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(20)),
      child: const Text(
        'Agotado',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
      ),
    );
  }
}
