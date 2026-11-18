/// Error de dominio al calificar.
///
/// [toString] devuelve solo [message], para que el Bloc lo muestre tal cual.
class CalificacionFailure implements Exception {
  final String message;

  const CalificacionFailure(this.message);

  @override
  String toString() => message;
}
