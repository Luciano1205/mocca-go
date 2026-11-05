import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/errors/pedido_failure.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// El domiciliario avanza su entrega: Aceptado → En camino → Entregado
/// (17 · Gestionar). Tomar el pedido es [TomarPedidoUseCase].
class AvanzarPedidoUseCase {
  final PedidoRepository _pedidos;

  AvanzarPedidoUseCase(this._pedidos);

  Future<Pedido> call(Pedido pedido) async {
    final nuevo = pedido.estado.siguiente;
    if (pedido.estado == EstadoPedido.pendiente || nuevo == null) {
      throw PedidoFailure(
        'Un pedido ${pedido.estado.etiqueta.toLowerCase()} no se puede avanzar.',
      );
    }
    final cambiado = await _pedidos.cambiarEstado(
      pedido.id,
      actual: pedido.estado,
      nuevo: nuevo,
    );
    if (!cambiado) {
      throw const PedidoFailure('El pedido cambió. Vuelve a cargarlo.');
    }
    return _pedidos.getPedido(pedido.id);
  }
}
