import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';

/// Productos del menú, todos o de una categoría (06 · Menú).
class GetProductosUseCase {
  final CatalogoRepository _catalogo;

  GetProductosUseCase(this._catalogo);

  Future<List<Producto>> call({String? categoriaId}) {
    return _catalogo.getProductos(categoriaId: categoriaId);
  }
}
