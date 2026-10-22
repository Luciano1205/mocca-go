import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/app_logo.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_bloc.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_event.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_state.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Panel temporal del sprint 1: confirma a qué rol entró el usuario y
/// permite cerrar sesión. En el sprint 2 se reemplaza por los paneles con
/// pestañas del cliente (Menú) y del domiciliario (Pedidos).
class PanelScreen extends StatelessWidget {
  final Usuario usuario;

  const PanelScreen({super.key, required this.usuario});

  String get _titulo {
    switch (usuario.rol) {
      case Rol.cliente:
        return 'Panel del cliente';
      case Rol.proveedor:
        return 'Panel del domiciliario';
      case Rol.soporte:
        return 'Panel de soporte';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PanelBloc, PanelState>(
        listener: (context, state) {
          if (state.status == PanelStatus.signedOut) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const AppLogo(size: 56),
                  const SizedBox(height: 24),
                  Text(
                    _titulo,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hola, ${usuario.nombre}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.correo,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (state.status == PanelStatus.failure) ...[
                    const SizedBox(height: 16),
                    MessageBanner(title: state.errorMessage!, isError: true),
                  ],
                  const Spacer(),
                  PrimaryButton(
                    label: 'Cerrar sesión',
                    isSecondary: true,
                    isLoading: state.status == PanelStatus.signingOut,
                    onPressed: () => context.read<PanelBloc>().add(
                      PanelSignOutRequested(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
