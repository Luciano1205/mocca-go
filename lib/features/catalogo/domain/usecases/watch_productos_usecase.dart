import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';

/// Productos en tiempo real: el menú del cliente ve los agotados al instante
/// y la pestaña Productos del domiciliario refleja su switch.
class WatchProductosUseCase {
  final CatalogoRepository _catalogo;

  WatchProductosUseCase(this._catalogo);

  /// Con [categoriaId] solo los de esa categoría.
  Stream<List<Producto>> call({String? categoriaId}) {
    return _catalogo.watchProductos().map(
      (productos) => categoriaId == null
          ? productos
          : productos.where((p) => p.categoriaId == categoriaId).toList(),
    );
  }
}
