import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/app_input.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/login/ui/login_args.dart';
import 'package:mocca_go/features/recovery/ui/bloc/new_password_bloc.dart';
import 'package:mocca_go/features/recovery/ui/bloc/new_password_event.dart';
import 'package:mocca_go/features/recovery/ui/bloc/new_password_state.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// 02g · Nueva contraseña. Recibe el correo como argumento de la ruta.
/// Al cambiarla vuelve al login con "¡Contraseña actualizada!" (02h).
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  /// Errores de validación del formulario. Los de Supabase llegan en el
  /// estado del Bloc.
  String? _codeError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit(String email) {
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    setState(() {
      _codeError = code.length != 6 ? 'Escribe el código de 6 dígitos' : null;
      _passwordError = password.isEmpty
          ? 'Escribe la nueva contraseña'
          : password.length < 6
          ? 'La contraseña debe tener al menos 6 caracteres'
          : null;
      _confirmError = confirm.isEmpty
          ? 'Confirma la nueva contraseña'
          : confirm != password
          ? 'Las contraseñas no coinciden'
          : null;
    });
    if (_codeError != null || _passwordError != null || _confirmError != null) {
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<NewPasswordBloc>().add(
      NewPasswordSubmitted(email: email, code: code, newPassword: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<NewPasswordBloc, NewPasswordState>(
        listener: (context, state) {
          if (state.status == NewPasswordStatus.success) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
              arguments: LoginArgs.contrasenaActualizada,
            );
          }
        },
        child: BlocBuilder<NewPasswordBloc, NewPasswordState>(
          builder: (context, state) {
            final isLoading = state.status == NewPasswordStatus.loading;
            final isResending = state.resendStatus == NewPasswordStatus.loading;
            final serverError =
                state.status == NewPasswordStatus.failure ||
                    state.resendStatus == NewPasswordStatus.failure
                ? state.errorMessage
                : null;
            final resent = state.resendStatus == NewPasswordStatus.success;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Nueva contraseña',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Escribe el código que enviamos a ',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textMuted,
                        ),
                        children: [
                          TextSpan(
                            text: email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const TextSpan(text: ' y tu nueva contraseña.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (serverError != null) ...[
                      MessageBanner(title: serverError, isError: true),
                      const SizedBox(height: 16),
                    ] else if (resent) ...[
                      const MessageBanner(
                        title: 'Te enviamos un nuevo código.',
                        subtitle: 'Revisa tu bandeja de entrada o spam.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    AppInput(
                      label: 'Código',
                      hint: '000000',
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      helperText: 'Revisa tu bandeja de entrada o spam.',
                      errorText: _codeError,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Nueva contraseña',
                      hint: 'Mínimo 6 caracteres',
                      controller: _passwordController,
                      isPassword: true,
                      errorText: _passwordError,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Confirmar contraseña',
                      hint: 'Repite la nueva contraseña',
                      controller: _confirmController,
                      isPassword: true,
                      errorText: _confirmError,
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Cambiar contraseña',
                      isLoading: isLoading,
                      onPressed: () => _submit(email),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: isResending || isLoading
                            ? null
                            : () => context.read<NewPasswordBloc>().add(
                                NewPasswordResendRequested(email: email),
                              ),
                        child: Text.rich(
                          TextSpan(
                            text: '¿No te llegó el código? ',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textMuted,
                            ),
                            children: [
                              TextSpan(
                                text: isResending
                                    ? 'Reenviando...'
                                    : 'Reenviar',
                                style: const TextStyle(
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
            );
          },
        ),
      ),
    );
  }
}
