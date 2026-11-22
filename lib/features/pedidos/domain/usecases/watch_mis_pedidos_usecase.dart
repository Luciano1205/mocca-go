import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Mis pedidos del cliente en tiempo real (10 · Activos, 10b · Historial).
class WatchMisPedidosUseCase {
  final PedidoRepository _pedidos;

  WatchMisPedidosUseCase(this._pedidos);

  /// El más reciente arriba.
  Stream<List<Pedido>> call({required bool activos}) {
    return _pedidos
        .watchMisPedidos(activos: activos)
        .map((lista) => [...lista]..sort((a, b) => b.creadoEn.compareTo(a.creadoEn)));
  }
}
