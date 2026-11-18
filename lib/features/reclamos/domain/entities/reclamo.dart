/// Cómo prefiere el cliente que se resuelva (21c).
enum SolucionReclamo {
  reenviar('reenviar', 'Reenviar el pedido'),
  devolver('devolver', 'Devolver el dinero'),
  hablarEquipo('hablar_equipo', 'Hablar con alguien del equipo');

  /// Valor en la columna `reclamo.solucion`.
  final String valor;
  final String etiqueta;

  const SolucionReclamo(this.valor, this.etiqueta);
}

/// Lo que el cliente arma en el chat antes de enviarlo.
class NuevoReclamo {
  final String pedidoId;
  final String motivoId;
  final SolucionReclamo? solucion;

  /// Ids de `detalle_pedido` afectados (ItemPedido.id). Vacío si el motivo
  /// no pide producto.
  final List<String> detalleIds;

  const NuevoReclamo({
    required this.pedidoId,
    required this.motivoId,
    this.solucion,
    this.detalleIds = const [],
  });
}

/// Reclamo registrado. El chat muestra "Registramos tu reclamo #R-102".
class Reclamo {
  final String id;
  final int numero;

  const Reclamo({required this.id, required this.numero});

  /// "R-102".
  String get codigo => 'R-$numero';
}
