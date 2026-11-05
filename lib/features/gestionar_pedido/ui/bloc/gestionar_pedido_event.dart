/// Eventos de Gestionar pedido (17).
abstract class GestionarPedidoEvent {}

/// Aceptado → En camino, o En camino → Entregado.
class AvanzarPedidoPressed extends GestionarPedidoEvent {}
