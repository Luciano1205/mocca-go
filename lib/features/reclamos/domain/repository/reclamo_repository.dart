import 'package:mocca_go/features/reclamos/domain/entities/motivo_reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';

/// Chat de reclamos, versión corta: el bot guía y el reclamo queda
/// registrado para que el equipo contacte al cliente.
abstract class ReclamoRepository {
  /// Motivos de un pedido entregado o de uno en curso, en orden.
  Future<List<MotivoReclamo>> getMotivos({required bool paraEntregado});

  /// Registra el reclamo con sus productos afectados.
  Future<Reclamo> abrir(NuevoReclamo reclamo);
}
