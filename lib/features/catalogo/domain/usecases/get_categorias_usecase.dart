import 'package:mocca_go/features/catalogo/domain/entities/categoria.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';

/// Chips del menú (06 · Menú).
class GetCategoriasUseCase {
  final CatalogoRepository _catalogo;

  GetCategoriasUseCase(this._catalogo);

  Future<List<Categoria>> call() => _catalogo.getCategorias();
}
