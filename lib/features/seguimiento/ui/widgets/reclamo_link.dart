import 'package:flutter/material.dart';

import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Entrada al chat de reclamos (21 y 22): "¿Problema con tu pedido? Escríbenos".
class ReclamoLink extends StatelessWidget {
  final Pedido pedido;

  const ReclamoLink({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.reclamo, arguments: pedido),
        icon: const Icon(Icons.support_agent, color: AppColors.primary, size: 20),
        label: const Text.rich(
          TextSpan(
            text: '¿Problema con tu pedido? ',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            children: [
              TextSpan(
                text: 'Escríbenos',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
