import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';

/// Lo que Menú y Carrito le dicen a [CarritoBloc].
abstract class CarritoEvent {}

/// "+" o "Agregar": suma una unidad del producto.
class CarritoProductoAgregado extends CarritoEvent {
  final Producto producto;

  CarritoProductoAgregado(this.producto);
}

/// "−": resta una unidad; si llega a cero, el producto sale del carrito.
class CarritoProductoQuitado extends CarritoEvent {
  final String productoId;

  CarritoProductoQuitado(this.productoId);
}

/// "Vaciar carrito", al enviar el pedido y al entrar con otra sesión.
class CarritoVaciado extends CarritoEvent {}
