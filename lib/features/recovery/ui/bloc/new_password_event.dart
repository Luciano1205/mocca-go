/// Lo que la pantalla 02g le dice a [NewPasswordBloc].
abstract class NewPasswordEvent {}

/// El usuario escribió el código y la nueva contraseña y tocó
/// "Cambiar contraseña".
class NewPasswordSubmitted extends NewPasswordEvent {
  final String email;
  final String code;
  final String newPassword;

  NewPasswordSubmitted({
    required this.email,
    required this.code,
    required this.newPassword,
  });
}

/// El usuario tocó "¿No te llegó el código? Reenviar".
class NewPasswordResendRequested extends NewPasswordEvent {
  final String email;

  NewPasswordResendRequested({required this.email});
}
