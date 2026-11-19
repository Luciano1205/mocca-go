import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// Eventos de Mis entregas (16).
abstract class MisEntregasEvent {}

/// Abrir la suscripción en tiempo real. Con [activos] cambia de pestaña
/// (Activos / Historial); sin él vuelve a abrir la pestaña actual.
class MisEntregasStarted extends MisEntregasEvent {
  final bool? activos;

  MisEntregasStarted({this.activos});
}

/// Supabase empujó la lista actualizada. Solo lo lanza el Bloc.
class MisEntregasUpdated extends MisEntregasEvent {
  final List<Pedido> pedidos;

  MisEntregasUpdated(this.pedidos);
}

/// El Stream falló. Solo lo lanza el Bloc.
class MisEntregasStreamFailed extends MisEntregasEvent {
  final String message;

  MisEntregasStreamFailed(this.message);
}
