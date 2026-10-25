/// En qué momento está el registro.
enum RegisterStatus { initial, loading, success, failure }

/// Estado único: el momento es [status] y [copyWith] cambia solo lo que
/// se le pasa.
class RegisterState {
  final RegisterStatus status;
  final String? errorMessage;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
  });

  RegisterState copyWith({RegisterStatus? status, String? errorMessage}) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
