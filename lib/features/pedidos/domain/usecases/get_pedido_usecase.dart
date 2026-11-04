import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Un pedido con todo su detalle (11 · Seguimiento, 15 · Detalle, 17 · Gestionar).
class GetPedidoUseCase {
  final PedidoRepository _pedidos;

  GetPedidoUseCase(this._pedidos);

  Future<Pedido> call(String pedidoId) => _pedidos.getPedido(pedidoId);
}
