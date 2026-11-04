import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Entregas del domiciliario (16 · Activos y 16b · Historial).
class GetMisEntregasUseCase {
  final PedidoRepository _pedidos;

  GetMisEntregasUseCase(this._pedidos);

  Future<List<Pedido>> call({required bool activos}) {
    return _pedidos.misEntregas(activos: activos);
  }
}
