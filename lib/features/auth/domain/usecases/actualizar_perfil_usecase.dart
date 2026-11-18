import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/errors/auth_failure.dart';
import 'package:mocca_go/features/auth/domain/repository/usuario_repository.dart';

/// Guarda nombre y descripción (13b y 20b · Editar perfil).
class ActualizarPerfilUseCase {
  final UsuarioRepository _usuarios;

  ActualizarPerfilUseCase(this._usuarios);

  Future<Usuario> call(Usuario usuario, {required String nombre, String? descripcion}) async {
    final limpio = nombre.trim();
    if (limpio.isEmpty) throw const AuthFailure('Escribe tu nombre.');
    final desc = descripcion?.trim();
    return _usuarios.actualizarPerfil(
      usuario.id,
      nombre: limpio,
      descripcion: (desc == null || desc.isEmpty) ? null : desc,
    );
  }
}
