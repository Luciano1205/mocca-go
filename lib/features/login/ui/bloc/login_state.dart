import 'package:mocca_go/features/auth/domain/entities/usuario.dart';

/// En qué momento está el login.
enum LoginStatus { initial, loading, success, failure }

/// Estado único: el momento es [status] y [copyWith] cambia solo lo que
/// se le pasa.
class LoginState {
  final LoginStatus status;
  final Usuario? usuario;
  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.usuario,
    this.errorMessage,
  });

  LoginState copyWith({
    LoginStatus? status,
    Usuario? usuario,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      usuario: usuario ?? this.usuario,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
