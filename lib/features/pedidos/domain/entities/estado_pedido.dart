/// Estados del pedido, en el orden en que avanza.
///
/// [valor] es como se guarda en la columna `pedido.estado`.
enum EstadoPedido {
  pendiente('pendiente'),
  aceptado('aceptado'),
  enCamino('en_camino'),
  entregado('entregado'),
  cancelado('cancelado');

  final String valor;

  const EstadoPedido(this.valor);

  static EstadoPedido desde(String valor) {
    return EstadoPedido.values.firstWhere((e) => e.valor == valor);
  }

  /// Sigue en curso: aparece en "Activos".
  bool get activo => this == pendiente || this == aceptado || this == enCamino;

  /// Estado al que lo pasa el domiciliario, o null si ya no avanza.
  EstadoPedido? get siguiente {
    switch (this) {
      case EstadoPedido.pendiente:
        return EstadoPedido.aceptado;
      case EstadoPedido.aceptado:
        return EstadoPedido.enCamino;
      case EstadoPedido.enCamino:
        return EstadoPedido.entregado;
      case EstadoPedido.entregado:
      case EstadoPedido.cancelado:
        return null;
    }
  }

  /// Texto para mostrar en la app.
  String get etiqueta {
    switch (this) {
      case EstadoPedido.pendiente:
        return 'Pendiente';
      case EstadoPedido.aceptado:
        return 'Aceptado';
      case EstadoPedido.enCamino:
        return 'En camino';
      case EstadoPedido.entregado:
        return 'Entregado';
      case EstadoPedido.cancelado:
        return 'Cancelado';
    }
  }
}
