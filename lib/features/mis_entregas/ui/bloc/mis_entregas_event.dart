/// Eventos de Mis entregas (16).
abstract class MisEntregasEvent {}

/// Cargar la lista. Con [activos] cambia de pestaña (Activos / Historial);
/// sin él recarga la pestaña actual.
class MisEntregasRequested extends MisEntregasEvent {
  final bool? activos;

  MisEntregasRequested({this.activos});
}
