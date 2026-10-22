/// Lo que la pantalla de login le dice a [LoginBloc].
abstract class LoginEvent {}

/// El usuario llenó el formulario y tocó "Iniciar sesión".
class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}
