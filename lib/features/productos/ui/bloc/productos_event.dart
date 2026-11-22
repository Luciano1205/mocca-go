import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';

/// Eventos de la pestaña Productos (19).
abstract class ProductosEvent {}

/// Abrir la suscripción en tiempo real de los productos.
class ProductosStarted extends ProductosEvent {}

/// Supabase empujó la lista actualizada. Solo lo lanza el Bloc.
class ProductosUpdated extends ProductosEvent {
  final List<Producto> productos;

  ProductosUpdated(this.productos);
}

/// El Stream falló. Solo lo lanza el Bloc.
class ProductosStreamFailed extends ProductosEvent {
  final String message;

  ProductosStreamFailed(this.message);
}

/// El domiciliario movió el switch Disponible/Agotado.
class DisponibilidadCambiada extends ProductosEvent {
  final Producto producto;
  final bool disponible;

  DisponibilidadCambiada(this.producto, {required this.disponible});
}
