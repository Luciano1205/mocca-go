/// Error de dominio para todo lo que falla con un pedido.
///
/// [toString] devuelve solo [message], para que el Bloc lo muestre tal cual.
class PedidoFailure implements Exception {
  final String message;

  const PedidoFailure(this.message);

  @override
  String toString() => message;
}

/// Otro domiciliario tomó el pedido primero (15b · Pedido ya tomado).
class PedidoYaTomadoFailure extends PedidoFailure {
  const PedidoYaTomadoFailure()
    : super('Otro domiciliario tomó este pedido primero.');
}
