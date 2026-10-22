import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'package:mocca_go/features/auth/domain/entities/auth_user.dart';
import 'package:mocca_go/features/auth/domain/errors/auth_failure.dart';

/// El único archivo que usa Supabase Auth. Convierte las respuestas en
/// [AuthUser] y los errores en [AuthFailure] con mensajes en español.
class SupabaseAuthDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String nombre,
    String? descripcion,
    String? codigoAcceso,
  }) async {
    try {
      // El trigger `crear_usuario` lee estos datos y crea el perfil.
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre': nombre,
          if (descripcion != null && descripcion.isNotEmpty)
            'descripcion': descripcion,
          'codigo_acceso': ?codigoAcceso,
        },
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('No se pudo crear la cuenta.');
      }
      return AuthUser(id: user.id, email: user.email ?? email);
    } on AuthException catch (e) {
      throw AuthFailure(_messageFor(e, registrandoConCodigo: codigoAcceso != null));
    }
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('No se pudo iniciar sesión.');
      }
      return AuthUser(id: user.id, email: user.email ?? email);
    } on AuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  String? currentUserId() => _client.auth.currentSession?.user.id;

  Future<bool> validarCodigoAcceso(String codigo) async {
    try {
      final result = await _client.rpc(
        'validar_codigo_acceso',
        params: {'p_codigo': codigo},
      );
      return result == true;
    } on PostgrestException {
      throw const AuthFailure('No se pudo validar el código. Intenta de nuevo.');
    }
  }

  Future<void> sendRecoveryCode(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  Future<void> verifyRecoveryCode({
    required String email,
    required String code,
  }) async {
    try {
      await _client.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: code,
      );
    } on AuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  /// Mensaje en español para los errores más comunes de Auth.
  String _messageFor(AuthException e, {bool registrandoConCodigo = false}) {
    switch (e.code) {
      case 'user_already_exists':
      case 'email_exists':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak_password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'email_address_invalid':
      case 'validation_failed':
        return 'El correo no es válido.';
      case 'invalid_credentials':
        return 'Correo o contraseña incorrectos.';
      case 'otp_expired':
        return 'El código es incorrecto o ya venció.';
      case 'same_password':
        return 'La nueva contraseña debe ser diferente a la anterior.';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Espera un momento antes de volver a intentarlo.';
      case 'unexpected_failure':
        // El trigger rechaza el registro si el código no es válido.
        return registrandoConCodigo
            ? 'El código de acceso no es válido.'
            : 'No se pudo crear la cuenta. Intenta de nuevo.';
      default:
        return e.message;
    }
  }
}
