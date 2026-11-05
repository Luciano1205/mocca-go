import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_bloc.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_event.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_state.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// Pestaña "Perfil" (13 · Perfil, 20 · Perfil domiciliario): nombre, rol,
/// descripción, calificación y cerrar sesión. Editar llega en el sprint 3.
class PerfilPage extends StatelessWidget {
  final Usuario usuario;

  const PerfilPage({super.key, required this.usuario});

  String get _rol {
    switch (usuario.rol) {
      case Rol.cliente:
        return 'Cliente';
      case Rol.proveedor:
        return 'Domiciliario';
      case Rol.soporte:
        return 'Soporte';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PanelBloc, PanelState>(
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
        final calificacion = usuario.totalCalificaciones == 0
            ? 'Sin calificaciones aún'
            : '${usuario.calificacionPromedio.toStringAsFixed(1)} · '
                  '${usuario.totalCalificaciones} calificaciones';
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Perfil', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                  child: Text(
                    iniciales(usuario.nombre),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  usuario.nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '$_rol · ${usuario.correo}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 24),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          calificacion,
                          style: const TextStyle(fontSize: 15, color: AppColors.text),
                        ),
                      ],
                    ),
                    if (usuario.descripcion != null && usuario.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        usuario.descripcion!,
                        style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
                      ),
                    ],
                  ],
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
                onPressed: () =>
                    context.read<PanelBloc>().add(PanelSignOutRequested()),
              ),
            ],
          ),
        );
      },
    );
  }
}
