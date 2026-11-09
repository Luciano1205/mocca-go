/// Eventos de Mis pedidos (10).
abstract class MisPedidosEvent {}

/// Cargar la lista. Con [activos] cambia de pestaña (Activos / Historial);
/// sin él recarga la pestaña actual.
class MisPedidosRequested extends MisPedidosEvent {
  final bool? activos;

  MisPedidosRequested({this.activos});
}
