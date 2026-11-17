import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Un pedido en tiempo real: seguimiento del cliente (11) y gestión del
/// domiciliario (17).
class WatchPedidoUseCase {
  final PedidoRepository _pedidos;

  WatchPedidoUseCase(this._pedidos);

  Stream<Pedido> call(String pedidoId) => _pedidos.watchPedido(pedidoId);
}
