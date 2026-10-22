import 'package:mocca_go/features/auth/domain/errors/auth_failure.dart';
import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';

/// Registra un cliente o, si trae [codigoAcceso], un domiciliario
/// (04 y 05). Al terminar cierra la sesión: el diseño vuelve al login con
/// el aviso "¡Cuenta creada exitosamente!" (02e).
class SignUpUseCase {
  final AuthRepository _auth;

  SignUpUseCase(this._auth);

  Future<void> call({
    required String email,
    required String password,
    required String nombre,
    String? descripcion,
    String? codigoAcceso,
  }) async {
    final codigo = codigoAcceso?.trim();
    if (codigo != null && codigo.isNotEmpty) {
      // Se valida antes para mostrar el error de la pantalla 05b.
      final valido = await _auth.validarCodigoAcceso(codigo);
      if (!valido) {
        throw const AuthFailure('El código de acceso no es válido.');
      }
    }
    await _auth.signUp(
      email: email.trim(),
      password: password,
      nombre: nombre.trim(),
      descripcion: descripcion?.trim(),
      codigoAcceso: (codigo == null || codigo.isEmpty) ? null : codigo,
    );
    await _auth.signOut();
  }
}
