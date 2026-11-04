import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/errors/pedido_failure.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Envía el pedido del cliente (08 · Datos de entrega → 09 · Pedido enviado).
///
/// Valida aquí para dar un mensaje claro; la base de datos vuelve a revisar
/// precios, agotados y el valor del billete.
class CrearPedidoUseCase {
  final PedidoRepository _pedidos;

  CrearPedidoUseCase(this._pedidos);

  Future<Pedido> call(NuevoPedido pedido) async {
    if (pedido.lineas.isEmpty) {
      throw const PedidoFailure('Tu pedido está vacío.');
    }
    final referencia = pedido.referencia.trim();
    if (referencia.isEmpty) {
      throw const PedidoFailure('Escribe una referencia para encontrarte.');
    }
    if (pedido.metodo == MetodoPago.transferencia && pedido.entidadPagoId == null) {
      throw const PedidoFailure('Elige a qué cuenta vas a transferir.');
    }
    final valor = pedido.valorEntregado;
    if (pedido.metodo == MetodoPago.efectivo && valor != null && valor < pedido.total) {
      throw const PedidoFailure('El valor con el que pagas no alcanza para el total.');
    }
    final nota = pedido.nota?.trim();
    return _pedidos.crear(
      NuevoPedido(
        lineas: pedido.lineas,
        zonaId: pedido.zonaId,
        referencia: referencia,
        nota: (nota == null || nota.isEmpty) ? null : nota,
        metodo: pedido.metodo,
        valorEntregado: pedido.metodo == MetodoPago.efectivo ? valor : null,
        entidadPagoId: pedido.metodo == MetodoPago.transferencia ? pedido.entidadPagoId : null,
      ),
    );
  }
}
