import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';

/// Cierra la sesión.
class SignOutUseCase {
  final AuthRepository _auth;

  SignOutUseCase(this._auth);

  Future<void> call() => _auth.signOut();
}
