import 'package:flutter/material.dart';

import 'package:mocca_go/components/estado_vacio.dart';
import 'package:mocca_go/components/info_row.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// 09 · Pedido enviado. Recibe el [Pedido] creado como argumento.
class PedidoEnviadoScreen extends StatelessWidget {
  const PedidoEnviadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedido = ModalRoute.of(context)!.settings.arguments as Pedido;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
          children: [
            const EstadoVacio(
              icono: Icons.check_rounded,
              titulo: '¡Pedido enviado!',
              mensaje:
                  'Estamos buscando un domiciliario. '
                  'Te avisamos en Mis pedidos cuando lo tome.',
              color: AppColors.success,
            ),
            const SizedBox(height: 32),
            SurfaceCard(
              child: Column(
                children: [
                  InfoRow(label: 'Pedido', value: '#${pedido.numero}'),
                  InfoRow(label: 'Entrega en', value: pedido.zona),
                  InfoRow(label: 'Productos', value: pedido.resumenItems),
                  if (pedido.pago != null) InfoRow(label: 'Pago', value: pedido.pago!.resumen),
                  const SizedBox(height: 4),
                  InfoRow(
                    label: 'Total',
                    value: formatoPesos(pedido.total),
                    destacado: true,
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: 'Ver seguimiento',
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.seguimiento,
                  arguments: pedido,
                ),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Volver al menú',
                isSecondary: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
