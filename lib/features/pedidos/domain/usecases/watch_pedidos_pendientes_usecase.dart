import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Feed del domiciliario en tiempo real (14 y 14b · notificación de nuevo pedido).
class WatchPedidosPendientesUseCase {
  final PedidoRepository _pedidos;

  WatchPedidosPendientesUseCase(this._pedidos);

  Stream<List<Pedido>> call() => _pedidos.watchPendientes();
}
