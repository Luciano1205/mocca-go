import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/errors/pedido_failure.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// El domiciliario toma un pendiente (15 · Detalle → 17 · Gestionar).
///
/// Si dos lo intentan a la vez, la base de datos deja pasar solo al primero;
/// el otro recibe [PedidoYaTomadoFailure] (15b · Pedido ya tomado).
class TomarPedidoUseCase {
  final PedidoRepository _pedidos;

  TomarPedidoUseCase(this._pedidos);

  Future<Pedido> call(String pedidoId) async {
    final tomado = await _pedidos.tomar(pedidoId);
    if (!tomado) throw const PedidoYaTomadoFailure();
    return _pedidos.getPedido(pedidoId);
  }
}
