import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/app_input.dart';
import 'package:mocca_go/components/app_logo.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/login/ui/bloc/login_bloc.dart';
import 'package:mocca_go/features/login/ui/bloc/login_event.dart';
import 'package:mocca_go/features/login/ui/bloc/login_state.dart';
import 'package:mocca_go/features/login/ui/login_args.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// 02 · Login. Si llega con [LoginArgs] muestra el aviso verde (02e / 02h).
/// Al entrar, va al panel del rol y borra el historial.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Errores de validación del formulario. Los de Supabase llegan en el
  /// estado del Bloc.
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _emailError = email.isEmpty ? 'Escribe tu correo' : null;
      _passwordError = password.isEmpty ? 'Escribe tu contraseña' : null;
    });
    if (_emailError != null || _passwordError != null) return;
    FocusScope.of(context).unfocus();
    context.read<LoginBloc>().add(
      LoginSubmitted(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as LoginArgs?;

    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.panelDe(state.usuario!.rol),
              (route) => false,
              arguments: state.usuario,
            );
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final isLoading = state.status == LoginStatus.loading;
            final serverError = state.status == LoginStatus.failure
                ? state.errorMessage
                : null;
            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          const AppLogo(size: 56),
                          const SizedBox(height: 24),
                          const Text(
                            'Hola de nuevo',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingresa para pedir tu café o atender pedidos.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (serverError != null) ...[
                            MessageBanner(title: serverError, isError: true),
                            const SizedBox(height: 16),
                          ] else if (args != null) ...[
                            MessageBanner(
                              title: args.titulo,
                              subtitle: args.subtitulo,
                            ),
                            const SizedBox(height: 16),
                          ],
                          AppInput(
                            label: 'Correo',
                            hint: 'correo@ejemplo.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailError,
                          ),
                          const SizedBox(height: 16),
                          AppInput(
                            label: 'Contraseña',
                            hint: 'Tu contraseña',
                            controller: _passwordController,
                            isPassword: true,
                            errorText: _passwordError,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.recuperar,
                              ),
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 28),
                          PrimaryButton(
                            label: 'Iniciar sesión',
                            isLoading: isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.tipoRegistro,
                              ),
                              child: const Text.rich(
                                TextSpan(
                                  text: '¿No tienes cuenta? ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textMuted,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Regístrate',
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
            );
          },
        ),
      ),
    );
  }
}
