import 'package:mocca_go/features/auth/data/source/supabase_usuario_data_source.dart';
import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/repository/usuario_repository.dart';

/// Cumple [UsuarioRepository] delegando en el data source de Supabase.
class UsuarioRepositoryImpl implements UsuarioRepository {
  final SupabaseUsuarioDataSource _dataSource;

  UsuarioRepositoryImpl(this._dataSource);

  @override
  Future<Usuario> getUsuario(String id) => _dataSource.getUsuario(id);
}
