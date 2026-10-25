import 'package:flutter/material.dart';

import 'package:mocca_go/components/app_logo.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// 03 · Tipo de registro. Solo navega: cliente (04) o domiciliario (05).
class RegisterTypeScreen extends StatelessWidget {
  const RegisterTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const AppLogo(size: 56),
                    const SizedBox(height: 24),
                    const Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¿Cómo vas a usar Mocca Go!?',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _TypeOption(
                      icon: Icons.local_cafe_outlined,
                      title: 'Cliente',
                      subtitle: 'Pide tu café y recíbelo donde estés.',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.registroCliente,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TypeOption(
                      icon: Icons.delivery_dining_outlined,
                      title: 'Domiciliario',
                      subtitle:
                          'Atiende y entrega pedidos. Necesitas un '
                          'código de acceso.',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.registroDomiciliario,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 28),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text.rich(
                          TextSpan(
                            text: '¿Ya tienes cuenta? ',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textMuted,
                            ),
                            children: [
                              TextSpan(
                                text: 'Inicia sesión',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de una opción de registro.
class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Function() onTap;

  const _TypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
