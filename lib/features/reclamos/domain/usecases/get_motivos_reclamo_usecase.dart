import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/reclamos/domain/entities/motivo_reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/errors/reclamo_failure.dart';
import 'package:mocca_go/features/reclamos/domain/repository/reclamo_repository.dart';

/// Primera pregunta del bot: los motivos según el estado del pedido
/// (21 · entregado, 22 · en curso).
class GetMotivosReclamoUseCase {
  final ReclamoRepository _reclamos;

  GetMotivosReclamoUseCase(this._reclamos);

  Future<List<MotivoReclamo>> call(Pedido pedido) async {
    if (pedido.estado == EstadoPedido.cancelado) {
      throw const ReclamoFailure('Los pedidos cancelados no tienen reclamos.');
    }
    return _reclamos.getMotivos(paraEntregado: pedido.estado == EstadoPedido.entregado);
  }
}
