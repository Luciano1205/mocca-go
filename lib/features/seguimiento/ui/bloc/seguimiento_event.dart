import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// Eventos de 11 · Seguimiento y 11d · Detalle.
abstract class SeguimientoEvent {}

/// Abre la suscripción en tiempo real del pedido: al abrir la pantalla y al
/// deslizar hacia abajo. Si ya llega entregado, revisa si ya calificó.
class SeguimientoStarted extends SeguimientoEvent {}

/// Supabase empujó el pedido actualizado. Solo lo lanza el Bloc.
class SeguimientoUpdated extends SeguimientoEvent {
  final Pedido pedido;

  SeguimientoUpdated(this.pedido);
}

/// El Stream falló. Solo lo lanza el Bloc.
class SeguimientoStreamFailed extends SeguimientoEvent {
  final String message;

  SeguimientoStreamFailed(this.message);
}

/// El cliente confirmó la cancelación en 11c.
class CancelarPedidoConfirmed extends SeguimientoEvent {}

/// Calificación del domiciliario desde la hoja de 12 · Calificar.
class CalificarDomiciliarioPressed extends SeguimientoEvent {
  final int valor;

  CalificarDomiciliarioPressed(this.valor);
}
