/// Error de dominio para todo lo que falla al autenticar.
///
/// [toString] devuelve solo [message], para que el Bloc lo muestre tal cual.
class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}
