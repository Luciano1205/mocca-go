/// Eventos de 11 · Seguimiento.
abstract class SeguimientoEvent {}

/// Recargar el pedido: al abrir la pantalla y al deslizar hacia abajo.
class SeguimientoRequested extends SeguimientoEvent {}

/// El cliente confirmó la cancelación en 11c.
class CancelarPedidoConfirmed extends SeguimientoEvent {}
