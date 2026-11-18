import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/reclamos/domain/entities/motivo_reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/errors/reclamo_failure.dart';
import 'package:mocca_go/features/reclamos/domain/repository/reclamo_repository.dart';

/// Último paso del chat: registra el reclamo (21d y 22b, "Registramos tu
/// reclamo #R-102").
class AbrirReclamoUseCase {
  final ReclamoRepository _reclamos;

  AbrirReclamoUseCase(this._reclamos);

  Future<Reclamo> call(
    Pedido pedido, {
    required MotivoReclamo motivo,
    List<ItemPedido> productos = const [],
    SolucionReclamo? solucion,
  }) async {
    if (motivo.pideProducto && productos.isEmpty) {
      throw const ReclamoFailure('Elige qué producto se vio afectado.');
    }
    if (motivo.pideSolucion && solucion == null) {
      throw const ReclamoFailure('Elige cómo prefieres que lo solucionemos.');
    }
    return _reclamos.abrir(
      NuevoReclamo(
        pedidoId: pedido.id,
        motivoId: motivo.id,
        solucion: motivo.pideSolucion ? solucion : null,
        detalleIds: [
          if (motivo.pideProducto)
            for (final p in productos)
              if (p.id != null) p.id!,
        ],
      ),
    );
  }
}
