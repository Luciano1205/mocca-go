/// Error de dominio al leer el catálogo.
///
/// [toString] devuelve solo [message], para que el Bloc lo muestre tal cual.
class CatalogoFailure implements Exception {
  final String message;

  const CatalogoFailure(this.message);

  @override
  String toString() => message;
}
