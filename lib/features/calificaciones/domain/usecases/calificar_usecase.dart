import 'package:mocca_go/features/calificaciones/domain/errors/calificacion_failure.dart';
import 'package:mocca_go/features/calificaciones/domain/repository/calificacion_repository.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// Calificar al domiciliario (12, cliente) o al cliente (18, domiciliario).
class CalificarUseCase {
  final CalificacionRepository _calificaciones;

  CalificarUseCase(this._calificaciones);

  Future<void> call(Pedido pedido, {required int valor}) async {
    if (pedido.estado != EstadoPedido.entregado) {
      throw const CalificacionFailure('Solo se califican pedidos entregados.');
    }
    if (valor < 1 || valor > 5) {
      throw const CalificacionFailure('Elige de 1 a 5 estrellas.');
    }
    await _calificaciones.calificar(pedido.id, valor: valor);
  }
}
