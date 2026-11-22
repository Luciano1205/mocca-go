import 'package:mocca_go/features/calificaciones/data/source/supabase_calificacion_data_source.dart';
import 'package:mocca_go/features/calificaciones/domain/repository/calificacion_repository.dart';

/// Cumple [CalificacionRepository] delegando en el data source de Supabase.
class CalificacionRepositoryImpl implements CalificacionRepository {
  final SupabaseCalificacionDataSource _dataSource;

  CalificacionRepositoryImpl(this._dataSource);

  @override
  Future<void> calificar(String pedidoId, {required int valor}) {
    return _dataSource.calificar(pedidoId, valor: valor);
  }

  @override
  Future<int?> miCalificacion(String pedidoId) => _dataSource.miCalificacion(pedidoId);
}
