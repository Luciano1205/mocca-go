import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Pedidos del cliente (10 · Activos y 10b · Historial).
class GetMisPedidosUseCase {
  final PedidoRepository _pedidos;

  GetMisPedidosUseCase(this._pedidos);

  Future<List<Pedido>> call({required bool activos}) {
    return _pedidos.misPedidos(activos: activos);
  }
}
