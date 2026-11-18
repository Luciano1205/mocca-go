import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';

/// Switch Disponible/Agotado del domiciliario (19 · Disponibilidad de productos).
class CambiarDisponibilidadUseCase {
  final CatalogoRepository _catalogo;

  CambiarDisponibilidadUseCase(this._catalogo);

  Future<void> call(String productoId, {required bool disponible}) {
    return _catalogo.cambiarDisponibilidad(productoId, disponible: disponible);
  }
}
