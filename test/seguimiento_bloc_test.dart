import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/calificaciones/domain/usecases/calificar_usecase.dart';
import 'package:mocca_go/features/calificaciones/domain/usecases/get_mi_calificacion_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/cancelar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_pedido_usecase.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_bloc.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_event.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_state.dart';

import 'fakes/fake_complementos.dart';
import 'fakes/fake_pedidos.dart';

/// Como Supabase: responde "¿ya calificó?" con algo de demora.
class _CalificacionLenta extends FakeCalificacionRepository {
  @override
  Future<int?> miCalificacion(String pedidoId) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return super.miCalificacion(pedidoId);
  }
}

void main() {
  late FakePedidoRepository pedidos;
  late FakeCalificacionRepository calificaciones;

  setUp(() {
    pedidos = FakePedidoRepository(FakeCatalogoRepository());
    calificaciones = _CalificacionLenta();
  });

  Future<void> esperar() => Future<void>.delayed(const Duration(milliseconds: 80));

  Future<Pedido> crear() {
    pedidos.usuarioActual = 'laura';
    return pedidos.crear(
      const NuevoPedido(
        lineas: [LineaPedido(productoId: 'americano', cantidad: 1, precioUnitario: 4000)],
        zonaId: 'labs',
        referencia: 'Entrada',
        metodo: MetodoPago.efectivo,
      ),
    );
  }

  SeguimientoBloc bloc(Pedido pedido) => SeguimientoBloc(
    WatchPedidoUseCase(pedidos),
    CancelarPedidoUseCase(pedidos),
    CalificarUseCase(calificaciones),
    GetMiCalificacionUseCase(calificaciones),
    pedido,
  );

  Future<void> andresEntrega(Pedido pedido) async {
    pedidos.usuarioActual = 'Andrés Ruiz';
    await pedidos.tomar(pedido.id);
    await pedidos.cambiarEstado(
      pedido.id,
      actual: EstadoPedido.aceptado,
      nuevo: EstadoPedido.enCamino,
    );
    await pedidos.cambiarEstado(
      pedido.id,
      actual: EstadoPedido.enCamino,
      nuevo: EstadoPedido.entregado,
    );
  }

  test('Si Supabase repite "Entregado", la hoja de calificar se pide una sola vez', () async {
    final pedido = await crear();
    final seguimiento = bloc(pedido);
    final pedidas = <SeguimientoState>[];
    seguimiento.stream.where((s) => s.pedirCalificacion).listen(pedidas.add);
    seguimiento.add(SeguimientoStarted());
    await esperar();

    await andresEntrega(pedido);
    // Otro cambio en la tabla hace que el Stream vuelva a emitir el mismo pedido.
    await crear();
    await esperar();

    expect(seguimiento.state.pedido.estado, EstadoPedido.entregado);
    expect(pedidas.length, 1);
    await seguimiento.close();
  });

  test('No pide calificar si ya había calificado', () async {
    final pedido = await crear();
    calificaciones.dadas[pedido.id] = 4;
    final seguimiento = bloc(pedido);
    final pedidas = <SeguimientoState>[];
    seguimiento.stream.where((s) => s.pedirCalificacion).listen(pedidas.add);
    seguimiento.add(SeguimientoStarted());
    await esperar();

    await andresEntrega(pedido);
    await esperar();
    expect(pedidas, isEmpty);
    expect(seguimiento.state.miCalificacion, 4);
    await seguimiento.close();
  });

  test('Calificar guarda las estrellas y ya no se pide', () async {
    final pedido = await crear();
    final seguimiento = bloc(pedido);
    seguimiento.add(SeguimientoStarted());
    await esperar();
    await andresEntrega(pedido);
    await esperar();

    seguimiento.add(CalificarDomiciliarioPressed(5));
    await esperar();
    expect(calificaciones.dadas[pedido.id], 5);
    expect(seguimiento.state.miCalificacion, 5);
    await seguimiento.close();
  });
}
