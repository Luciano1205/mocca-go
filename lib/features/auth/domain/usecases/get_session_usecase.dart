import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';
import 'package:mocca_go/features/auth/domain/repository/usuario_repository.dart';

/// Lo usa el splash (01): si hay sesión devuelve el perfil para ir al panel
/// del rol; si no hay sesión, o el perfil no carga, devuelve null (login).
class GetSessionUseCase {
  final AuthRepository _auth;
  final UsuarioRepository _usuarios;

  GetSessionUseCase(this._auth, this._usuarios);

  Future<Usuario?> call() async {
    final id = _auth.currentUserId();
    if (id == null) return null;
    try {
      return await _usuarios.getUsuario(id);
    } on Exception {
      await _auth.signOut();
      return null;
    }
  }
}
