/// Motivo que el cliente elige en el chat (21 y 22). Los motivos de un
/// pedido en curso y los de uno entregado son distintos.
class MotivoReclamo {
  final String id;
  final String texto;

  /// true: aplica a pedidos entregados; false: a pedidos en curso.
  final bool paraEntregado;

  /// El bot pregunta qué producto se vio afectado (21b).
  final bool pideProducto;

  /// El bot pregunta cómo resolverlo (21c).
  final bool pideSolucion;

  const MotivoReclamo({
    required this.id,
    required this.texto,
    required this.paraEntregado,
    this.pideProducto = false,
    this.pideSolucion = false,
  });
}
