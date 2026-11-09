import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/cantidad_stepper.dart';
import 'package:mocca_go/components/estado_vacio.dart';
import 'package:mocca_go/components/info_row.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/components/producto_imagen.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_bloc.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_event.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_state.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// 07 · Carrito y 07b · Carrito vacío. Usa el [CarritoBloc] global.
class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarritoBloc, CarritoState>(
      builder: (context, carrito) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tu carrito'),
            actions: [
              if (!carrito.vacio)
                TextButton(
                  onPressed: () => context.read<CarritoBloc>().add(CarritoVaciado()),
                  child: const Text('Vaciar', style: TextStyle(color: AppColors.error)),
                ),
            ],
          ),
          body: SafeArea(child: carrito.vacio ? const _Vacio() : _Items(carrito: carrito)),
          bottomNavigationBar: carrito.vacio
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                    child: PrimaryButton(
                      label: 'Continuar',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.datosEntrega),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _Items extends StatelessWidget {
  final CarritoState carrito;

  const _Items({required this.carrito});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CarritoBloc>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        for (final item in carrito.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SurfaceCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ProductoImagen(url: item.producto.imagenUrl, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.producto.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatoPesos(item.subtotal),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CantidadStepper(
                    cantidad: item.cantidad,
                    onRestar: () => bloc.add(CarritoProductoQuitado(item.producto.id)),
                    onSumar: () => bloc.add(CarritoProductoAgregado(item.producto)),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        SurfaceCard(
          child: Column(
            children: [
              InfoRow(label: 'Subtotal', value: formatoPesos(carrito.total)),
              const InfoRow(label: 'Domicilio', value: 'Gratis', valueColor: AppColors.success),
              const SizedBox(height: 4),
              InfoRow(
                label: 'Total',
                value: formatoPesos(carrito.total),
                destacado: true,
                valueColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 07b · Carrito vacío.
class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const EstadoVacio(
            icono: Icons.shopping_bag_outlined,
            titulo: 'Tu carrito está vacío',
            mensaje: 'Agrega algo del menú para hacer tu pedido.',
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: PrimaryButton(
              label: 'Ver menú',
              isSecondary: true,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
