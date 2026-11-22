import 'package:mocca_go/features/calificaciones/domain/repository/calificacion_repository.dart';

/// Para no pedir la calificación dos veces: null si aún no califico ese pedido.
class GetMiCalificacionUseCase {
  final CalificacionRepository _calificaciones;

  GetMiCalificacionUseCase(this._calificaciones);

  Future<int?> call(String pedidoId) => _calificaciones.miCalificacion(pedidoId);
}
