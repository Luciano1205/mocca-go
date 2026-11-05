import 'package:mocca_go/features/catalogo/domain/entities/zona.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';

/// Zonas para elegir dónde entregar (08b · Seleccionar zona).
class GetZonasUseCase {
  final CatalogoRepository _catalogo;

  GetZonasUseCase(this._catalogo);

  Future<List<Zona>> call() => _catalogo.getZonas();
}
