import 'package:mocca_go/features/catalogo/domain/entities/categoria.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';

enum MenuStatus { initial, loading, success, failure }

/// Estado del menú: chips, chip elegido (null es "Todos") y todos los
/// productos que llegan en tiempo real.
class MenuState {
  final MenuStatus status;
  final List<Categoria> categorias;
  final String? categoriaId;
  final List<Producto> todos;
  final String? errorMessage;

  const MenuState({
    this.status = MenuStatus.initial,
    this.categorias = const [],
    this.categoriaId,
    this.todos = const [],
    this.errorMessage,
  });

  /// Los productos del chip elegido.
  List<Producto> get productos =>
      categoriaId == null ? todos : todos.where((p) => p.categoriaId == categoriaId).toList();

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  /// [categoriaId] tampoco, porque null es una opción válida ("Todos").
  MenuState copyWith({
    MenuStatus? status,
    List<Categoria>? categorias,
    required String? categoriaId,
    List<Producto>? todos,
    String? errorMessage,
  }) {
    return MenuState(
      status: status ?? this.status,
      categorias: categorias ?? this.categorias,
      categoriaId: categoriaId,
      todos: todos ?? this.todos,
      errorMessage: errorMessage,
    );
  }
}
