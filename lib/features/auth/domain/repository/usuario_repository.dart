import 'package:mocca_go/features/auth/domain/entities/usuario.dart';

/// Lo que el dominio necesita de la tabla `usuario`.
abstract class UsuarioRepository {
  /// Perfil del usuario con ese id.
  Future<Usuario> getUsuario(String id);

  /// Cambia nombre y descripción del usuario [id] y devuelve el perfil nuevo.
  /// Rol y calificación no se editan (13b · Editar perfil).
  Future<Usuario> actualizarPerfil(
    String id, {
    required String nombre,
    String? descripcion,
  });
}
