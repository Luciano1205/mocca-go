import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';

enum ProductosStatus { initial, loading, success, failure }

/// Estado de la pestaña Productos.
class ProductosState {
  final ProductosStatus status;
  final List<Producto> productos;
  final String? errorMessage;

  /// Productos cuyo cambio se está guardando (el switch se deshabilita).
  final Set<String> guardando;

  const ProductosState({
    this.status = ProductosStatus.initial,
    this.productos = const [],
    this.errorMessage,
    this.guardando = const {},
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  ProductosState copyWith({
    ProductosStatus? status,
    List<Producto>? productos,
    String? errorMessage,
    Set<String>? guardando,
  }) {
    return ProductosState(
      status: status ?? this.status,
      productos: productos ?? this.productos,
      errorMessage: errorMessage,
      guardando: guardando ?? this.guardando,
    );
  }
}
