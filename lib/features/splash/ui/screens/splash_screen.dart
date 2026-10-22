import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/app_logo.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_bloc.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_state.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// 01 · Splash. Muestra la marca mientras [SplashBloc] revisa la sesión:
/// con sesión va al panel del rol; sin sesión, al login. En ambos casos
/// borra el historial para que "atrás" no vuelva al splash.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state.status == SplashStatus.authenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.panelDe(state.usuario!.rol),
            (route) => false,
            arguments: state.usuario,
          );
        } else if (state.status == SplashStatus.unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: 96),
              SizedBox(height: 16),
              Text(
                'Mocca Go!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Tu café, donde estés en el campus',
                style: TextStyle(fontSize: 15, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
