import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/errors/auth_failure.dart';
import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';
import 'package:mocca_go/features/auth/domain/repository/usuario_repository.dart';

/// Inicia sesión y lee el perfil para saber el rol (02 · Login).
class SignInUseCase {
  final AuthRepository _auth;
  final UsuarioRepository _usuarios;

  SignInUseCase(this._auth, this._usuarios);

  Future<Usuario> call({required String email, required String password}) async {
    final user = await _auth.signIn(email: email, password: password);
    try {
      return await _usuarios.getUsuario(user.id);
    } on Exception {
      // Sin perfil la app no puede seguir: se cierra la sesión recién abierta.
      try {
        await _auth.signOut();
      } on Exception {
        // El problema original es el perfil.
      }
      throw const AuthFailure('No se pudo cargar tu perfil. Intenta de nuevo.');
    }
  }
}
