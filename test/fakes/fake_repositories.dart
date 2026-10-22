import 'package:mocca_go/features/auth/domain/entities/auth_user.dart';
import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/errors/auth_failure.dart';
import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';
import 'package:mocca_go/features/auth/domain/repository/usuario_repository.dart';

/// Auth en memoria para probar casos de uso y pantallas sin Supabase.
class FakeAuthRepository implements AuthRepository {
  final Map<String, String> passwords = {};
  final Map<String, String> ids = {};
  String? sessionUserId;
  String? lastRecoveryEmail;
  String codigoValido = 'MOCCA-2026';
  String recoveryCode = '123456';
  final List<Map<String, String?>> signUps = [];

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String nombre,
    String? descripcion,
    String? codigoAcceso,
  }) async {
    if (passwords.containsKey(email)) {
      throw const AuthFailure('Ya existe una cuenta con ese correo.');
    }
    passwords[email] = password;
    ids[email] = 'id-$email';
    sessionUserId = ids[email];
    signUps.add({'email': email, 'nombre': nombre, 'codigo': codigoAcceso});
    return AuthUser(id: ids[email]!, email: email);
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    if (passwords[email] != password) {
      throw const AuthFailure('Correo o contraseña incorrectos.');
    }
    sessionUserId = ids[email];
    return AuthUser(id: ids[email]!, email: email);
  }

  @override
  Future<void> signOut() async => sessionUserId = null;

  @override
  String? currentUserId() => sessionUserId;

  @override
  Future<bool> validarCodigoAcceso(String codigo) async =>
      codigo.trim().toUpperCase() == codigoValido;

  @override
  Future<void> sendRecoveryCode(String email) async => lastRecoveryEmail = email;

  @override
  Future<void> verifyRecoveryCode({required String email, required String code}) async {
    if (email != lastRecoveryEmail || code != recoveryCode) {
      throw const AuthFailure('El código es incorrecto o ya venció.');
    }
    sessionUserId = ids[email];
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final email = ids.entries.firstWhere((e) => e.value == sessionUserId).key;
    passwords[email] = newPassword;
  }
}

/// Perfiles en memoria.
class FakeUsuarioRepository implements UsuarioRepository {
  final Map<String, Usuario> usuarios = {};

  @override
  Future<Usuario> getUsuario(String id) async {
    final u = usuarios[id];
    if (u == null) throw const AuthFailure('No se pudo cargar tu perfil.');
    return u;
  }
}
