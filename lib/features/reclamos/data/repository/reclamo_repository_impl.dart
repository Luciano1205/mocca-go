import 'package:mocca_go/features/reclamos/data/source/supabase_reclamo_data_source.dart';
import 'package:mocca_go/features/reclamos/domain/entities/motivo_reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/repository/reclamo_repository.dart';

/// Cumple [ReclamoRepository] delegando en el data source de Supabase.
class ReclamoRepositoryImpl implements ReclamoRepository {
  final SupabaseReclamoDataSource _dataSource;

  ReclamoRepositoryImpl(this._dataSource);

  @override
  Future<List<MotivoReclamo>> getMotivos({required bool paraEntregado}) {
    return _dataSource.getMotivos(paraEntregado: paraEntregado);
  }

  @override
  Future<Reclamo> abrir(NuevoReclamo reclamo) => _dataSource.abrir(reclamo);
}
