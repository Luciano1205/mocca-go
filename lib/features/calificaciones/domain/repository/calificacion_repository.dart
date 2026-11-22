/// Calificaciones de 1 a 5 al entregar un pedido, en ambos sentidos.
/// Siempre actúa como el usuario de la sesión.
abstract class CalificacionRepository {
  /// Califica a la otra parte del pedido: el cliente al domiciliario o el
  /// domiciliario al cliente. La base decide a quién y recalcula su promedio.
  Future<void> calificar(String pedidoId, {required int valor});

  /// Lo que yo le di a ese pedido, o null si aún no lo califico.
  Future<int?> miCalificacion(String pedidoId);
}
