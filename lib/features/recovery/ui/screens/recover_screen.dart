import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/app_input.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/recovery/ui/bloc/recover_bloc.dart';
import 'package:mocca_go/features/recovery/ui/bloc/recover_event.dart';
import 'package:mocca_go/features/recovery/ui/bloc/recover_state.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// 02f · Recuperar contraseña. Envía el código y pasa a 02g con el correo.
class RecoverScreen extends StatefulWidget {
  const RecoverScreen({super.key});

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final _emailController = TextEditingController();

  /// Error de validación del formulario. Los de Supabase llegan en el
  /// estado del Bloc.
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    setState(() {
      _emailError = email.isEmpty
          ? 'Escribe tu correo'
          : !email.contains('@')
          ? 'Escribe un correo válido'
          : null;
    });
    if (_emailError != null) return;
    FocusScope.of(context).unfocus();
    context.read<RecoverBloc>().add(RecoverSubmitted(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<RecoverBloc, RecoverState>(
        listener: (context, state) {
          if (state.status == RecoverStatus.success) {
            Navigator.pushNamed(
              context,
              AppRoutes.nuevaContrasena,
              arguments: _emailController.text.trim(),
            );
          }
        },
        child: BlocBuilder<RecoverBloc, RecoverState>(
          builder: (context, state) {
            final isLoading = state.status == RecoverStatus.loading;
            final serverError = state.status == RecoverStatus.failure
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
                          const SizedBox(height: 8),
                          const Text(
                            'Recuperar contraseña',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Escribe el correo de tu cuenta y te enviaremos '
                            'un código de 6 dígitos.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (serverError != null) ...[
                            MessageBanner(title: serverError, isError: true),
                            const SizedBox(height: 16),
                          ],
                          AppInput(
                            label: 'Correo',
                            hint: 'correo@ejemplo.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailError,
                          ),
                          const Spacer(),
                          const SizedBox(height: 28),
                          PrimaryButton(
                            label: 'Enviar código',
                            isLoading: isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text.rich(
                                TextSpan(
                                  text: '¿Ya la recordaste? ',
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
            );
          },
        ),
      ),
    );
  }
}
