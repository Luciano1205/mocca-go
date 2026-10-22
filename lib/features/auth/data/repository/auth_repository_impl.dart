import 'package:mocca_go/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:mocca_go/features/auth/domain/entities/auth_user.dart';
import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';

/// Cumple [AuthRepository] delegando en el data source de Supabase.
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String nombre,
    String? descripcion,
    String? codigoAcceso,
  }) {
    return _dataSource.signUp(
      email: email,
      password: password,
      nombre: nombre,
      descripcion: descripcion,
      codigoAcceso: codigoAcceso,
    );
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    return _dataSource.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  String? currentUserId() => _dataSource.currentUserId();

  @override
  Future<bool> validarCodigoAcceso(String codigo) {
    return _dataSource.validarCodigoAcceso(codigo);
  }

  @override
  Future<void> sendRecoveryCode(String email) {
    return _dataSource.sendRecoveryCode(email);
  }

  @override
  Future<void> verifyRecoveryCode({
    required String email,
    required String code,
  }) {
    return _dataSource.verifyRecoveryCode(email: email, code: code);
  }

  @override
  Future<void> updatePassword(String newPassword) {
    return _dataSource.updatePassword(newPassword);
  }
}
