import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Feed del domiciliario (14 · Pedidos pendientes).
class GetPedidosPendientesUseCase {
  final PedidoRepository _pedidos;

  GetPedidosPendientesUseCase(this._pedidos);

  Future<List<Pedido>> call() => _pedidos.pendientes();
}
