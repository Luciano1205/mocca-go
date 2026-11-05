import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/errors/pedido_failure.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// El cliente cancela mientras nadie lo ha tomado (11c · Confirmar cancelación).
class CancelarPedidoUseCase {
  final PedidoRepository _pedidos;

  CancelarPedidoUseCase(this._pedidos);

  Future<Pedido> call(String pedidoId) async {
    final cancelado = await _pedidos.cancelar(pedidoId);
    if (!cancelado) {
      throw const PedidoFailure(
        'Ya no se puede cancelar: un domiciliario tomó tu pedido.',
      );
    }
    return _pedidos.getPedido(pedidoId);
  }
}
