/// Lo que la pantalla 02f le dice a [RecoverBloc].
abstract class RecoverEvent {}

/// El usuario escribió su correo y tocó "Enviar código".
class RecoverSubmitted extends RecoverEvent {
  final String email;

  RecoverSubmitted({required this.email});
}
