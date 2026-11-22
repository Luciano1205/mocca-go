/// Eventos de Gestionar pedido (17).
abstract class GestionarPedidoEvent {}

/// Al abrir: si el pedido ya está entregado, revisa si ya calificó al cliente.
class GestionarPedidoStarted extends GestionarPedidoEvent {}

/// Aceptado → En camino, o En camino → Entregado.
class AvanzarPedidoPressed extends GestionarPedidoEvent {}

/// Calificación del cliente desde la hoja de 18 · Calificar cliente.
class CalificarClientePressed extends GestionarPedidoEvent {
  final int valor;

  CalificarClientePressed(this.valor);
}
