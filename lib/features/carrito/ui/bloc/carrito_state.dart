import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';

/// Un producto del carrito con cuántas unidades lleva.
class ItemCarrito {
  final Producto producto;
  final int cantidad;

  const ItemCarrito({required this.producto, required this.cantidad});

  int get subtotal => producto.precio * cantidad;
}

/// Estado del carrito: los productos en el orden en que se agregaron.
/// No tiene status porque todo pasa en memoria, sin esperar a Supabase.
class CarritoState {
  final List<ItemCarrito> items;

  const CarritoState({this.items = const []});

  bool get vacio => items.isEmpty;

  int get total => items.fold(0, (suma, i) => suma + i.subtotal);

  int get totalUnidades => items.fold(0, (suma, i) => suma + i.cantidad);

  /// Unidades de un producto (0 si no está), para el contador del menú.
  int cantidadDe(String productoId) {
    for (final item in items) {
      if (item.producto.id == productoId) return item.cantidad;
    }
    return 0;
  }

  /// Lo que se manda en [NuevoPedido] (08 · Datos de entrega).
  List<LineaPedido> get lineas => items
      .map(
        (i) => LineaPedido(
          productoId: i.producto.id,
          cantidad: i.cantidad,
          precioUnitario: i.producto.precio,
        ),
      )
      .toList();

  CarritoState copyWith({List<ItemCarrito>? items}) {
    return CarritoState(items: items ?? this.items);
  }
}
