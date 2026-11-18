import 'package:mocca_go/features/calificaciones/domain/errors/calificacion_failure.dart';
import 'package:mocca_go/features/calificaciones/domain/repository/calificacion_repository.dart';
import 'package:mocca_go/features/reclamos/domain/entities/motivo_reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/repository/reclamo_repository.dart';

/// Calificaciones en memoria: una por pedido, como la restricción única.
class FakeCalificacionRepository implements CalificacionRepository {
  final Map<String, int> dadas = {};

  @override
  Future<void> calificar(String pedidoId, {required int valor}) async {
    if (dadas.containsKey(pedidoId)) {
      throw const CalificacionFailure('Ya calificaste este pedido.');
    }
    dadas[pedidoId] = valor;
  }

  @override
  Future<int?> miCalificacion(String pedidoId) async => dadas[pedidoId];
}

/// Motivos del prototipo y reclamos en memoria.
class FakeReclamoRepository implements ReclamoRepository {
  final motivos = const [
    MotivoReclamo(id: 'no-llega', texto: 'Mi pedido no ha llegado', paraEntregado: false),
    MotivoReclamo(id: 'demora', texto: 'Se está demorando mucho', paraEntregado: false),
    MotivoReclamo(
      id: 'falto',
      texto: 'Faltó un producto',
      paraEntregado: true,
      pideProducto: true,
      pideSolucion: true,
    ),
    MotivoReclamo(id: 'demoro', texto: 'Demoró mucho', paraEntregado: true),
  ];

  final List<NuevoReclamo> abiertos = [];

  @override
  Future<List<MotivoReclamo>> getMotivos({required bool paraEntregado}) async =>
      motivos.where((m) => m.paraEntregado == paraEntregado).toList();

  @override
  Future<Reclamo> abrir(NuevoReclamo reclamo) async {
    abiertos.add(reclamo);
    return Reclamo(id: 'r${abiertos.length}', numero: 100 + abiertos.length);
  }
}
