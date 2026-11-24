import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// Eventos de Mis pedidos (10).
abstract class MisPedidosEvent {}

/// Abre las dos suscripciones en tiempo real (Activos e Historial): al entrar
/// al panel y al deslizar hacia abajo (por si se cayó la conexión).
class MisPedidosStarted extends MisPedidosEvent {}

/// Se tocó el chip Activos o Historial. Solo cambia qué lista se muestra.
class MisPedidosTabChanged extends MisPedidosEvent {
  final bool activos;

  MisPedidosTabChanged(this.activos);
}

/// Supabase empujó una de las dos listas. Solo lo lanza el Bloc.
class MisPedidosUpdated extends MisPedidosEvent {
  final bool activos;
  final List<Pedido> pedidos;

  MisPedidosUpdated({required this.activos, required this.pedidos});
}

/// Un Stream falló. Solo lo lanza el Bloc.
class MisPedidosStreamFailed extends MisPedidosEvent {
  final String message;

  MisPedidosStreamFailed(this.message);
}
