import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Mis entregas del domiciliario en tiempo real (16 · Activos, 16b · Historial).
class WatchMisEntregasUseCase {
  final PedidoRepository _pedidos;

  WatchMisEntregasUseCase(this._pedidos);

  Stream<List<Pedido>> call({required bool activos}) {
    return _pedidos.watchMisEntregas(activos: activos);
  }
}
