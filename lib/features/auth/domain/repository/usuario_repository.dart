import 'package:mocca_go/features/auth/domain/entities/usuario.dart';

/// Lo que el dominio necesita de la tabla `usuario`.
abstract class UsuarioRepository {
  /// Perfil del usuario con ese id.
  Future<Usuario> getUsuario(String id);
}
