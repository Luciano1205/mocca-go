import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';

/// 02g · Verifica el código, cambia la contraseña y cierra la sesión
/// temporal: el diseño vuelve al login con "¡Contraseña actualizada!" (02h).
class ResetPasswordUseCase {
  final AuthRepository _auth;

  ResetPasswordUseCase(this._auth);

  Future<void> call({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _auth.verifyRecoveryCode(email: email.trim(), code: code.trim());
    await _auth.updatePassword(newPassword);
    await _auth.signOut();
  }
}
