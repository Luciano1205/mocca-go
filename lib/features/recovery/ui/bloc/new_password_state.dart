/// En qué momento está el cambio de contraseña. [resendStatus] usa los
/// mismos valores para el reenvío del código.
enum NewPasswordStatus { initial, loading, success, failure }

/// Estado único: el cambio va en [status] y el reenvío en [resendStatus].
/// [copyWith] cambia solo lo que se le pasa.
class NewPasswordState {
  final NewPasswordStatus status;
  final NewPasswordStatus resendStatus;
  final String? errorMessage;

  const NewPasswordState({
    this.status = NewPasswordStatus.initial,
    this.resendStatus = NewPasswordStatus.initial,
    this.errorMessage,
  });

  NewPasswordState copyWith({
    NewPasswordStatus? status,
    NewPasswordStatus? resendStatus,
    String? errorMessage,
  }) {
    return NewPasswordState(
      status: status ?? this.status,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
