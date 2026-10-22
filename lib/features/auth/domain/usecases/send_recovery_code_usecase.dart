import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';

/// 02f · Envía el código de 6 dígitos al correo.
class SendRecoveryCodeUseCase {
  final AuthRepository _auth;

  SendRecoveryCodeUseCase(this._auth);

  Future<void> call(String email) => _auth.sendRecoveryCode(email.trim());
}
