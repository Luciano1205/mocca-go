/// Eventos del feed de pedidos pendientes (14).
abstract class PendientesEvent {}

/// Cargar o recargar el feed: al abrir la pestaña, al deslizar hacia abajo
/// y al volver del detalle.
class PendientesRequested extends PendientesEvent {}
