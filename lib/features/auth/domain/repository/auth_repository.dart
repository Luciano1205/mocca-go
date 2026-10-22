import 'package:mocca_go/features/auth/domain/entities/auth_user.dart';

/// Lo que el dominio necesita del servicio de autenticación.
abstract class AuthRepository {
  /// Crea la cuenta. [codigoAcceso] solo lo envía el domiciliario: la base
  /// de datos lo valida y asigna el rol `proveedor`.
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String nombre,
    String? descripcion,
    String? codigoAcceso,
  });

  /// Abre sesión con una cuenta existente.
  Future<AuthUser> signIn({required String email, required String password});

  /// Cierra la sesión actual.
  Future<void> signOut();

  /// Id de la cuenta con sesión abierta, o null si no hay sesión.
  String? currentUserId();

  /// true si el código de domiciliario es válido (pantalla 05b).
  Future<bool> validarCodigoAcceso(String codigo);

  /// Envía al correo el código de 6 dígitos para recuperar la contraseña.
  Future<void> sendRecoveryCode(String email);

  /// Verifica el código de recuperación. Si es correcto abre una sesión
  /// temporal que permite cambiar la contraseña.
  Future<void> verifyRecoveryCode({required String email, required String code});

  /// Cambia la contraseña de la sesión actual.
  Future<void> updatePassword(String newPassword);
}
