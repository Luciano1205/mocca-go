import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/app_input.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/login/ui/login_args.dart';
import 'package:mocca_go/features/register/ui/bloc/register_bloc.dart';
import 'package:mocca_go/features/register/ui/bloc/register_event.dart';
import 'package:mocca_go/features/register/ui/bloc/register_state.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// Mensaje del caso de uso cuando el código del domiciliario no sirve (05b).
const codigoInvalidoMessage = 'El código de acceso no es válido.';

/// Formulario común de 04 · Registro cliente y 05 · Registro domiciliario.
/// Con [pideCodigo] agrega el campo del código de acceso.
///
/// Valida los campos (HU02) antes de mandar el evento y, al crear la
/// cuenta, vuelve al login con el aviso verde (02e).
class RegisterForm extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool pideCodigo;

  const RegisterForm({
    super.key,
    required this.title,
    required this.subtitle,
    this.pideCodigo = false,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoController = TextEditingController();

  /// Errores de validación del formulario. Los de Supabase llegan en el
  /// estado del Bloc.
  String? _nombreError;
  String? _emailError;
  String? _passwordError;
  String? _codigoError;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _descripcionController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  void _submit() {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final descripcion = _descripcionController.text.trim();
    final codigo = _codigoController.text.trim();
    setState(() {
      _nombreError = nombre.isEmpty ? 'Escribe tu nombre' : null;
      _emailError = email.isEmpty
          ? 'Escribe tu correo'
          : !email.contains('@')
          ? 'Escribe un correo válido'
          : null;
      _passwordError = password.isEmpty
          ? 'Escribe una contraseña'
          : password.length < 6
          ? 'La contraseña debe tener al menos 6 caracteres'
          : null;
      _codigoError = widget.pideCodigo && codigo.isEmpty
          ? 'Escribe el código de acceso'
          : null;
    });
    if (_nombreError != null ||
        _emailError != null ||
        _passwordError != null ||
        _codigoError != null) {
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        email: email,
        password: password,
        nombre: nombre,
        descripcion: descripcion.isEmpty ? null : descripcion,
        codigoAcceso: widget.pideCodigo ? codigo : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
            arguments: LoginArgs.cuentaCreada,
          );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          final isLoading = state.status == RegisterStatus.loading;
          final serverError = state.status == RegisterStatus.failure
              ? state.errorMessage
              : null;
          // 05b: el código inválido se muestra en su campo, no en el aviso.
          final codigoInvalido = serverError == codigoInvalidoMessage;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (serverError != null && !codigoInvalido) ...[
                    MessageBanner(title: serverError, isError: true),
                    const SizedBox(height: 16),
                  ],
                  AppInput(
                    label: 'Nombre',
                    hint: 'Tu nombre completo',
                    controller: _nombreController,
                    keyboardType: TextInputType.name,
                    errorText: _nombreError,
                  ),
                  const SizedBox(height: 16),
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
                    hint: 'Mínimo 6 caracteres',
                    controller: _passwordController,
                    isPassword: true,
                    errorText: _passwordError,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Descripción (opcional)',
                    hint: widget.pideCodigo
                        ? 'Cuéntanos sobre ti'
                        : 'Ej: estudiante de Ingeniería',
                    controller: _descripcionController,
                  ),
                  if (widget.pideCodigo) ...[
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Código de acceso',
                      hint: 'Ej: MOCCA-2026',
                      controller: _codigoController,
                      helperText: 'Te lo entrega el equipo de Mocca Go!',
                      errorText:
                          _codigoError ??
                          (codigoInvalido ? codigoInvalidoMessage : null),
                    ),
                  ],
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: 'Crear cuenta',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      ),
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
          );
        },
      ),
    );
  }
}
