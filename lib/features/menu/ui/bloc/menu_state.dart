import 'package:mocca_go/features/catalogo/domain/entities/categoria.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';

enum MenuStatus { initial, loading, success, failure }

/// Estado del menú: chips, chip elegido (null es "Todos") y sus productos.
class MenuState {
  final MenuStatus status;
  final List<Categoria> categorias;
  final String? categoriaId;
  final List<Producto> productos;
  final String? errorMessage;

  const MenuState({
    this.status = MenuStatus.initial,
    this.categorias = const [],
    this.categoriaId,
    this.productos = const [],
    this.errorMessage,
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  /// [categoriaId] tampoco, porque null es una opción válida ("Todos").
  MenuState copyWith({
    MenuStatus? status,
    List<Categoria>? categorias,
    required String? categoriaId,
    List<Producto>? productos,
    String? errorMessage,
  }) {
    return MenuState(
      status: status ?? this.status,
      categorias: categorias ?? this.categorias,
      categoriaId: categoriaId,
      productos: productos ?? this.productos,
      errorMessage: errorMessage,
    );
  }
}
