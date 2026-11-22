/// Error de dominio en el chat de reclamos.
///
/// [toString] devuelve solo [message], para que el Bloc lo muestre tal cual.
class ReclamoFailure implements Exception {
  final String message;

  const ReclamoFailure(this.message);

  @override
  String toString() => message;
}
