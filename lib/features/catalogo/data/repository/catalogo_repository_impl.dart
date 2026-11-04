import 'package:mocca_go/features/catalogo/data/source/supabase_catalogo_data_source.dart';
import 'package:mocca_go/features/catalogo/domain/entities/categoria.dart';
import 'package:mocca_go/features/catalogo/domain/entities/entidad_pago.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/catalogo/domain/entities/zona.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';

/// Cumple [CatalogoRepository] delegando en el data source de Supabase.
class CatalogoRepositoryImpl implements CatalogoRepository {
  final SupabaseCatalogoDataSource _dataSource;

  CatalogoRepositoryImpl(this._dataSource);

  @override
  Future<List<Categoria>> getCategorias() => _dataSource.getCategorias();

  @override
  Future<List<Producto>> getProductos({String? categoriaId}) {
    return _dataSource.getProductos(categoriaId: categoriaId);
  }

  @override
  Future<List<Zona>> getZonas() => _dataSource.getZonas();

  @override
  Future<List<EntidadPago>> getEntidadesPago() => _dataSource.getEntidadesPago();
}
