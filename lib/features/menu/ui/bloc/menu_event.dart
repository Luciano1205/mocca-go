/// Eventos del menú (06).
abstract class MenuEvent {}

/// Cargar categorías y productos: al abrir el panel y al deslizar hacia abajo.
class MenuRequested extends MenuEvent {}

/// Se tocó un chip. [categoriaId] null es "Todos".
class MenuCategoriaSelected extends MenuEvent {
  final String? categoriaId;

  MenuCategoriaSelected(this.categoriaId);
}
