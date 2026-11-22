import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// Eventos del feed de pedidos pendientes (14).
abstract class PendientesEvent {}

/// Abrir la suscripción en tiempo real: al entrar al panel y al deslizar
/// hacia abajo (por si se cayó la conexión).
class PendientesStarted extends PendientesEvent {}

/// Supabase empujó el feed actualizado. Solo lo lanza el Bloc.
class PendientesUpdated extends PendientesEvent {
  final List<Pedido> pedidos;

  PendientesUpdated(this.pedidos);
}

/// El Stream falló. Solo lo lanza el Bloc.
class PendientesStreamFailed extends PendientesEvent {
  final String message;

  PendientesStreamFailed(this.message);
}
